import os
from collections import namedtuple
from pathlib import Path

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

@pytest.fixture(scope="session")
def concept_folders():
    """
    Returns the folders containing concepts.
    """
    return ['comorbidity', 'demographics', 'measurement', 'medication', 'organfailure', 'treatment', 'score', 'sepsis', 'firstday']

@pytest.fixture(scope="session")
def concepts(concept_folders):
    """
    Returns all concepts which should be generated.
    """
    concepts = {}
    current_dir = Path(__file__).parent
    concept_dir = current_dir / '../concepts'
    for folder in concept_folders:
        files = os.listdir(concept_dir / folder)
        # add list of the concepts in this folder to the dict
        concepts[folder] = [f[:-4] for f in files if f.endswith('.sql')]

    return concepts
