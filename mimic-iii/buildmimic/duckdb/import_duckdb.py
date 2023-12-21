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
    'icustay_times': {"path": "demographics/icustay_times.sql"},
    'icustay_hours': {"path": "icustay_hours.sql", "db": "duckdb"},
    'echo_data': {"path": "echo_data.sql"},
    'code_status': {"path": "code_status.sql"},
    'weight_durations': {"path": "durations/weight_durations.sql"},
    'rrt': {"path": "rrt.sql"},
    'heightweight': {"path": "demographics/heightweight.sql"},
    'icustay_detail': {"path": "demographics/icustay_detail.sql"},

    'ventilation_classification': {"path": "durations/ventilation_classification.sql"},
    'ventilation_durations': {"path": "durations/ventilation_durations.sql"},
    'crrt_durations': {"path": "durations/crrt_durations.sql"},
    'adenosine_durations': {"path": "durations/adenosine_durations.sql"},
    'dobutamine_durations': {"path": "durations/dobutamine_durations.sql"},
    'dopamine_durations': {"path": "durations/dopamine_durations.sql"},
    'epinephrine_durations': {"path": "durations/epinephrine_durations.sql"},
    'isuprel_durations': {"path": "durations/isuprel_durations.sql"},
    'milrinone_durations': {"path": "durations/milrinone_durations.sql"},
    'norepinephrine_durations': {"path": "durations/norepinephrine_durations.sql"},
    'phenylephrine_durations': {"path": "durations/phenylephrine_durations.sql"},
    'vasopressin_durations': {"path": "durations/vasopressin_durations.sql"},
    'vasopressor_durations': {"path": "durations/vasopressor_durations.sql"},

    'dobutamine_dose': {"path": "durations/dobutamine_dose.sql"},
    'dopamine_dose': {"path": "durations/dopamine_dose.sql"},
    'epinephrine_dose': {"path": "durations/epinephrine_dose.sql"},
    'norepinephrine_dose': {"path": "durations/norepinephrine_dose.sql"},
    'phenylephrine_dose': {"path": "durations/phenylephrine_dose.sql"},
    'vasopressin_dose': {"path": "durations/vasopressin_dose.sql"},

    'pivoted_vital': {"path": "pivot/pivoted_vital.sql"},
    'pivoted_uo': {"path": "pivot/pivoted_uo.sql"},
    'pivoted_rrt': {"path": "pivot/pivoted_rrt.sql"},
    'pivoted_lab': {"path": "pivot/pivoted_lab.sql"},
    'pivoted_invasive_lines': {"path": "pivot/pivoted_invasive_lines.sql"},
    'pivoted_icp': {"path": "pivot/pivoted_icp.sql"},
    'pivoted_height': {"path": "pivot/pivoted_height.sql"},
    'pivoted_gcs': {"path": "pivot/pivoted_gcs.sql"},
    'pivoted_fio2': {"path": "pivot/pivoted_fio2.sql"},
    'pivoted_bg': {"path": "pivot/pivoted_bg.sql"},
    # pivoted_bg_art must be run after pivoted_bg
    'pivoted_bg_art': {"path": "pivot/pivoted_bg_art.sql"},
    # Difficult error here, the original query seems to reference something non-existent...
    # the `pivot` queries are omitted from the Postgres version... we may have to do the same?
    # pivoted oasis depends on icustay_hours in demographics
    #'pivoted_oasis': {"path": "pivot/pivoted_oasis.sql"},
    # Another puzzling error here, duckdb doesn't like something on the `WITH` line!
    # pivoted sofa depends on many above pivoted views, ventilation_durations, and dose queries
    #'pivoted_sofa': {"path": "pivot/pivoted_sofa.sql"},

    'elixhauser_ahrq_v37': {"path": "comorbidity/elixhauser_ahrq_v37.sql"},
    'elixhauser_ahrq_v37_no_drg': {"path": "comorbidity/elixhauser_ahrq_v37_no_drg.sql"},
    'elixhauser_quan': {"path": "comorbidity/elixhauser_quan.sql"},
    'elixhauser_score_ahrq': {"path": "comorbidity/elixhauser_score_ahrq.sql"},
    'elixhauser_score_quan': {"path": "comorbidity/elixhauser_score_quan.sql"},

    'blood_gas_first_day': {"path": "firstday/blood_gas_first_day.sql"},
    'blood_gas_first_day_arterial': {"path": "firstday/blood_gas_first_day_arterial.sql"},
    'gcs_first_day': {"path": "firstday/gcs_first_day.sql"},
    'labs_first_day': {"path": "firstday/labs_first_day.sql"},
    'rrt_first_day': {"path": "firstday/rrt_first_day.sql"},
    'urine_output_first_day': {"path": "firstday/urine_output_first_day.sql"},
    'ventilation_first_day': {"path": "firstday/ventilation_first_day.sql"},
    'vitals_first_day': {"path": "firstday/vitals_first_day.sql"},
    'weight_first_day': {"path": "firstday/weight_first_day.sql"},
    
    'urine_output': {"path": "fluid_balance/urine_output.sql"},
    'colloid_bolus': {"path": "fluid_balance/colloid_bolus.sql"},
    'crystalloid_bolus': {"path": "fluid_balance/crystalloid_bolus.sql"},
    'ffp_transfusion': {"path": "fluid_balance/ffp_transfusion.sql"},
    'rbc_transfusion': {"path": "fluid_balance/rbc_transfusion.sql"},

    'angus': {"path": "sepsis/angus.sql"},
    'martin': {"path": "sepsis/martin.sql"},
    'explicit': {"path": "sepsis/explicit.sql"},

    'ccs_dx': {"path": "diagnosis/ccs_dx.sql", "schema": None}, # explicit None means default schema not schema_name

    'kdigo_creatinine': {"path": "organfailure/kdigo_creatinine.sql"},
    'kdigo_uo': {"path": "organfailure/kdigo_uo.sql"},
    'kdigo_stages': {"path": "organfailure/kdigo_stages.sql"},
    'kdigo_stages_7day': {"path": "organfailure/kdigo_stages_7day.sql"},
    'kdigo_stages_48hr': {"path": "organfailure/kdigo_stages_48hr.sql"},
    'meld': {"path": "organfailure/meld.sql"},

    'oasis': {"path": "severityscores/oasis.sql"},
    'sofa': {"path": "severityscores/sofa.sql"},
    'saps': {"path": "severityscores/saps.sql"},
    'sapsii': {"path": "severityscores/sapsii.sql"},
    'apsiii': {"path": "severityscores/apsiii.sql"},
    'lods': {"path": "severityscores/lods.sql"},
    'sirs': {"path": "severityscores/sirs.sql"},

}

