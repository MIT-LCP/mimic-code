with ce as
(
  SELECT
      ce.stay_id
    , ce.charttime
    , itemid
    -- TODO: clean
    , value
    , case
        -- begin fio2 cleaning
        when itemid = 223835
        then
            case
                when valuenum > 0 and valuenum <= 1
                then valuenum * 100
                -- improperly input data - looks like O2 flow in litres
                when valuenum > 1 and valuenum < 21
                then null
                when valuenum >= 21 and valuenum <= 100
                then valuenum
            ELSE NULL END
        -- end of fio2 cleaning
    ELSE valuenum END AS valuenum
    , valueuom
    , storetime
  FROM `physionet-data.mimic_icu.chartevents` ce
  where ce.value IS NOT NULL
  AND ce.stay_id IS NOT NULL
  AND ce.itemid IN
  (
      224687 -- minute volume
    , 224685, 224684, 224686 -- tidal volume
    , 224696 -- PlateauPressure
    , 220339, 224700 -- PEEP
    , 223835 -- fio2
    , 223849 -- vent mode
    , 223848 -- vent type
    , 224691 -- flow rate (L/min) (looks like high-flow)
    , 227287 -- additional o2 flow
  )
  UNION ALL
  -- add in the extubation flags from procedureevents_mv
  -- note that we only need the start time for the extubation
  -- (extubation is always charted as ending 1 minute after it started)
  select
      stay_id
      , starttime as charttime
      , itemid
      , 'extubated' as value
      , 1 as valuenum
      , NULL AS valueuom
      , storetime
  from `physionet-data.mimic_icu.procedureevents`
  where itemid in
  (
      227194 -- "Extubation"
    , 225468 -- "Unplanned Extubation (patient-initiated)"
    , 225477 -- "Unplanned Extubation (non-patient initiated)"
  )
)
-- retain only 1 o2 flow per charted row, prioritizing the last documented value
, o2flow AS
(
  select
      ce.stay_id
    , ce.charttime
    , itemid
    , valuenum
    , valueuom
    , ROW_NUMBER() OVER (PARTITION BY stay_id, charttime ORDER BY storetime DESC) as rn
  FROM `physionet-data.mimic_icu.chartevents` ce
  where ce.value IS NOT NULL
  AND ce.stay_id IS NOT NULL
  AND ce.itemid IN
  (
      223834 -- o2 flow
    , 227582 -- bipap o2 flow
  )
)
, o2 AS
(
    -- -- The below ITEMID can have multiple entires for charttime/storetime
    -- -- These are totally valid entries.
    --   224181 -- Small Volume Neb Drug #1              | Respiratory             | Text       | chartevents
    -- , 227570 -- Small Volume Neb Drug/Dose #1         | Respiratory             | Text       | chartevents
    -- , 224833 -- SBT Deferred                          | Respiratory             | Text       | chartevents
    -- , 224716 -- SBT Stopped                           | Respiratory             | Text       | chartevents
    -- , 224740 -- RSBI Deferred                         | Respiratory             | Text       | chartevents
    -- , 224829 -- Trach Tube Type                       | Respiratory             | Text       | chartevents
    -- , 226732 -- O2 Delivery Device(s)                 | Respiratory             | Text       | chartevents
    -- , 226873 -- Inspiratory Ratio                     | Respiratory             | Numeric    | chartevents
    -- , 226871 -- Expiratory Ratio                      | Respiratory             | Numeric    | chartevents
    -- maximum of 4 o2 devices on at once
    SELECT
        stay_id, charttime, itemid
        , value AS o2_device
    , ROW_NUMBER() OVER (PARTITION BY stay_id, charttime, itemid ORDER BY value DESC) as rn
    FROM `physionet-data.mimic_icu.chartevents`
    WHERE itemid = 226732 -- oxygen delivery device(s)
)
, stg AS
(
    select
    COALESCE(ce.stay_id, o2.stay_id, o2flow.stay_id) AS stay_id
    , COALESCE(ce.charttime, o2.charttime, o2flow.charttime) AS charttime
    , COALESCE(ce.itemid, o2.itemid, o2flow.itemid) AS itemid
    , ce.value, ce.valuenum
    , o2.o2_device
    , o2.rn
    from ce
    FULL OUTER JOIN o2
      ON ce.stay_id = o2.stay_id
      AND ce.charttime = o2.charttime
      AND ce.itemid = o2.itemid
    FULL OUTER JOIN (SELECT * FROM o2flow WHERE rn = 1) o2flow
      ON ce.stay_id = o2flow.stay_id
      AND ce.charttime = o2flow.charttime
      AND ce.itemid = o2flow.itemid
)
SELECT
    stay_id, charttime
    , MAX(CASE WHEN itemid in (224687) THEN valuenum ELSE NULL END) AS minute_volume
    , MAX(CASE WHEN itemid in (224685) THEN valuenum ELSE NULL END) AS vt_observed
    , MAX(CASE WHEN itemid in (224684) THEN valuenum ELSE NULL END) AS vt_set
    , MAX(CASE WHEN itemid in (224686) THEN valuenum ELSE NULL END) AS vt_spont
    , MAX(CASE WHEN itemid in (224696) THEN valuenum ELSE NULL END) AS plateau_pressure
    , MAX(CASE WHEN itemid in (220339, 224700) THEN valuenum ELSE NULL END) AS peep
    , MAX(CASE WHEN itemid in (223849) THEN value ELSE NULL END) AS ventmode
    , MAX(CASE WHEN itemid in (223848) THEN value ELSE NULL END) AS venttype
    , MAX(CASE WHEN itemid in (227194, 225468, 225477) THEN valuenum ELSE NULL END) AS extubated
    , MAX(CASE WHEN itemid in (223834, 227582) THEN valuenum ELSE NULL END) AS o2_flow
    , MAX(CASE WHEN itemid in (224691) THEN valuenum ELSE NULL END) AS o2_highflow
    , MAX(CASE WHEN itemid in (227287) THEN valuenum ELSE NULL END) AS o2_flow_additional
    -- ensure we retain all o2 devices for the patient
    , MAX(CASE WHEN itemid = 226732 AND rn = 1 THEN o2_device ELSE NULL END) AS o2_delivery_device_1
    , MAX(CASE WHEN itemid = 226732 AND rn = 2 THEN o2_device ELSE NULL END) AS o2_delivery_device_2
    , MAX(CASE WHEN itemid = 226732 AND rn = 3 THEN o2_device ELSE NULL END) AS o2_delivery_device_3
    , MAX(CASE WHEN itemid = 226732 AND rn = 4 THEN o2_device ELSE NULL END) AS o2_delivery_device_4
FROM stg
GROUP BY stay_id, charttime
ORDER BY stay_id, charttime;
