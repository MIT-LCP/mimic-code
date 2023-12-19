-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.invasive_line; CREATE TABLE mimiciv_derived.invasive_line AS
/* as a final step, combine any similar terms together */
/* metavision */
WITH mv AS (
  SELECT
    stay_id, /* since metavision separates lines using itemid, */ /* we can use it as the line number */
    mv.itemid AS line_number,
    di.label AS line_type,
    mv.location AS line_site,
    starttime,
    endtime
  FROM mimiciv_icu.procedureevents AS mv
  INNER JOIN mimiciv_icu.d_items AS di
    ON mv.itemid = di.itemid
  WHERE
    mv.itemid IN (227719 /* AVA Line */, 225752 /* Arterial Line */, 224269 /* CCO PAC */, 224267 /* Cordis/Introducer */, 224270 /* Dialysis Catheter */, 224272 /* IABP line */, 226124 /* ICP Catheter */, 228169 /* Impella Line */, 225202 /* Indwelling Port (PortaCath) */, 228286 /* Intraosseous Device */, 225204 /* Midline */, 224263 /* Multi Lumen */, 224560 /* PA Catheter */, 224264 /* PICC Line */, 225203 /* Pheresis Catheter */, 224273 /* Presep Catheter */, 225789 /* Sheath */, 225761 /* Sheath Insertion */, 228201 /* Tandem Heart Access Line */, 228202 /* Tandem Heart Return Line */, 224268 /* Trauma line */, 225199 /* Triple Introducer */, 225315 /* Tunneled (Hickman) Line */, 225205 /* RIC */)
)
SELECT
  stay_id,
  CASE
    WHEN line_type IN ('Arterial Line', 'A-Line')
    THEN 'Arterial'
    WHEN line_type IN ('CCO PA Line', 'CCO PAC')
    THEN 'Continuous Cardiac Output PA'
    WHEN line_type IN ('Dialysis Catheter', 'Dialysis Line')
    THEN 'Dialysis'
    WHEN line_type IN ('Hickman', 'Tunneled (Hickman) Line')
    THEN 'Hickman'
    WHEN line_type IN ('IABP', 'IABP line')
    THEN 'IABP'
    WHEN line_type IN ('Multi Lumen', 'Multi-lumen')
    THEN 'Multi Lumen'
    WHEN line_type IN ('PA Catheter', 'PA line')
    THEN 'PA'
    WHEN line_type IN ('PICC Line', 'PICC line')
    THEN 'PICC'
    WHEN line_type IN ('Pre-Sep Catheter', 'Presep Catheter')
    THEN 'Pre-Sep'
    WHEN line_type IN ('Trauma Line', 'Trauma line')
    THEN 'Trauma'
    WHEN line_type IN ('Triple Introducer', 'TripleIntroducer')
    THEN 'Triple Introducer'
    WHEN line_type IN ('Portacath', 'Indwelling Port (PortaCath)')
    THEN 'Portacath'
    ELSE line_type
  END AS line_type,
  CASE
    WHEN line_site IN ('Left Antecub', 'Left Antecube')
    THEN 'Left Antecube'
    WHEN line_site IN ('Left Axilla', 'Left Axilla.')
    THEN 'Left Axilla'
    WHEN line_site IN ('Left Brachial', 'Left Brachial.')
    THEN 'Left Brachial'
    WHEN line_site IN ('Left Femoral', 'Left Femoral.')
    THEN 'Left Femoral'
    WHEN line_site IN ('Right Antecub', 'Right Antecube')
    THEN 'Right Antecube'
    WHEN line_site IN ('Right Axilla', 'Right Axilla.')
    THEN 'Right Axilla'
    WHEN line_site IN ('Right Brachial', 'Right Brachial.')
    THEN 'Right Brachial'
    WHEN line_site IN ('Right Femoral', 'Right Femoral.')
    THEN 'Right Femoral'
    ELSE line_site
  END AS line_site,
  starttime,
  endtime
FROM mv
ORDER BY
  stay_id NULLS FIRST,
  starttime NULLS FIRST,
  line_type NULLS FIRST,
  line_site NULLS FIRST