# This will contain all the table/view names to put in a namespace...
tables_in_schema = set()

# BigQuery monkey patches
sqlglot.dialects.bigquery.BigQuery.Parser.FUNCTIONS["PARSE_DATETIME"] = lambda args: exp.StrToTime(
    this=seq_get(args, 1), format=seq_get(args, 0)
)
sqlglot.dialects.bigquery.BigQuery.Parser.FUNCTIONS["FORMAT_DATE"] = lambda args: exp.TimeToStr(
    this=seq_get(args, 1), format=seq_get(args, 0)
)
sqlglot.dialects.bigquery.BigQuery.Parser.STRICT_CAST = False

# DuckDB monkey patches
def duckdb_date_sub_sql(self, expression):
    #print("CALLING duckdb._date_sub")
    this = self.sql(expression, "this")
    unit = self.sql(expression, "unit") or "DAY" # .strip("'")
    return f"{this} - {self.sql(exp.Interval(this=expression.expression, unit=unit))}"
sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DatetimeSub] = duckdb_date_sub_sql
sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DatetimeAdd] = sqlglot.dialects.duckdb._date_add

_unit_ms_conversion_factor_map = {
    'SECOND': 1e6,
    'MINUTE': 60.0*1e6,
    'HOUR': 3600.0*1e6,
    'DAY': 24*3600.0*1e6,
    'YEAR': 365.242*24*3600.0*1e6,
}
def duckdb_date_diff_whole_sql(self, expression):
    #print("CALLING duckdb._date_diff")
    this = self.sql(expression, "this")
    unit = self.sql(expression, "unit") or "DAY"
    # DuckDB DATE_DIFF operand order is start_time, end_time--not like end_time - start_time!
    return f"DATE_DIFF('{unit}', {self.sql(expression.expression)}, {this})" 
def duckdb_date_diff_frac_sql(self, expression):
    this = self.sql(expression, "this")
    mfactor = _unit_ms_conversion_factor_map[self.sql(expression, "unit").upper() or "DAY"]
    # DuckDB DATE_DIFF operand order is start_time, end_time--not like end_time - start_time!
    return f"DATE_DIFF('microseconds', {self.sql(expression.expression)}, {this})/{mfactor:.1f}"
