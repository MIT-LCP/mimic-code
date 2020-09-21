-- ------------------------------------------------------------------
-- Title: Extraction of insulin events.
-- Description: This scripts extracts all the insulin events from 
--  INPUTEVENTS_MV table. It furthers differentiates into types of 
--  insulin: Short-acting (or regular), intermediate-acting and long-
--  acting. This query also distinguish the administration routes: 
--  infusion, bolus pushes and bolus injections.
-- ------------------------------------------------------------------

SELECT atr.SUBJECT_ID, atr.HADM_ID, atr.ICUSTAY_ID
    , CAST(atr.starttime AS TIMESTAMP) AS STARTTIME
    , CAST(atr.endtime AS TIMESTAMP) AS ENDTIME
    , atr.AMOUNT, atr.RATE, atr.ORIGINALRATE, atr.ITEMID, atr.ORDERCATEGORYNAME
    , (CASE
        WHEN itemid=223257 THEN 'Intermediate' --'Ins7030'
        WHEN itemid=223258 THEN 'Short'        --'InsRegular'
        WHEN itemid=223259 THEN 'Intermediate' --'InsNPH'
        WHEN itemid=223260 THEN 'Long'         --'InsGlargine'
        WHEN itemid=223261 THEN 'Intermediate' --'InsHum7525'
        WHEN itemid=223262 THEN 'Short'        --'InsHum'
        ELSE null END) AS InsulinType
    , (CASE
        WHEN UPPER(ORDERCATEGORYNAME) LIKE '%NON IV%' THEN 'BOLUS_INYECTION'
        WHEN UPPER(ORDERCATEGORYNAME) LIKE '%MED BOLUS%' THEN 'BOLUS_PUSH'
        WHEN ORDERCATEGORYNAME IN ('01-Drips','12-Parenteral Nutrition') THEN 'INFUSION'
        ELSE null END) AS InsulinAdmin
    , (CASE WHEN STATUSDESCRIPTION IN ('Paused','Stopped') THEN 1 ELSE 0 END) AS INFXSTOP
FROM `physionet-data.mimiciii_clinical.inputevents_mv` atr								
WHERE itemid IN (223257   -- [Ins7030]     - Insulin 70/30 
                , 223258  -- [InsRegular]  - Insulin Regular
                , 223259  -- [InsNPH]      - Insulin NPH
                , 223260  -- [InsGlargine] - Insulin Glargine
                , 223261  -- [nsHum7525]   - Insulin Humalog 75/25
                , 223262) -- [InsHum]      - Insulin Humalog
    --Exclude invalid measures that were rewritten
    AND atr.statusdescription != 'Rewritten'
GROUP BY atr.subject_id, atr.hadm_id, atr.icustay_id, atr.starttime
    , atr.endtime, atr.ITEMID, atr.ordercategoryname
    , atr.statusdescription, atr.amount, atr.rate, atr.ORIGINALRATE
ORDER BY atr.icustay_id, atr.subject_id, atr.hadm_id, atr.starttime
