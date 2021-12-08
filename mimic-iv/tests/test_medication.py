import pandas as pd
from pandas.io import gbq
import logging

_LOGGER = logging.getLogger(__name__)

def test_vasopressor_units(dataset, project_id):
    # verify vasopressors in expected units
    units = {
        'milrinone': 'mcg/kg/min',
        'dobutamine': 'mcg/kg/min',
        'dopamine': 'mcg/kg/min',
        'epinephrine': 'mcg/kg/min',
        'norepinephrine': 'mcg/kg/min',
        'phenylephrine': 'mcg/kg/min',
        'vasopressin': 'units/hour',
    }

    itemids = {
        'milrinone': 221986,
        'dobutamine': 221653,
        'dopamine': 221662,
        'epinephrine': 221289,
        'norepinephrine': 221906,
        'phenylephrine': 221749,
        'vasopressin': 222315,
    }

    hadm_id = {
        'norepinephrine': [21898267],
        'phenylephrine': [26809360],
        'vasopressin': [26272149]
    }

    # verify we always have a unit of measure for the rate
    query = f"""
    select itemid, COUNT(*) AS n
    FROM mimic_icu.inputevents
    WHERE itemid IN ({", ".join([str(x) for x in itemids.values()])})
    AND rateuom IS NULL
    GROUP BY itemid
    """
    df = gbq.read_gbq(query, project_id=project_id, dialect="standard")
    assert df.shape[0] == 0, 'found vasopressors with null units'

    # norepinephrine has two rows in mg/kg/min
    #   these are actually supposed to be mcg/kg/min - and the patient weight has been set to 1 to make it work
    # phenylephrine has one row in mcg/min - looks fine, within expected dose
    # vasopressin three rows in units/min - these look OK
    
    for drug, hadm_id_list in hadm_id.items():
        query = f"""
        select hadm_id, rate, rateuom
        FROM mimic_icu.inputevents
        WHERE itemid = {itemids[drug]}
        AND rateuom != '{units[drug]}'
        LIMIT 10
        """
        df = gbq.read_gbq(query, project_id=project_id, dialect="standard")
        # if we find new uninspected rows, raise a warning. this will only happen when mimic-iv is updated.
        if (~df['hadm_id'].contains(hadm_id_list)).any():
            _LOGGER.warn(f"""New data found with non-standard unit. Inspect the data with this query:

            select *
            from `physionet-data.mimic_icu.inputevents`
            where itemid = {itemids['vasopressin']}
            and stay_id in (
                select stay_id from `physionet-data.mimic_icu.inputevents`
                where itemid = {itemids['vasopressin']}
                and rateuom != '{units['vasopressin']}'
            )
            order by starttime
            """)
        assert df.shape[0] != 10, f'many rows found with non-standard unit for {drug}'

def test_vasopressor_doses(dataset, project_id):
    # verify vasopressors have reasonable doses
    # based on uptodate graphic 99963 version 19.0
    # double the maximum dose used in refractory shock is the upper limit used
    itemids = {
        'milrinone': 221986,
        'dobutamine': 221653,
        'dopamine': 221662,
        'epinephrine': 221289,
        'norepinephrine': 221906,
        'phenylephrine': 221749,
        'vasopressin': 222315,
    }
    max_dose = {
        'milrinone': 1.5,
        'dobutamine': 40,
        'dopamine': 40,
        'epinephrine': 4,
        'norepinephrine': 6.6,
        'phenylephrine': 18.2,
        'vasopressin': 0.08,
    }

    for vaso, dose in max_dose.items():
        query = f"""
        select COUNT(vaso_rate) AS n_above_rate
        FROM mimic_derived.{vaso}
        WHERE vaso_rate >= {dose}
        """
        df = gbq.read_gbq(query, project_id=project_id, dialect="standard")
        n_above_rate = df.loc[0, 'n_above_rate']
        assert n_above_rate == 0, f'found {vaso} rows with dose above {dose}, potentially incorrect'


