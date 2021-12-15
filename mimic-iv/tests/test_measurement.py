import pandas as pd
from pandas.io import gbq


def test_d_labitems_itemid_for_bg(dataset, project_id):
    known_itemid = {
        50801: "Alveolar-arterial Gradient",
        50802: "Base Excess",
        50803: "Calculated Bicarbonate, Whole Blood",
        50804: "Calculated Total CO2",
        50805: "Carboxyhemoglobin",
        50806: "Chloride, Whole Blood",
        50807: "Comments",
        50808: "Free Calcium",
        50809: "Glucose",
        50810: "Hematocrit, Calculated",
        50811: "Hemoglobin",
        50813: "Lactate",
        52030: "Lithium",
        50814: "Methemoglobin",
        50815: "O2 Flow",
        50816: "Oxygen",
        50817: "Oxygen Saturation",
        50818: "pCO2",
        50819: "PEEP",
        50820: "pH",
        50821: "pO2",
        50822: "Potassium, Whole Blood",
        50823: "Required O2",
        50824: "Sodium, Whole Blood",
        50825: "Temperature",
        52033: "Specimen Type"
    }

    query = f"""
        select itemid, label
        FROM mimic_hosp.d_labitems
        WHERE itemid IN
        (
            {", ".join([str(x) for x in known_itemid.keys()])}
        )
    """
    df = gbq.read_gbq(query, project_id=project_id, dialect="standard")
    observed = df.set_index('itemid')['label'].to_dict()

    for itemid, label in known_itemid.items():
        assert observed[itemid] == label, f'mismatch in lab itemid/concept for {itemid}'


def test_common_bg_exist(dataset, project_id):
    """Verifies common blood gases occur > 50% of the time"""
    query = f"""
    SELECT
    COUNT(*) AS n
    , COUNT(specimen) AS specimen
    , COUNT(po2) AS po2
    , COUNT(pco2) AS pco2
    , COUNT(ph) AS ph
    , COUNT(baseexcess) AS baseexcess
    FROM {dataset}.bg
    """
    df = gbq.read_gbq(query, project_id=project_id, dialect="standard")
    n = df.loc[0, 'n']
    assert n > 0, 'bg has no observations'

    missing_observations = {}
    for c in df:
        if (df.loc[0, c] / n) < 0.5:
            missing_observations[c] = df.loc[0, c]

    assert len(missing_observations) == 0, f'columns in bg missing data'
