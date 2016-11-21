-- This code extracts structured data from echocardiographies
-- You can join it to the text notes using ROW_ID
-- Just note that ROW_ID will differ across versions of MIMIC-III.

DROP MATERIALIZED VIEW IF EXISTS ECHODATA CASCADE;
CREATE MATERIALIZED VIEW ECHODATA AS
select ROW_ID
  , subject_id, hadm_id
  , chartdate

  -- charttime is always null for echoes..
  -- however, the time is available in the echo text, e.g.:
  -- , substring(ne.text, 'Date/Time: [\[\]0-9*-]+ at ([0-9:]+)') as TIMESTAMP
  -- we can therefore impute it and re-create charttime
  , cast(to_timestamp( (to_char( chartdate, 'DD-MM-YYYY' ) || substring(ne.text, 'Date/Time: [\[\]0-9*-]+ at ([0-9:]+)')),
            'DD-MM-YYYYHH24:MI') as timestamp without time zone)
    as charttime

  -- explanation of below substring:
  --  'Indication: ' - matched verbatim
  --  (.*?) - match any character
  --  \n - the end of the line
  -- substring only returns the item in ()s
  -- note: the '?' makes it non-greedy. if you exclude it, it matches until it reaches the *last* \n

  , substring(ne.text, 'Indication: (.*?)\n') as Indication

  -- sometimes numeric values contain de-id text, e.g. [** Numeric Identifier **]
  -- this removes that text
  , case
      when substring(ne.text, 'Height: \(in\) (.*?)\n') like '%*%'
        then null
      else cast(substring(ne.text, 'Height: \(in\) (.*?)\n') as numeric)
    end as Height

  , case
      when substring(ne.text, 'Weight \(lb\): (.*?)\n') like '%*%'
        then null
      else cast(substring(ne.text, 'Weight \(lb\): (.*?)\n') as numeric)
    end as Weight

  , case
      when substring(ne.text, 'BSA \(m2\): (.*?) m2\n') like '%*%'
        then null
      else cast(substring(ne.text, 'BSA \(m2\): (.*?) m2\n') as numeric)
    end as BSA -- ends in 'm2'

  , substring(ne.text, 'BP \(mm Hg\): (.*?)\n') as BP -- Sys/Dias

  , case
      when substring(ne.text, 'BP \(mm Hg\): ([0-9]+)/[0-9]+?\n') like '%*%'
        then null
      else cast(substring(ne.text, 'BP \(mm Hg\): ([0-9]+)/[0-9]+?\n') as numeric)
    end as BPSys -- first part of fraction

  , case
      when substring(ne.text, 'BP \(mm Hg\): [0-9]+/([0-9]+?)\n') like '%*%'
        then null
      else cast(substring(ne.text, 'BP \(mm Hg\): [0-9]+/([0-9]+?)\n') as numeric)
    end as BPDias -- second part of fraction

  , case
      when substring(ne.text, 'HR \(bpm\): ([0-9]+?)\n') like '%*%'
        then null
      else cast(substring(ne.text, 'HR \(bpm\): ([0-9]+?)\n') as numeric)
    end as HR

  , substring(ne.text, 'Status: (.*?)\n') as Status
  , substring(ne.text, 'Test: (.*?)\n') as Test
  , substring(ne.text, 'Doppler: (.*?)\n') as Doppler
  , substring(ne.text, 'Contrast: (.*?)\n') as Contrast
  , substring(ne.text, 'Technical Quality: (.*?)\n') as TechnicalQuality
from noteevents ne
where category = 'Echo';
