import cProfile

import sys
import os
import re
import argparse

import duckdb
import datetime

#import sqlparse
import sqlglot
import sqlglot.dialects.bigquery
import sqlglot.dialects.duckdb
from sqlglot import exp, generator, parser, tokens, transforms
from sqlglot.helper import seq_get

from pprint import pprint

concept_name_map = {
    #'icustay_times': {"path": "../../concepts_postgres/demographics/icustay_times.sql"},
    'icustay_times': {"path": "../../concepts/demographics/icustay_times.sql", "db": "bigquery"},
    #'icustay_hours': {"path": "../../concepts/demographics/icustay_hours.sql", "db": "bigquery"},
    'icustay_hours': {"path": "./concepts/icustay_hours.sql", "db": "duckdb"},
    'echo_data': {"path": "../../concepts/echo_data.sql", "db": "bigquery"},
    #'code_status': {"path": "../../concepts_postgres/code_status.sql"},
    'code_status': {"path": "../../concepts/code_status.sql", "db": "bigquery"},
    'weight_durations': {"path": "../../concepts/durations/weight_durations.sql", "db": "bigquery"},
    #'rrt': {"path": "../../concepts_postgres/rrt.sql"},
    'rrt': {"path": "../../concepts/rrt.sql", "db": "bigquery"},
    'heightweight': {"path": "../../concepts/demographics/heightweight.sql", "db": "bigquery"},
    'icustay_detail': {"path": "../../concepts/demographics/icustay_detail.sql", "db": "bigquery"},

    'ventilation_classification': {"path": "../../concepts/durations/ventilation_classification.sql", "db": "bigquery"},
    'ventilation_durations': {"path": "../../concepts/durations/ventilation_durations.sql", "db": "bigquery"},
    'crrt_durations': {"path": "../../concepts/durations/crrt_durations.sql", "db": "bigquery"},
    'adenosine_durations': {"path": "../../concepts/durations/adenosine_durations.sql", "db": "bigquery"},
    'dobutamine_durations': {"path": "../../concepts/durations/dobutamine_durations.sql", "db": "bigquery"},
    'dopamine_durations': {"path": "../../concepts/durations/dopamine_durations.sql", "db": "bigquery"},
    'epinephrine_durations': {"path": "../../concepts/durations/epinephrine_durations.sql", "db": "bigquery"},
    'isuprel_durations': {"path": "../../concepts/durations/isuprel_durations.sql", "db": "bigquery"},
    'milrinone_durations': {"path": "../../concepts/durations/milrinone_durations.sql", "db": "bigquery"},
    'norepinephrine_durations': {"path": "../../concepts/durations/norepinephrine_durations.sql", "db": "bigquery"},
    'phenylephrine_durations': {"path": "../../concepts/durations/phenylephrine_durations.sql", "db": "bigquery"},
    'vasopressin_durations': {"path": "../../concepts/durations/vasopressin_durations.sql", "db": "bigquery"},
    'vasopressor_durations': {"path": "../../concepts/durations/vasopressor_durations.sql", "db": "bigquery"},
    # move weight_durations here

    'dobutamine_dose': {"path": "../../concepts/durations/dobutamine_dose.sql", "db": "bigquery"},
    'dopamine_dose': {"path": "../../concepts/durations/dopamine_dose.sql", "db": "bigquery"},
    'epinephrine_dose': {"path": "../../concepts/durations/epinephrine_dose.sql", "db": "bigquery"},
    'norepinephrine_dose': {"path": "../../concepts/durations/norepinephrine_dose.sql", "db": "bigquery"},
    'phenylephrine_dose': {"path": "../../concepts/durations/phenylephrine_dose.sql", "db": "bigquery"},
    'vasopressin_dose': {"path": "../../concepts/durations/vasopressin_dose.sql", "db": "bigquery"},

    'pivoted_vital': {"path": "../../concepts/pivot/pivoted_vital.sql", "db": "bigquery"},
    'pivoted_uo': {"path": "../../concepts/pivot/pivoted_uo.sql", "db": "bigquery"},
    'pivoted_rrt': {"path": "../../concepts/pivot/pivoted_rrt.sql", "db": "bigquery"},
    'pivoted_lab': {"path": "../../concepts/pivot/pivoted_lab.sql", "db": "bigquery"},
    'pivoted_invasive_lines': {"path": "../../concepts/pivot/pivoted_invasive_lines.sql", "db": "bigquery"},
    'pivoted_icp': {"path": "../../concepts/pivot/pivoted_icp.sql", "db": "bigquery"},
    'pivoted_height': {"path": "../../concepts/pivot/pivoted_height.sql", "db": "bigquery"},
    'pivoted_gcs': {"path": "../../concepts/pivot/pivoted_gcs.sql", "db": "bigquery"},
    'pivoted_fio2': {"path": "../../concepts/pivot/pivoted_fio2.sql", "db": "bigquery"},
    'pivoted_bg': {"path": "../../concepts/pivot/pivoted_bg.sql", "db": "bigquery"},
    # pivoted_bg_art must be run after pivoted_bg
    'pivoted_bg_art': {"path": "../../concepts/pivot/pivoted_bg_art.sql", "db": "bigquery"},
    # Difficult error here, the original query seems to reference something non-existent...
    # the `pivot` queries are omitted from the Postgres version... we may have to do the same?
    # pivoted oasis depends on icustay_hours in demographics
    #'pivoted_oasis': {"path": "../../concepts/pivot/pivoted_oasis.sql", "db": "bigquery"},
    # Another puzzling error here, duckdb doesn't like something on the `WITH` line!
    # pivoted sofa depends on many above pivoted views, ventilation_durations, and dose queries
    #'pivoted_sofa': {"path": "../../concepts/pivot/pivoted_sofa.sql", "db": "bigquery"},

    'elixhauser_ahrq_v37': {"path": "../../concepts/comorbidity/elixhauser_ahrq_v37.sql", "db": "bigquery"},
    'elixhauser_ahrq_v37_no_drg': {"path": "../../concepts/comorbidity/elixhauser_ahrq_v37_no_drg.sql", "db": "bigquery"},
    'elixhauser_quan': {"path": "../../concepts/comorbidity/elixhauser_quan.sql", "db": "bigquery"},
    'elixhauser_score_ahrq': {"path": "../../concepts/comorbidity/elixhauser_score_ahrq.sql", "db": "bigquery"},
    'elixhauser_score_quan': {"path": "../../concepts/comorbidity/elixhauser_score_quan.sql", "db": "bigquery"},

    'blood_gas_first_day': {"path": "../../concepts/firstday/blood_gas_first_day.sql", "db": "bigquery"},
    'blood_gas_first_day_arterial': {"path": "../../concepts/firstday/blood_gas_first_day_arterial.sql", "db": "bigquery"},
    'gcs_first_day': {"path": "../../concepts/firstday/gcs_first_day.sql", "db": "bigquery"},
    'labs_first_day': {"path": "../../concepts/firstday/labs_first_day.sql", "db": "bigquery"},
    'rrt_first_day': {"path": "../../concepts/firstday/rrt_first_day.sql", "db": "bigquery"},
    'urine_output_first_day': {"path": "../../concepts/firstday/urine_output_first_day.sql", "db": "bigquery"},
    'ventilation_first_day': {"path": "../../concepts/firstday/ventilation_first_day.sql", "db": "bigquery"},
    'vitals_first_day': {"path": "../../concepts/firstday/vitals_first_day.sql", "db": "bigquery"},
    'weight_first_day': {"path": "../../concepts/firstday/weight_first_day.sql", "db": "bigquery"},
    
    'urine_output': {"path": "../../concepts/fluid_balance/urine_output.sql", "db": "bigquery"},

    'angus': {"path": "../../concepts/sepsis/angus.sql", "db": "bigquery"},
    'martin': {"path": "../../concepts/sepsis/martin.sql", "db": "bigquery"},
    'explicit': {"path": "../../concepts/sepsis/explicit.sql", "db": "bigquery"},

    #FIXME: Must load ccs_multi_dx lookup table first!
    'ccs_dx': {"path": "../../concepts/diagnosis/ccs_dx.sql", "db": "bigquery"},

    'kdigo_creatinine': {"path": "../../concepts/organfailure/kdigo_creatinine.sql", "db": "bigquery"},
    'kdigo_uo': {"path": "../../concepts/organfailure/kdigo_uo.sql", "db": "bigquery"},
    'kdigo_stages': {"path": "../../concepts/organfailure/kdigo_stages.sql", "db": "bigquery"},
    'kdigo_stages_7day': {"path": "../../concepts/organfailure/kdigo_stages_7day.sql", "db": "bigquery"},
    'kdigo_stages_48hr': {"path": "../../concepts/organfailure/kdigo_stages_48hr.sql", "db": "bigquery"},
    'meld': {"path": "../../concepts/organfailure/meld.sql", "db": "bigquery"},

    'oasis': {"path": "../../concepts/severityscores/oasis.sql", "db": "bigquery"},
    'sofa': {"path": "../../concepts/severityscores/sofa.sql", "db": "bigquery"},
    'saps': {"path": "../../concepts/severityscores/saps.sql", "db": "bigquery"},
    'sapsii': {"path": "../../concepts/severityscores/sapsii.sql", "db": "bigquery"},
    'apsiii': {"path": "../../concepts/severityscores/apsiii.sql", "db": "bigquery"},
    'lods': {"path": "../../concepts/severityscores/lods.sql", "db": "bigquery"},
    'sirs': {"path": "../../concepts/severityscores/sirs.sql", "db": "bigquery"},

}

