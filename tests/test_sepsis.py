import pandas as pd
from pandas.io import gbq


def test_sepsis3_one_row_per_stay_id(dataset, project_id):
    """Verifies one stay_id per row of sepsis-3"""
    query = f"""
    SELECT
    COUNT(*) AS n
    FROM
    (
        SELECT stay_id FROM {dataset}.sepsis3 GROUP BY 1 HAVING COUNT(*) > 1
    ) s    
    """
    df = gbq.read_gbq(query, project_id=project_id, dialect="standard")
    n = df.loc[0, 'n']
    assert n == 0, 'sepsis-3 table has more than one row per stay_id'
