import pandas as pd
from pandas.io import gbq

def test_tables_have_data(dataset, project_id, concepts):
    """Verifies each table has data."""

    for folder, concept_list in concepts.items():
        for concept_name in concept_list:
            query = f"""
            SELECT *
            FROM {dataset}.{concept_name}
            LIMIT 5
            """
            df = gbq.read_gbq(query, project_id=project_id, dialect="standard")
            assert df.shape[0] > 0, f'did not find table for {folder}.{concept_name}'