# BigQuery monkey patches
sqlglot.dialects.bigquery.BigQuery.Parser.FUNCTIONS["PARSE_DATETIME"] = lambda args: exp.StrToTime(
    this=seq_get(args, 1), format=seq_get(args, 0)
)
sqlglot.dialects.bigquery.BigQuery.Parser.FUNCTIONS["FORMAT_DATE"] = lambda args: exp.TimeToStr(
    this=seq_get(args, 1), format=seq_get(args, 0)
)
sqlglot.dialects.bigquery.BigQuery.Parser.STRICT_CAST = False

# DuckDB monkey patches
macros = [
    #"CREATE MACRO PARSE_DATETIME(a, b) AS strptime(b, a);",
    #"CREATE MACRO FORMAT_DATE(a, b) AS strftime(CAST(b AS DATE), CAST(a AS VARCHAR));",
    #"CREATE OR REPLACE MACRO DATETIME_DIFF(a, b, u := 'DAY') AS date_diff(CAST(u AS VARCHAR), CAST(a AS TIME), CAST(b AS TIME));",
    #"CREATE OR REPLACE MACRO DATETIME_DIFF_MACRO(u, a, b) AS date_diff(u, CAST(a AS TIME), CAST(b AS TIME));",
]
def duckdb_date_sub_sql(self, expression):
    #print("CALLING duckdb._date_sub")
    this = self.sql(expression, "this")
    unit = self.sql(expression, "unit") or "DAY" # .strip("'")
    return f"{this} - {self.sql(exp.Interval(this=expression.expression, unit=unit))}"
