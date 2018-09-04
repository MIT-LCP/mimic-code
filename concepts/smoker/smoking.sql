--Code to tell whether a person was a smoker         
WITH terms AS (
                 SELECT ne.subject_id,
                        CASE
                            WHEN ne.text ~* '(never|not|not a|none|non|no|no history of|no h\/o of|denies|denies any|negative)[\s-]?(smoke|smoking|tabacco|tobacco|cigar|cigs)'::text OR ne.text ~* '(smoke|smoking|tabacco|tobacco|tabacco abuse|tobacco abuse|cigs|cigarettes):[\s]?(no|never|denies|negative)'::text OR ne.text ~* 'smoked no \[x\]|no etoh, tobacco|not drink alcohol or smoke|not drink or smoke|absence of current tobacco use|absence of tobacco use'::text THEN 0 --means no smoker
                            WHEN ne.text ~* '(smoke|smoking|tabacco|tobacco|cigar|cigs|marijuana|nicotine)'::text THEN 1 --means smoker
                            ELSE 2 --means unknown
                        END AS smoking
                   FROM mimiciii.noteevents ne
                )
        SELECT terms.subject_id
        ,min(terms.smoking) AS smoking --chooses smoker,no smoker, unknown; in that order
        FROM terms
        GROUP BY subject_id
        ORDER BY subject_id

