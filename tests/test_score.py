import pandas as pd
from pandas.io import gbq


def test_sofa_one_row_per_hour(dataset, project_id):
    """Verifies one row per hour of the SOFA table"""
    query = f"""
    SELECT
    COUNT(*) AS n
    FROM
    (
        SELECT stay_id, hr FROM {dataset}.sofa GROUP BY 1, 2 HAVING COUNT(*) > 1
    ) s    
    """
    df = gbq.read_gbq(query, project_id=project_id, dialect="standard")
    n = df.loc[0, 'n']
    assert n == 0, 'sofa table has more than one row per (stay_id, hr)'