#sqlglot.dialects.duckdb._date_sub_sql = duckdb_date_sub_sql
#sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DateSub] = duckdb_date_sub_sql
sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DatetimeSub] = duckdb_date_sub_sql
sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DatetimeAdd] = sqlglot.dialects.duckdb._date_add

def duckdb_date_diff_sql(self, expression):
    #print("CALLING duckdb._date_diff")
    this = self.sql(expression, "this")
    unit = self.sql(expression, "unit") or "DAY"
    return f"DATE_DIFF('{unit}', {this}, {self.sql(expression.expression)})"
#sqlglot.dialects.duckdb._date_diff_sql = duckdb_date_diff_sql
sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DatetimeDiff] = duckdb_date_diff_sql
#sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DatetimeDiff] = sqlglot.dialects.duckdb._date_diff_sql
#sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DatetimeDiff] = sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DateDiff]
sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DateDiff] = duckdb_date_diff_sql

if False:
    concept_name_map = {
        'icustay_times': {"path": "../../concepts_postgres/demographics/icustay_times.sql"},
        'icustay_hours': {"path": "./demographics/icustay_hours.sql", "db": "duckdb"},
        'echo_data': {"path": "../../concepts/echo_data.sql", "db": "bigquery"},
        'code_status': {"path": "../../concepts_postgres/code_status.sql"},
        'weight_durations': {"path": "../../concepts/durations/weight_durations.sql", "db": "bigquery"},
        'rrt': {"path": "../../concepts_postgres/rrt.sql"},
        'urine_output': {"path": "../../concepts/fluid_balance/urine_output.sql", "db": "bigquery"},
        'kdigo_uo': {"path": "../../concepts/organfailure/kdigo_uo.sql", "db": "bigquery"}
    }
    
    ##sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DatetimeSub] = sqlglot.dialects.dialect.rename_func("date_sub")
    sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DatetimeSub] = sqlglot.dialects.duckdb._date_sub_sql
    sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DatetimeAdd] = sqlglot.dialects.duckdb._date_add
    sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DateSub] = sqlglot.dialects.duckdb._date_sub_sql
    ##sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DatetimeDiff] = sqlglot.dialects.dialect.rename_func("date_diff")
    ##sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DatetimeDiff] = lambda self, e: self.func(
    ##    "DATE_DIFF", ("'"+(e.args.get("unit") or exp.Literal.string("day")).name+"'"), e.expression, e.this
    ##)
    ##sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.Cast] = exp.TryCast


    # BigQuery monkey patches

    # Postgres monkey patches
    sqlglot.dialects.postgres.Postgres.Parser.FUNCTIONS["PARSE_DATETIME"] = lambda args: exp.StrToTime(
        this=seq_get(args, 1), format=seq_get(args, 0)
    )
    sqlglot.dialects.postgres.Postgres.Parser.FUNCTIONS["FORMAT_DATE"] = lambda args: exp.TimeToStr(
        this=seq_get(args, 1), format=seq_get(args, 0)
    )
    sqlglot.dialects.postgres.Postgres.Parser.STRICT_CAST = False

