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


def test_gcs_score_calculated_correctly(dataset, project_id):
    """Verifies common blood gases occur > 50% of the time"""
    # has verbal prev of 1 -> 11365767, 30015010, 2154-07-25T20:00:00
    # has verbal prev of 0 -> 13182319, 30159144, 2161-06-19T00:16:00
    query = f"""
    SELECT g.stay_id
    , g.charttime
    , g.gcs
    , g.gcs_motor
    , g.gcs_verbal
    , g.gcs_eyes
    , g.gcs_unable
    , gcs_v.valuenum AS gcs_verbal_numeric
    , gcs_v.value AS gcs_verbal_text
    FROM  {dataset}.gcs g
    LEFT JOIN (
        SELECT stay_id, charttime, value, valuenum
        FROM `physionet-data.mimiciv_icu.chartevents`
        WHERE itemid = 223900 AND stay_id IN (30015010, 30159144)
    ) gcs_v
        ON g.stay_id = gcs_v.stay_id
        AND g.charttime = gcs_v.charttime
    WHERE g.stay_id IN
    (
        30015010, -- subject_id: 11365767
        30159144 -- subject_id: 13182319
    )
    """
    df = gbq.read_gbq(query, project_id=project_id, dialect="standard")
    df = df.sort_values(['stay_id', 'charttime'])
    df['charttime'] = pd.to_datetime(df['charttime'])
    df['charttime_lag'] = df.groupby('stay_id')['charttime'].shift(1)
    df['gcs_verbal_text_lag'] = df.groupby('stay_id')['gcs_verbal_text'].shift(1)
    df['gcs_verbal_numeric_lag'] = df.groupby('stay_id')['gcs_verbal_numeric'].shift(1)

    idxTime = (df['charttime'] - df['charttime_lag']).astype('timedelta64[h]') <= 6
    # remove verbal value if occurring more than 6 hr later
    df.loc[~idxTime, 'gcs_verbal_text_lag'] = None
    df.loc[~idxTime, 'gcs_verbal_numeric_lag'] = None

    # verify GCS logic:
    # (1) verbal score is correctly carried forward if 0
    # (2) verbal score is imputed at 5 if nothing to carry forward

    # verbal score for this row is "unable"
    idxETT = (df['gcs_verbal_text'] == 'No Response-ETT')
    # and the previous row was not
    idxETT &= (df['gcs_verbal_text_lag'] != 'No Response-ETT')
    
    assert idxETT.sum() > 0, 'expected rows with gcs imputed, check stay_id/subject_id data'
    assert (df.loc[idxETT, 'gcs_verbal'] > 0).all(), 'expected no rows with verbal of 0 when prev val available'
    
    # verbal score for this row is "unable"
    idxETT = (df['gcs_verbal_text'] == 'No Response-ETT')
    # and the previous row was not
    idxETT &= (df['gcs_verbal_text_lag'].isnull())

    assert idxETT.sum() > 0, 'expected rows without prior GCS in 6 hours'
    assert (df.loc[idxETT, 'gcs_verbal'] == 0).all(), 'found rows without imputed verbal score'
