import os
from collections import namedtuple

import pytest
from google.cloud import bigquery

# add service account key to allow querying against BigQuery
dir_path = os.path.dirname(os.path.realpath(__file__))
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = os.path.join(
    dir_path, "key.json"
)


@pytest.fixture(scope="session")
def dataset():
    """
    Return the name of the dataset.
    """
    return 'mimic_derived'


@pytest.fixture(scope="session")
def dataset_testing():
    """
    Return the name of the dataset.
    """
    return 'mimic_derived_testing'


@pytest.fixture(scope="session")
def project_id():
    """
    Return the name of the BigQuery project used.
    """
    return 'physionet-data'