# only one of these will be used, set later based on arguments!

# This may not be strictly necessary because the views work without
# it IF you `use` the schema first... but making them fully qualified
# makes them work regardless of the current schema.
def _duckdb_rewrite_schema(sql: str, schema: str):
    parsed = sqlglot.parse_one(sql, read=sqlglot.dialects.DuckDB)
    for table in parsed.find_all(exp.Table):
        for identifier in table.find_all(exp.Identifier):
            if identifier.this.lower() in tables_in_schema:
                sql = sql.replace('"'+identifier.this+'"', schema+'.'+identifier.this.lower())
    # The below (unfinished) causes problems because some munging of functions
    # occurs in the output. The above approach is kludgy, but works and limits
    # the blast radius of potential problems regexping SQL.
    """
    def transformer(node):
        if isinstance(node, exp.Table): #and node.name == "a":
            for id in node.find_all(exp.Identifier):
                if id.this.lower() in tables_in_schema:
                    id.this = schema + '.' + id.this.lower()
                    #print(id)
            return node
        return node
    transformed_tree = parsed.transform(transformer)
    sql = transformed_tree.sql(dialect=sqlglot.dialects.DuckDB)
    """
    return sql


def _make_duckdb_query_bigquery(qname: str, qfile: str, conn, schema: str = None):
    _multischema_trunc_re = re.compile("\"physionet-data\.mimiciii_\w+\.")
    
    #TODO: better answer here? should only hit ccs_dx.sql!
    _too_many_backslashes_re = re.compile("\\\\([\[\.\]])") 

    with open(qfile, "r") as fp:
        sql = fp.read()
        sql = re.sub(_too_many_backslashes_re, '\\$1', sql) 
        try:
            sql_list = sqlglot.transpile(sql, read="bigquery", write="duckdb", pretty=True)
        except Exception as e:
            print(sql)
            raise e
        for st in sql_list:
            sql = re.sub(_multischema_trunc_re, "\"", st)

            if schema is not None:
                sql = _duckdb_rewrite_schema(sql, schema)

            conn.execute(f"DROP VIEW IF EXISTS {qname}")
            try:         
                conn.execute(f"CREATE VIEW {qname} AS " + sql)
            except Exception as e:
                print(sql)
                #print(repr(sqlglot.parse_one(sql)))
                raise e
            print(f"CREATED VIEW {qname}")

        #print()


def _make_duckdb_query_duckdb(qname: str, qfile: str, conn, schema: str = None):
    with open(qfile, "r") as fp:
        sql = fp.read()

        if schema is not None:
            sql = _duckdb_rewrite_schema(sql, schema)

        try:         
            conn.execute(f"CREATE OR REPLACE VIEW {qname} AS " + sql)
        except Exception as e:
            print(sql)
            raise e
        print(f"CREATED VIEW {qname}")