_time_unit_kwargs_map = {
    "HOUR": "hour",
    "DAY": "day",
    "MINUTE": "minute",
    "SECOND": "second",
    "YEAR": "year"
}
def _bigquery_duckdb_transformer(node):
    if isinstance(node, exp.Var) and node.name in _time_unit_kwargs_map:
        #print(f"{node=}")
        return sqlglot.parse_one(f"{node.name}")
    return node

    if isinstance(node, exp.Anonymous):
        #print(f"{node.name=}")
        #return sqlglot.parse_one(node.name) #no-op
        return node
    if isinstance(node, exp.DatetimeSub):
        #print(f"{node=}")
        return node
    if isinstance(node, exp.Column):
        #print(f"COLUMN {node.name=}")
        return node
    return node


def _make_duckdb_query_bigquery(qname: str, conn):
    _multischema_trunc_re = re.compile("\"physionet-data\.mimiciii_\w+\.")
    
    #TODO: better anwer here? should only hit ccs_dx.sql!
    _too_many_backslashes_re = re.compile("\\\\([\[\.\]])", ) 

    #_whole_line_comments_strip_re = re.compile("^\s*--.*$", flags=re.MULTILINE)
    qfile = concept_name_map[qname]["path"]
    with open(qfile, "r") as fp:
        sql = fp.read()
        ##strip comments manually... one weird thing happening in pivoted_sofa...??
        #sql = re.sub(_whole_line_comments_strip_re, '', sql)
        sql = re.sub(_too_many_backslashes_re, '\\$1', sql) 
        try:
            #print(repr(sqlglot.parse_one(sql.replace('`','"'))))
            sql_list = sqlglot.transpile(sql, read="bigquery", write="duckdb", pretty=True)
        except Exception as e:
            print(sql)
            raise e
        print()
        for st in sql_list:
            sql = re.sub(_multischema_trunc_re, "\"", st)
            #ast = sqlglot.parse_one(sql)
            #ast2 = ast.transform(_bigquery_duckdb_transformer)
            #sql = ast2.sql(pretty=True)
            #print(sql)

            if concept_name_map[qname].get("nocreate", False):
                cursor = conn.cursor()
                try:
                    cursor.execute(sql)
                except Exception as e:
                    print(sql)
                    print(repr(sqlglot.parse_one(sql)))
                    raise e
                result = cursor.fetchone()
                print(result)
                cursor.close()
                return sql

            conn.execute(f"DROP VIEW IF EXISTS {qname}")
            try:         
                conn.execute(f"CREATE TEMP VIEW {qname} AS " + sql)
            except Exception as e:
                print(sql)
                #print(repr(sqlglot.parse_one(sql)))
                raise e
            print(f"CREATED VIEW {qname}")

        #print()

def _make_duckdb_query_postgres(qname: str, conn):
    _uncreate_re = re.compile("DROP.*?;\s+CREATE.*?AS")
    _multischema_trunc_re = re.compile("\"physionet-data\.mimiciii_\w+\.")
    qfile = concept_name_map[qname]["path"]
    with open(qfile, "r") as fp:
        sql = fp.read()
        sql = re.sub(_uncreate_re, "", sql).strip()
        sql_list = sqlglot.transpile(sql, read="postgres", write="duckdb", pretty=True)
        for st in sql_list:
            if st == '':
                continue
            sql = re.sub(_multischema_trunc_re, "\"", st)
            #ast = sqlglot.parse_one(sql)
            #ast2 = ast.transform(_bigquery_sqlite_transformer)
            #sql = ast2.sql()
            #print(sql)

            if concept_name_map[qname].get("nocreate", False):
                cursor = conn.cursor()
                try:
                    cursor.execute(sql)
                except Exception as e:
                    print(sql)
                    print(repr(sqlglot.parse_one(sql)))
                    raise e
                result = cursor.fetchone()
                print(result)
                cursor.close()
                return sql

            conn.execute(f"DROP VIEW IF EXISTS {qname}")
            try:         
                conn.execute(f"CREATE TEMP VIEW {qname} AS " + sql)
                conn.execute(sql)
            except Exception as e:
                print(sql)
                #print(repr(sqlglot.parse_one(sql)))
                raise e
            print(f"CREATED VIEW {qname}")

        #print()

