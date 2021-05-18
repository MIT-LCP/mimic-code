import os
import subprocess
import hashlib
import urllib.request
from urllib.request import urlretrieve

import pandas as pd


def get_sha256(fn):
    # calculate sha256 of downloaded file
    sha256 = hashlib.sha256()
    with open(fn, 'rb') as fp:
        while True:
            chunk = fp.read(sha256.block_size)
            if not chunk:
                break
            sha256.update(chunk)

    return sha256.hexdigest()


def test_download_mimic_demo(mimic_demo_path, mimic_demo_url, mimic_tables):
    """
    Download the MIMIC demo to a local folder.
    """
    # download the SHA256 sums
    r = urllib.request.urlopen(f'{mimic_demo_url}SHA256SUMS.txt')
    sha_values = r.read().decode('utf-8').rstrip('\n')
    sha_values = [x.split(' ') for x in sha_values.split('\n')]

    sha_fn = [x[1] for x in sha_values]
    sha_values = [x[0] for x in sha_values]

    # download each table
    for table in mimic_tables:
        # ensure we have a reference SHA-256 sum
        assert f'{table}.csv' in sha_fn
        idx = sha_fn.index(f'{table}.csv')
        sha_ref = sha_values[idx]

        fn = os.path.join(mimic_demo_path, f'{table}.csv')

        # don't download the file if it already exists
        if os.path.exists(fn):
            fn_sha = get_sha256(fn)
            if fn_sha == sha_ref:
                # no need to download again!
                continue

        # download the file
        urlretrieve(f'{mimic_demo_url}{table}.csv', fn)

        # check we downloaded the file properly
        fn_sha = get_sha256(fn)
        assert fn_sha == sha_ref


def test_build_mimic_demo(mimic_demo_path, mimic_db_params, create_mimic_db):
    """
    Try to build MIMIC-III demo using the make file and the downloaded data.
    """
    # call make files to create MIMIC user and build database
    build_path = os.path.join(os.getcwd(), 'mimic-iii', 'buildmimic',
                              'postgres/')

    dbname = mimic_db_params['name']
    dbpass = mimic_db_params['password']
    dbuser = mimic_db_params['user']
    dbschema = mimic_db_params['schema']
    dbhost = mimic_db_params['host']

    # Create mimic user
    # make_user = f'make create-user DBNAME={dbname}'
    # subprocess.call(make_user, shell=True, cwd=build_path)

    # Build MIMIC demo
    make_mimic = (
        f'make mimic datadir={mimic_demo_path} '
        f'DBNAME={dbname} DBUSER={dbuser} DBPASS={dbpass} '
        f'DBSCHEMA={dbschema} DBHOST={dbhost}'
    )
    subprocess.check_output(make_mimic, shell=True, cwd=build_path)


# The MIMIC test db has been created by this point
# Add unit tests below


def test_db_con(mimic_con):
    """
    Check we can select from the database.
    """
    test_query = "SELECT 'another hello world';"
    hello_world = pd.read_sql_query(test_query, mimic_con)
    assert hello_world.values[0][0] == 'another hello world'


def test_select_min_subject_id(mimic_con, mimic_schema):
    """
    Minimum subject_id in the demo is 10006
    """
    test_query = f"""
    SELECT min(subject_id)
    FROM {mimic_schema}.patients;
    """

    min_id = pd.read_sql_query(test_query, mimic_con)
    assert min_id.values[0][0] == 10006


# --------------------------------------------------
# Run a series of checks to ensure ITEMIDs are valid
# All checks should return 0.
# --------------------------------------------------
def test_itemids_in_inputevents_cv_are_shifted(mimic_con, mimic_schema):
    """
    Number of ITEMIDs which were erroneously left as original value
    """
    query = f"""
    SELECT COUNT(*) FROM {mimic_schema}.inputevents_cv
    WHERE itemid < 30000;
    """

    queryresult = pd.read_sql_query(query, mimic_con)
    assert queryresult.values[0][0] == 0


def test_itemids_in_inputevents_mv_are_shifted(mimic_con, mimic_schema):
    """
    Number of ITEMIDs which were erroneously left as original value
    """
    query = f"""
    SELECT COUNT(*) FROM {mimic_schema}.inputevents_mv
    WHERE itemid < 220000;
    """

    queryresult = pd.read_sql_query(query, mimic_con)
    assert queryresult.values[0][0] == 0


def test_itemids_in_outputevents_are_shifted(mimic_con, mimic_schema):
    """
    Number of ITEMIDs which were erroneously left as original value
    """
    query = f"""
    SELECT COUNT(*) FROM {mimic_schema}.outputevents
    WHERE itemid < 30000;
    """

    queryresult = pd.read_sql_query(query, mimic_con)
    assert queryresult.values[0][0] == 0


def test_itemids_in_inputevents_cv_are_in_range(mimic_con, mimic_schema):
    """
    Number of ITEMIDs which are above the allowable range
    """
    query = f"""
    SELECT COUNT(*) FROM {mimic_schema}.inputevents_cv
    WHERE itemid > 50000;
    """

    queryresult = pd.read_sql_query(query, mimic_con)
    assert queryresult.values[0][0] == 0


def test_itemids_in_outputevents_are_in_range(mimic_con, mimic_schema):
    """
    Number of ITEMIDs which are not in the allowable range
    """
    query = f"""
    SELECT COUNT(*) FROM {mimic_schema}.outputevents
    WHERE itemid > 50000 AND itemid < 220000;
    """

    queryresult = pd.read_sql_query(query, mimic_con)
    assert queryresult.values[0][0] == 0


def test_itemids_in_chartevents_are_in_range(mimic_con, mimic_schema):
    """
    Number of ITEMIDs which are not in the allowable range
    """
    query = f"""
    SELECT COUNT(*) FROM {mimic_schema}.chartevents
    WHERE itemid > 20000 AND itemid < 220000;
    """

    queryresult = pd.read_sql_query(query, mimic_con)
    assert queryresult.values[0][0] == 0


def test_itemids_in_procedureevents_mv_are_in_range(mimic_con, mimic_schema):
    """
    Number of ITEMIDs which are not in the allowable range
    """
    query = f"""
    SELECT COUNT(*) FROM {mimic_schema}.procedureevents_mv
    WHERE itemid < 220000;
    """

    queryresult = pd.read_sql_query(query, mimic_con)
    assert queryresult.values[0][0] == 0


def test_itemids_in_labevents_are_in_range(mimic_con, mimic_schema):
    """
    Number of ITEMIDs which are not in the allowable range
    """
    query = f"""
    SELECT COUNT(*) FROM {mimic_schema}.labevents
    WHERE itemid < 50000 OR itemid > 60000;
    """

    queryresult = pd.read_sql_query(query, mimic_con)
    assert queryresult.values[0][0] == 0


def test_itemids_in_microbiologyevents_are_in_range(mimic_con, mimic_schema):
    """
    Number of ITEMIDs which are not in the allowable range
    """
    query = f"""
    SELECT COUNT(*) FROM {mimic_schema}.microbiologyevents
    WHERE SPEC_ITEMID < 70000 OR SPEC_ITEMID > 80000
    OR ORG_ITEMID < 80000 OR ORG_ITEMID > 90000
    OR AB_ITEMID < 90000 OR AB_ITEMID > 100000;
    """

    queryresult = pd.read_sql_query(query, mimic_con)
    assert queryresult.values[0][0] == 0
