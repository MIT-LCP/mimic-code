SELECT
  pr.subject_id
  , pr.starttime
  , pr.stoptime
  , ph.entertime
  --, ph.verifiedtime
  , pr.pharmacy_id
  , ph.poe_id
  -- aux columns used for debugging
  -- , pr.pharmacy_id
  , pr.route
  , ph.frequency
  , ph.disp_sched
  , pr.dose_val_rx
  , CASE
    -- Cast numeric values directly
    WHEN REGEXP_CONTAINS(pr.dose_val_rx, r'^\s*[0-9]*\.?[0-9]+\s*$')
      THEN CAST(pr.dose_val_rx AS NUMERIC)
    -- 25,000
    WHEN REGEXP_CONTAINS(pr.dose_val_rx, r'^\s*([0-9]*,?)+\s*$')
      THEN CAST(REPLACE(pr.dose_val_rx, ',', '') AS NUMERIC)
    -- for doses like 1500-3000, use the lower end
    WHEN REGEXP_CONTAINS(pr.dose_val_rx, r'^\s*([0-9]*\.?[0-9]+)-([0-9]*\.?[0-9]+)\s*$')
      THEN CAST(REGEXP_EXTRACT(pr.dose_val_rx, r'^\s*([0-9]*\.?[0-9]+)-') AS NUMERIC)
    ELSE NULL END AS dose_val_rx_numeric
  , pr.dose_unit_rx
  -- clean doses per 24 hour
  -- fixes 0s present if doses/24hr < 1
  -- adds dose when it's missing
  , CASE
      -- twice a day (BID)
      WHEN REGEXP_CONTAINS(ph.frequency, '^BID') THEN 2 -- BID
      WHEN ph.frequency IN ('Q12H', 'Q 12H') THEN 2 -- BID
      WHEN REGEXP_CONTAINS(ph.frequency, '^(1X|X1|ONCE|POST HD)') THEN 1
      -- TODO: ASDIR (maybe Q6H?)
      -- daily
      WHEN REGEXP_CONTAINS(ph.frequency, '^DAILY') THEN 1
      WHEN ph.frequency IN ('Q24H', 'Q 24H', 'HS', 'DINNER', 'QAM', 'QHD', 'QHS', 'QPM') THEN 1
      -- every other day
      WHEN ph.frequency IN ('Q48H', 'EVERY OTHER DAY') THEN 0.5
      WHEN ph.frequency IN ('QMOWEFR', 'QTUTHSA', '3X/WEEK') THEN 0.42
      WHEN ph.frequency IN ('Q72H') THEN 0.33
      -- fall back on doses if necessary
      ELSE COALESCE(pr.doses_per_24_hrs, 1) END
    AS doses_per_24_hrs
  -- misc info used to identify drug
  , drug
  , gsn, ndc
FROM `physionet-data.mimic_hosp.prescriptions` pr
LEFT JOIN `physionet-data.mimic_hosp.pharmacy` ph
  ON pr.pharmacy_id = ph.pharmacy_id
WHERE pr.drug IN
(

    'Heparin',
    'Heparin Sodium',
    -- '5% Dextrose',
    -- 'Heparin Flush (10 units/ml)',
    -- 'Heparin Dwell (1000 Units/mL)',
    -- 'Heparin Flush (100 units/ml)',
    'Heparin Pres. Free',
    -- 'Heparin (Hemodialysis)',
    -- 'Heparin (CRRT Machine Priming)',
    -- 'Heparin Flush (1000 units/mL)',
    -- 'Heparin Flush (10 units/mL)',
    -- 'Heparin Flush (1 unit/mL)',
    'Heparin Sodium',
    -- 'Heparin PF (0.5 Units/mL)',
    -- 'Heparin Desensitization',
    -- 'Heparin (Impella)',
    -- 'Heparin Dwell (1000 Units/mL)',
    -- 'Heparin Flush (1000 units/mL)',
    'Heparin (via Anti-Xa Monitoring)',
    'Heparin',
    -- 'NS',
    'Heparin Sodium',
    -- 'Heparin (IABP)',
    'Heparin',
    'Heparin Pres. Free',
    'Heparin',
    -- 'Heparin INTRAPERITONEAL',
    'Heparin ',
    'Heparin Sodium',
    -- 'Heparin CRRT',
    -- 'Heparin Flush CRRT (5000 Units/mL)',
    'Heparin',
    -- 'Heparin (IABP)',
    'Heparin Sodium'
)
;