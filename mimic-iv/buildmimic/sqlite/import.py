from argparse import ArgumentParser
import json
import os
from pathlib import Path
import sqlite3
import sys
import typing as t
import pandas as pd

DATABASE_NAME = "mimic4.db"
THRESHOLD_SIZE = 5 * 10**7
CHUNKSIZE = 10**6

_MIMIC_TABLES = (
    # hospital EHR derived tables
    'admissions',
    'd_hcpcs',
    'd_icd_diagnoses',
    'd_icd_procedures',
    'd_labitems',
    'diagnoses_icd',
    'drgcodes',
    'emar',
    'emar_detail',
    'hcpcsevents',
    'labevents',
    'microbiologyevents',
    'omr',
    'patients',
    'pharmacy',
    'poe',
    'poe_detail',
    'prescriptions',
    'procedures_icd',
    'provider',
    'services',
    'transfers',
    # ICU derived tables
    'caregiver',
    'chartevents',
    'd_items',
    'datetimeevents',
    'icustays',
    'ingredientevents',
    'inputevents',
    'outputevents',
    'procedureevents',
)

def process_dataframe(df: pd.DataFrame, subjects: t.Optional[t.List[int]] = None) -> pd.DataFrame:
    for c in df.columns:
        if c.endswith('time') or c.endswith('date'):
            df[c] = pd.to_datetime(df[c], format='ISO8601')
    
    if subjects is not None and 'subject_id' in df:
        df = df.loc[df['subject_id'].isin(subjects)]
    
    return df

def main():
    argparser = ArgumentParser()
    argparser.add_argument(
        '--limit', type=int, default=0,
        help='Restrict the database to the first N subject_id.'
    )
    argparser.add_argument(
        '--data_dir', type=str, default='.',
        help='Path to the directory containing the MIMIC-IV CSV files.'
    )
    argparser.add_argument(
        '--overwrite', action='store_true',
        help='Overwrite existing mimic4.db file.'
    )
    args = argparser.parse_args()

    # validate that we can find all the files
    data_dir = Path(args.data_dir).resolve()
    data_files = list(data_dir.rglob('**/*.csv*'))
    if not data_files:
        print(f"No CSV files found in {data_dir}")
        sys.exit()

    # remove suffixes from data files -> also lower case tablenames
    # creates index aligned array for data files
    tablenames = []
    for f in data_files:
        while f.suffix.lower() in {'.csv', '.gz'}:
            f = f.with_suffix('')
        tablenames.append(f.stem.lower())

    # check that all the expected tables are present
    expected_tables = set([t for t in tablenames])
    missing_tables = set(_MIMIC_TABLES) - expected_tables
    if missing_tables:
        print(expected_tables)
        print(f"Missing tables: {missing_tables}")
        sys.exit()

    # subselect to only tables in the above list
    ignored_files = set([f for f, t in zip(data_files, tablenames) if t not in _MIMIC_TABLES])
    data_files = [f for f, t in zip(data_files, tablenames) if t in _MIMIC_TABLES]
    tablenames = [t for t in tablenames if t in _MIMIC_TABLES]
    print(f"Importing {len(tablenames)} files.")

    if ignored_files:
        print(f"Ignoring {len(ignored_files)} files: {ignored_files}")

    pt = None
    subjects = None
    if args.limit > 0:
        for f in data_files:
            if 'patients' in f.name:
                pt = pd.read_csv(f)
                break
        if pt is None:
            raise FileNotFoundError('Unable to find a patients file in current folder.')

        pt = pt[['subject_id']].sort_values('subject_id').head(args.limit)
        subjects = set(sorted(pt['subject_id'].tolist())[:args.limit])
        print(f'Limiting to {len(subjects)} subjects.')

    if os.path.exists(DATABASE_NAME):
        if args.overwrite:
            os.remove(DATABASE_NAME)
        else:
            msg = "File {} already exists.".format(DATABASE_NAME)
            print(msg)
            sys.exit()

    # For a subset of columns, we specify the data types to ensure
    # pandas loads the data correctly.
    mimic_dtypes = {
        "subject_id": pd.Int64Dtype(),
        "hadm_id": pd.Int64Dtype(),
        "stay_id": pd.Int64Dtype(),
        "caregiver_id": pd.Int64Dtype(),
        "provider_id": str,
        "category": str, # d_hcpcs
        "parent_field_ordinal": str,
        "pharmacy_id": pd.Int64Dtype(),
        "emar_seq": pd.Int64Dtype(),
        "poe_seq": pd.Int64Dtype(),
        "ndc": str,
        "doses_per_24_hrs": pd.Int64Dtype(),
        "drg_code": str,
        "org_itemid": pd.Int64Dtype(),
        "isolate_num": pd.Int64Dtype(),
        "quantity": str,
        "ab_itemid": pd.Int64Dtype(),
        "dilution_text": str,
        "warning": pd.Int64Dtype(),
        "valuenum": float,
    }

    row_counts = {t: 0 for t in set(tablenames) | set(_MIMIC_TABLES)}
    with sqlite3.Connection(DATABASE_NAME) as connection:
        for i, f in enumerate(data_files):
            tablename = tablenames[i]
            print("Starting processing {}".format(tablename), end='.. ')
            if os.path.getsize(f) < THRESHOLD_SIZE:
                df = pd.read_csv(f, dtype=mimic_dtypes)
                df = process_dataframe(df, subjects=subjects)
                df.to_sql(tablename, connection, index=False)
                row_counts[tablename] += len(df)
            else:
                # If the file is too large, let's do the work in chunks
                for chunk in pd.read_csv(f, chunksize=CHUNKSIZE, low_memory=False, dtype=mimic_dtypes):
                    chunk = process_dataframe(chunk)
                    chunk.to_sql(tablename, connection, if_exists="append", index=False)
                    row_counts[tablename] += len(chunk)
            print("done!")

    print("Should be all done! Row counts of loaded data:\n")

    print(json.dumps(row_counts, indent=2))



if __name__ == '__main__':
    main()