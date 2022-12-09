import pandas as pd
from pandas.io import gbq

def test_gcs_first_day_calculated_correctly(dataset, project_id):
    """Verifies GCS first day values are calculated correctly."""
    # almost every individual should have a GCS first day
    query = f"""
    SELECT COUNT(*) AS n, COUNT(g.gcs) AS n_gcs
    FROM  {dataset}.first_day_gcs g
    """
    df = gbq.read_gbq(query, project_id=project_id, dialect="standard")
    n, n_gcs = df.iloc[0, 0], df.iloc[0, 1]
    frac = float(n_gcs) / n * 100.0
    assert frac > 98, 'less than 98%% of stays have a first day GCS'


    # verify a subset of values
    known_values = {
        37535507: {'gcs': 13, 'gcs_motor': 4, 'gcs_verbal': None, 'gcs_eyes': None},
        38852627: {'gcs': None, 'gcs_motor': None, 'gcs_verbal': None, 'gcs_eyes': None},
        32435143: {'gcs': 8, 'gcs_motor': 5, 'gcs_verbal': 1, 'gcs_eyes': 2},
    }
    query = f"""
    SELECT g.stay_id
    , g.gcs
    , g.gcs_motor
    , g.gcs_verbal
    , g.gcs_eyes
    , g.gcs_unable
    FROM  {dataset}.first_day_gcs g
    WHERE g.stay_id IN
    (
        {','.join([str(x) for x in known_values.keys()])}
    )
    """
    df = gbq.read_gbq(query, project_id=project_id, dialect="standard")
    df = df.sort_values(['stay_id']).set_index('stay_id')
    for stay_id, row in df.iterrows():
        for col, expected_val in known_values[stay_id].items():
            assert row[col] == expected_val, f'first_day_gcs {col} value incorrect for stay_id={stay_id}'
