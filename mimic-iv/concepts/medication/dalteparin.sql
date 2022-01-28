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
      -- once is set to be equiv to daily
      WHEN REGEXP_CONTAINS(ph.frequency, '^(1X|X1|ASDIR|ONCE)') THEN 1
      -- daily
      WHEN REGEXP_CONTAINS(ph.frequency, '^DAILY') THEN 1
      WHEN ph.frequency IN ('Q24H', 'Q 24H', 'HS', 'DINNER', 'QAM', 'QHD', 'QHS', 'QPM') THEN 1
      -- twice a day (BID)
      WHEN REGEXP_CONTAINS(ph.frequency, '^BID') THEN 0.5 -- BID
      WHEN ph.frequency IN ('Q12H', 'Q 12H') THEN 0.5 -- BID
      WHEN ph.frequency IN ('QMOWEFR', 'QTUTHSA') THEN 0.5
      -- fall back on doses if necessary
      ELSE COALESCE(pr.doses_per_24_hrs, 1) END
    AS doses_per_24_hrs
  -- misc info used to identify drug
  , drug
  , gsn, ndc
FROM `physionet-data.mimic_hosp.prescriptions` pr
LEFT JOIN `physionet-data.mimic_hosp.pharmacy` ph
  ON pr.pharmacy_id = ph.pharmacy_id
  AND pr.drug = ph.medication
WHERE pr.drug IN
(
'Dalteparin',
'Fragmin (Dalteparin)',
'INV Dalteparin',
'INV dalteparin',
'INV-*NF*-Dalteparin',
'INV-Dalteparin',
'dalt',
'dalteparin',
'dalteparin (porcine)',
'Fragmin'
);