def _make_duckdb_query_duckdb(qname: str, conn):
    qfile = concept_name_map[qname]["path"]
    with open(qfile, "r") as fp:
        sql = fp.read()
        if concept_name_map[qname].get("nocreate", False):
            cursor = conn.cursor()
            try:
                cursor.execute(sql)
            except Exception as e:
                print(sql)
                raise e
            result = cursor.fetchone()
            print(result)
            cursor.close()
            return sql
        try:         
            conn.execute(f"CREATE TEMP VIEW {qname} AS " + sql)
        except Exception as e:
            print(sql)
            raise e
        print(f"CREATED VIEW {qname}")


def main() -> int:
    global concept_name_map

    parser = argparse.ArgumentParser(
        prog='buildmimic_duckdb',
        description='Creates the MIMIC-III database in DuckDB and optionally the concepts views.',
        )
    parser.add_argument('output_db_file', help="The destination DuckDB file to be written", default="./mimiciii.db")
    parser.add_argument('--data-path', required=True)
    parser.add_argument('--make-concepts', action="store_true")
    parser.add_argument('--mimic-code-root', default='../../../')
    args = parser.parse_args()
    output_db_file = args.output_db_file
    data_path = args.data_path
    make_concepts = args.make_concepts
    mimic_code_root = args.mimic_code_root

    if make_concepts:
        connection = duckdb.connect(output_db_file)
        print("Connected to duckdb...")

        #print("Defining macros...")
        #for macro in macros:
        #        connection.execute(macro)

        print("Creating tables...")
        
        # ccs_dx is an outlier...this is adapted from the BigQuery version...
        ccs_multi_dx_create = """
            DROP TABLE IF EXISTS ccs_multi_dx;
            CREATE TABLE ccs_multi_dx
            (
            icd9_code CHAR(5) NOT NULL,
            -- CCS levels and names based on position in hierarchy
            ccs_level1 VARCHAR(10),
            ccs_group1 VARCHAR(100),
            ccs_level2 VARCHAR(10),
            ccs_group2 VARCHAR(100),
            ccs_level3 VARCHAR(10),
            ccs_group3 VARCHAR(100),
            ccs_level4 VARCHAR(10),
            ccs_group4 VARCHAR(100)
            );
            """

        print("Loading data...")
        try:
            #FIXME: Turn this line back on!
            #connection.execute(ccs_multi_dx_create)
            #connection.execute(...)
            data_path = os.path.join(mimic_code_root, 'mimic-iii','concepts_postgres','diagnosis','ccs_multi_dx.csv.gz')
            #connection.from_csv_auto(
            #    name=data_path,
            #    header=True)
            #FIXME: Turn this line back on!
            #connection.execute(f"COPY ccs_multi_dx from '{data_path}' (FORMAT CSV, DELIMITER ',', HEADER);")
            
            print(connection.sql("SELECT * FROM ccs_multi_dx LIMIT 10;"))
        except Exception as error:
            print("Failed to setup ccs_multi_dx: ", error)
            raise error
        finally:
            if connection:
                connection.close()
                print("duckdb connection is closed")

        connection = duckdb.connect(output_db_file)

        print("Creating views...")
        try:
            for key in concept_name_map:
                #cProfile.run('...')
                #print(f"Making view {key}...")
                db = concept_name_map[key].get("db", "postgres")
                if db == "duckdb":
                    _make_duckdb_query_duckdb(key, connection)
                elif db == "bigquery":
                    _make_duckdb_query_bigquery(key, connection)
                elif db == "postgres":
                    _make_duckdb_query_postgres(key, connection)

        except Exception as error:
            print("Failed to execute translated SQL: ", error)
            raise error
        finally:
            if connection:
                connection.close()
                print("duckdb connection is closed")
            
if __name__ == '__main__':
    sys.exit(main())