def main() -> int:

    parser = argparse.ArgumentParser(
        prog='buildmimic_duckdb',
        description='Creates the MIMIC-III database in DuckDB and optionally the concepts views.',
        )
    parser.add_argument('mimic_data_dir', help="directory that contains csv.tar.gz or csv files")
    parser.add_argument('output_db', help="filename for duckdb file (default: mimic3.db)", nargs='?', default="./mimic3.db")
    parser.add_argument('--mimic-code-root', help="location of the mimic-code repo (used to find concepts SQL)", default='../../../')
    parser.add_argument('--make-concepts', help="generate the concepts views", action="store_true")
    parser.add_argument('--skip-tables', help="don't create schema or load data (they must already exist)", action="store_true")
    parser.add_argument('--skip-indexes', help="don't create indexes (implied by --skip-tables)", action="store_true")
    parser.add_argument('--schema-name', help="put all object (except ccs_dx) into a schema (like the PostgreSQL version)", default=None)
    parser.add_argument('--integer-datetime-diff', help="EXPERIMENTAL: calculate integer DATETIME_DIFF results (like BigQuery) for e.g. icustay_detail.los_icu", action="store_true")
    args = parser.parse_args()
    output_db = args.output_db
    mimic_data_dir = args.mimic_data_dir
    make_concepts = args.make_concepts
    mimic_code_root = args.mimic_code_root
    skip_tables = args.skip_tables
    skip_indexes = args.skip_indexes
    integer_datetime_diff = args.integer_datetime_diff
    #TODO: validate schema_name is valid identifier
    schema_name = args.schema_name

    #EXPERIMENTAL! May be removed.
    if integer_datetime_diff:
        sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DatetimeDiff] = duckdb_date_diff_whole_sql
        sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DateDiff] = duckdb_date_diff_whole_sql
    else:
        sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DatetimeDiff] = duckdb_date_diff_frac_sql
        sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DateDiff] = duckdb_date_diff_frac_sql


    if not skip_tables:

        connection = duckdb.connect(output_db)
        print("Connected to duckdb...")

        try:
            schema_prequel = ""
            if schema_name is not None:
                connection.execute(f"CREATE SCHEMA IF NOT EXISTS {schema_name};")
                connection.execute(f"USE {schema_name};")
                schema_prequel = f"USE {schema_name};"

            print("Creating tables...")
    
            with open(os.path.join(mimic_code_root, 'mimic-iii','buildmimic','duckdb','duckdb_add_tables.sql'), 'r') as fp:
                sql = fp.read()
                connection.execute(sql)

            print("Loading data...")
            
            for f in os.listdir(mimic_data_dir):
                m = re.match(r'^(.*)\.csv(\.gz)*', f)
                if m is not None:
                    tablename = m.group(1).lower()
                    tables_in_schema.add(tablename)
                    tablename = tablename if schema_name is None else schema_name+'.'+tablename
                    print(f"  {tablename}")
                    connection.execute(f"COPY {tablename} from '{os.path.join(mimic_data_dir,m.group(0))}' (FORMAT CSV, DELIMITER ',', HEADER);")
            
            if not skip_indexes:
                print("Adding indexes...")
        
                with open(os.path.join(mimic_code_root, 'mimic-iii','buildmimic','duckdb','duckdb_add_indexes.sql'), 'r') as fp:
                    sql = fp.read()
                    connection.execute(sql)

            print("Running checks...")
    
            with open(os.path.join(mimic_code_root, 'mimic-iii','buildmimic','duckdb','duckdb_checks.sql'), 'r') as fp:
                sql = fp.read()
                result = connection.execute(sql).fetchall()
                for row in result:
                    print(f"{row[0]}: {row[2]} records ({row[1]} expected) - {row[3]}")

        except Exception as error:
            print("Failed setting up database: ", error)
            raise error
        finally:
            if connection:
                connection.close()
                print("duckdb connection is closed")

    #TODO: If both --schema-name and --skip-tables are specified, we won't have
    # populated tables_in_schema with the data table names... so the views won't
    # work... So, here, read the tables already in the destination schema from
    # the DB and add those tablenames to tables_in_schema?

    if make_concepts:
        connection = duckdb.connect(output_db)
        print("Connected to duckdb...")

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

            connection.execute(f"USE main;")

            connection.execute(ccs_multi_dx_create)
            csvgz_path = os.path.join(mimic_code_root, 'mimic-iii','concepts_postgres','diagnosis','ccs_multi_dx.csv.gz')
            connection.execute(f"COPY ccs_multi_dx from '{csvgz_path}' (FORMAT CSV, DELIMITER ',', HEADER);")
            
        except Exception as error:
            print("Failed to setup ccs_multi_dx: ", error)
            raise error
        finally:
            if connection:
                connection.close()
                print("duckdb connection is closed")

        connection = duckdb.connect(output_db)

        print("Creating views...")
        try:

            if schema_name is not None:
                connection.execute(f"CREATE SCHEMA IF NOT EXISTS {schema_name};")
                connection.execute(f"USE {schema_name}")

            for key in concept_name_map:
                if schema_name is not None:
                    if "schema" not in concept_name_map[key]:
                        tables_in_schema.add(key.lower())

                #cProfile.run('...')
                #print(f"Making view {key}...")
                db = concept_name_map[key].get("db", "bigquery")
                if db == "duckdb":
                    qpath = os.path.join(mimic_code_root, 'mimic-iii', 'buildmimic', 'duckdb', 'concepts', concept_name_map[key]['path'])
                    _make_duckdb_query_duckdb(key, qpath, connection, schema=concept_name_map[key].get('schema', schema_name))
                elif db == "bigquery":
                    qpath = os.path.join(mimic_code_root, 'mimic-iii', 'concepts', concept_name_map[key]['path'])
                    _make_duckdb_query_bigquery(key, qpath, connection, schema=schema_name)

        except Exception as error:
            print("Failed to execute translated SQL: ", error)
            raise error
        finally:
            if connection:
                connection.close()
                print("duckdb connection is closed")
            
if __name__ == '__main__':
    sys.exit(main())




