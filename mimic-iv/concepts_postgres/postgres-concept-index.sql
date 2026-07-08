----------------------------------------------------
----------------------------------------------------
-- Indexes for the mimiciv_derived concept tables --
----------------------------------------------------
----------------------------------------------------

-- The score/firstday concepts join hourly windows against the measurement
-- and medication concepts using (stay_id/hadm_id/subject_id, charttime)
-- range predicates. Without these indexes PostgreSQL falls back to
-- merge/hash joins that materialise hundreds of millions of intermediate
-- rows. With them the joins become per-hour index lookups and the same
-- scripts run in minutes.

SET search_path TO mimiciv_derived;

DROP INDEX IF EXISTS icustay_hourly_idx01;
CREATE INDEX icustay_hourly_idx01
  ON icustay_hourly (stay_id);

-- measurement concepts joined on stay_id + charttime

DROP INDEX IF EXISTS vitalsign_idx01;
CREATE INDEX vitalsign_idx01
  ON vitalsign (stay_id, charttime);

DROP INDEX IF EXISTS gcs_idx01;
CREATE INDEX gcs_idx01
  ON gcs (stay_id, charttime);

DROP INDEX IF EXISTS urine_output_rate_idx01;
CREATE INDEX urine_output_rate_idx01
  ON urine_output_rate (stay_id, charttime);

-- measurement concepts joined on hadm_id + charttime

DROP INDEX IF EXISTS chemistry_idx01;
CREATE INDEX chemistry_idx01
  ON chemistry (hadm_id, charttime);

DROP INDEX IF EXISTS complete_blood_count_idx01;
CREATE INDEX complete_blood_count_idx01
  ON complete_blood_count (hadm_id, charttime);

DROP INDEX IF EXISTS enzyme_idx01;
CREATE INDEX enzyme_idx01
  ON enzyme (hadm_id, charttime);

-- blood gas joined on subject_id + charttime

DROP INDEX IF EXISTS bg_idx01;
CREATE INDEX bg_idx01
  ON bg (subject_id, charttime);

-- ventilation and vasopressor concepts joined on stay_id + starttime/endtime

DROP INDEX IF EXISTS ventilation_idx01;
CREATE INDEX ventilation_idx01
  ON ventilation (stay_id, starttime, endtime);

DROP INDEX IF EXISTS epinephrine_idx01;
CREATE INDEX epinephrine_idx01
  ON epinephrine (stay_id, starttime, endtime);

DROP INDEX IF EXISTS norepinephrine_idx01;
CREATE INDEX norepinephrine_idx01
  ON norepinephrine (stay_id, starttime, endtime);

DROP INDEX IF EXISTS dopamine_idx01;
CREATE INDEX dopamine_idx01
  ON dopamine (stay_id, starttime, endtime);

DROP INDEX IF EXISTS dobutamine_idx01;
CREATE INDEX dobutamine_idx01
  ON dobutamine (stay_id, starttime, endtime);
