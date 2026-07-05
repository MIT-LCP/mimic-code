from datetime import datetime, timedelta, timezone

import pandas as pd

from mimic_utils.compare_concepts import compare_table


def test_compare_table_treats_same_wall_time_as_equal_across_timezones():
    pg = pd.DataFrame({"charttime": [datetime(2150, 1, 1, 3, 30, tzinfo=timezone(timedelta(hours=2)))]})
    duck = pd.DataFrame({"charttime": [datetime(2150, 1, 1, 3, 30)]})

    assert compare_table(pg, duck, 1e-6, 1e-9) == (True, "1 rows OK")


def test_compare_table_flags_different_wall_times_even_if_instants_match():
    pg = pd.DataFrame({"charttime": [datetime(2150, 1, 1, 3, 30, tzinfo=timezone(timedelta(hours=2)))]})
    duck = pd.DataFrame({"charttime": [datetime(2150, 1, 1, 1, 30)]})

    assert compare_table(pg, duck, 1e-6, 1e-9) == (
        False,
        "1 differing cells in columns: charttime(1)",
    )