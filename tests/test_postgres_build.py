import unittest
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import pandas as pd
import os
from subprocess import call

# Prep for Oracle and MySQL database connection
# http://stackoverflow.com/questions/10065051/python-pandas-and-databases-like-mysql
# import cx_Oracle
# import MySQLdb

# Config
psqluser = 'postgres'
testdbname = 'mimic_test_db'
hostname = 'localhost'
datadir = 'testdata/v1_3/'
schema = 'mimiciii'

# Set paths for scripts to be tested
curpath = os.path.join(os.path.dirname(__file__)) + '/'

# Display environment variables
print(os.environ)

# Create dictionary with table details for use in testing
row_dict = {
"ADMISSIONS": 58976,
"CALLOUT": 34499,
"CAREGIVERS": 7567,
"CHARTEVENTS": 263201375,
"CPTEVENTS": 573146,
"D_CPT": 134,
"D_ICD_DIAGNOSES": 14567,
"D_ICD_PROCEDURES": 3882,
"D_ITEMS": 12478,
"D_LABITEMS": 755,
"DATETIMEEVENTS": 4486049,
"DIAGNOSES_ICD": 651047,
"DRGCODES": 125557,
"ICUSTAYS": 61532,
"INPUTEVENTS_CV": 17528894,
"INPUTEVENTS_MV": 3618991,
"LABEVENTS": 27872575,
"MICROBIOLOGYEVENTS": 328446,
"NOTEEVENTS": 2078705,
"OUTPUTEVENTS": 4349339,
"PATIENTS": 46520,
"PRESCRIPTIONS": 4156848,
"PROCEDUREEVENTS_MV": 258066,
"PROCEDURES_ICD": 240095,
"SERVICES": 73343,
"TRANSFERS": 261897 }

# # Load build scripts
# def executescripts(filename):
#     # Open and read the file as a single buffer
#     fd = open(filename, 'r')
#     sqlFile = fd.read()
#     fd.close()

#     # all SQL commands (split on ';')
#     sqlcommands = sqlFile.split(';')

#     # Execute every command from the input file
#     for command in sqlcommands:
#         # This will skip and report errors
#         # For example, if the tables do not yet exist, this will skip over
#         # the DROP TABLE commands
#         try:
#             c.execute(command)
#         except OperationalError, msg:
#             print "Command skipped: ", msg

def run_postgres_build_scripts(cur):
    # Create tables
    fn = curpath + '../buildmimic/postgres/postgres_create_tables.sql'
    cur.execute(open(fn, "r").read())
    # Loads data
    fn = curpath + '../buildmimic/postgres/postgres_load_data.sql'
    if os.environ.has_key('USER') and os.environ['USER'] == 'jenkins': 
        # use full dataset
        mimic_data_dir = '/home/mimicadmin/data/mimiciii_1_3/'
    else: 
        mimic_data_dir = curpath+datadir
    call(['psql','-f',fn,'-d',testdbname,'-U',psqluser,'-v','mimic_data_dir='+mimic_data_dir])
    # Add constraints
    fn = curpath + '../buildmimic/postgres/postgres_add_constraints.sql'
    cur.execute(open(fn, "r").read())
    # Add indexes
    fn = curpath + '../buildmimic/postgres/postgres_add_indexes.sql'
    cur.execute(open(fn, "r").read())

# # Prep for adding MySQL build
# def run_mysql_build_scripts(cur):
#     # Create tables
#     fn = curpath + '../buildmimic/mysql/mysql_create_tables.sql'
#     cur.execute(open(fn, "r").read())
#     # Loads data
#     fn = curpath + '../buildmimic/mysql/mysql_load_data.sql'
#     if os.environ.has_key('USER') and os.environ['USER'] == 'jenkins': 
#         # use full dataset
#         mimic_data_dir = '/home/mimicadmin/data/mimiciii_1_3/'
#     else: 
#         mimic_data_dir = curpath+datadir
#     call(['psql','-f',fn,'-d',testdbname,'-U',psqluser,'-v','mimic_data_dir='+mimic_data_dir])
#     # Add constraints
#     fn = curpath + '../buildmimic/mysql/mysql_add_constraints.sql'
#     cur.execute(open(fn, "r").read())
#     # Add indexes
#     fn = curpath + '../buildmimic/mysql/mysql_add_indexes.sql'
#     cur.execute(open(fn, "r").read())

# Class to run unit tests
class test_postgres(unittest.TestCase):
    # setUpClass runs once for the class
    @classmethod
    def setUpClass(cls):
        # Connect to default postgres database
        cls.con = psycopg2.connect(dbname='postgres', user=psqluser)
        cls.con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cls.cur = cls.con.cursor()
        # Create test database
        try: 
            cls.cur.execute('DROP DATABASE ' + testdbname)
        except psycopg2.ProgrammingError:
            pass
        cls.cur.execute('CREATE DATABASE ' + testdbname)
        cls.cur.close()
        cls.con.close()
        # Connect to the test database
        cls.con = psycopg2.connect(dbname=testdbname, user=psqluser)
        cls.con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cls.cur = cls.con.cursor()
        # Build the test database
        run_postgres_build_scripts(cls.cur)
        cls.cur.close()
        cls.con.close()

    # tearDownClass runs once for the class
    @classmethod
    def tearDownClass(cls):
        # Connect to default postgres database
        cls.con = psycopg2.connect(dbname='postgres', user=psqluser)
        cls.con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cls.cur = cls.con.cursor()
        # Drop test database
        cls.cur.execute('DROP DATABASE ' + testdbname)
        cls.cur.close()
        cls.con.close()

    # setUp runs once for each test method
    def setUp(self):
        # Connect to the test database
        self.con = psycopg2.connect(dbname=testdbname, user=psqluser)
        self.con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        self.cur = self.con.cursor()

    # tearDown runs once for each test method
    def tearDown(self):
        self.cur.close()
        self.con.close()

    # The MIMIC test db has been created by this point
    # Add unit tests below
    def test_run_sample_query(self):
        test_query = """
        SELECT 'hello world';
        """
        hello_world = pd.read_sql_query(test_query,self.con)
        self.assertEqual(hello_world.values[0][0],'hello world')

    def test_testddl(self):
        # Creates and drops an example schema and table
        fn = curpath + 'testddl.sql'
        self.cur.execute(open(fn, "r").read())
        # self.assertEqual(1,1)

    # --------------------------------------------------
    # Run a series of checks to ensure ITEMIDs are valid
    # All checks should return 0.
    # --------------------------------------------------
        
    def test_itemids_in_inputevents_cv_are_shifted(self):
        query = """
        -- prompt Number of ITEMIDs which were erroneously left as original value
        select count(*) from mimiciii.inputevents_cv
        where itemid < 30000;
        """
        queryresult = pd.read_sql_query(query,self.con)
        self.assertEqual(queryresult.values[0][0],0)
        
    def test_itemids_in_inputevents_mv_are_shifted(self):
        query = """
        -- prompt Number of ITEMIDs which were erroneously left as original value
        select count(*) from mimiciii.inputevents_mv
        where itemid < 220000;
        """
        queryresult = pd.read_sql_query(query,self.con)
        self.assertEqual(queryresult.values[0][0],0)
        
    def test_itemids_in_outputevents_are_shifted(self):
        query = """
        -- prompt Number of ITEMIDs which were erroneously left as original value
        select count(*) from mimiciii.outputevents
        where itemid < 30000;
        """
        queryresult = pd.read_sql_query(query,self.con)
        self.assertEqual(queryresult.values[0][0],0)
        
    def test_itemids_in_inputevents_cv_are_in_range(self):
        query = """
        -- prompt Number of ITEMIDs which are above the allowable range
        select count(*) from mimiciii.inputevents_cv
        where itemid > 50000;
        """
        queryresult = pd.read_sql_query(query,self.con)
        self.assertEqual(queryresult.values[0][0],0)
      
    def test_itemids_in_outputevents_are_in_range(self):
        query = """
        -- prompt Number of ITEMIDs which are not in the allowable range
        select count(*) from mimiciii.outputevents
        where itemid > 50000 and itemid < 220000;
        """
        queryresult = pd.read_sql_query(query,self.con)
        self.assertEqual(queryresult.values[0][0],0)
        
    def test_itemids_in_chartevents_are_in_range(self):
        query = """
        -- prompt Number of ITEMIDs which are not in the allowable range
        select count(*) from mimiciii.chartevents
        where itemid > 20000 AND itemid < 220000;
        """
        queryresult = pd.read_sql_query(query,self.con)
        self.assertEqual(queryresult.values[0][0],0)
        
    def test_itemids_in_procedureevents_mv_are_in_range(self):
        query = """
        -- prompt Number of ITEMIDs which are not in the allowable range
        select count(*) from mimiciii.procedureevents_mv
        where itemid < 220000;
        """
        queryresult = pd.read_sql_query(query,self.con)
        self.assertEqual(queryresult.values[0][0],0)
        
    def test_itemids_in_labevents_are_in_range(self):
        query = """
        -- prompt Number of ITEMIDs which are not in the allowable range
        select count(*) from mimiciii.labevents
        where itemid < 50000 or itemid > 60000;
        """
        queryresult = pd.read_sql_query(query,self.con)
        self.assertEqual(queryresult.values[0][0],0)
        
    def test_itemids_in_microbiologyevents_are_in_range(self):
        query = """
        -- prompt Number of ITEMIDs which are not in the allowable range
        select count(*) from mimiciii.microbiologyevents
        where SPEC_ITEMID < 70000 or SPEC_ITEMID > 80000
        or ORG_ITEMID < 80000 or ORG_ITEMID > 90000
        or AB_ITEMID < 90000 or AB_ITEMID > 100000;
        """
        queryresult = pd.read_sql_query(query,self.con)
        self.assertEqual(queryresult.values[0][0],0)

    # ----------------------------------------------------
    # RUN THE FOLLOWING TESTS ON THE FULL DATASET ONLY ---
    # ----------------------------------------------------
        
    if os.environ.has_key('USER') and os.environ['USER'] == 'jenkins':
        def test_row_counts_are_as_expected(self):
            for tablename,expectedrows in row_dict.iteritems():
                query = "SELECT COUNT(*) FROM " + schema + "." + tablename + ";"
                queryresult = pd.read_sql_query(query,self.con)
                self.assertEqual(queryresult.values[0][0],expectedrows)

        def test_age_and_los_is_expected(self):
            query = \
            """
            WITH icuadmissions as (
                SELECT a.subject_id, a.hadm_id, i.icustay_id, 
                    a.admittime as hosp_admittime, a.dischtime as hosp_dischtime, 
                    i.first_careunit, 
                    DENSE_RANK() over(PARTITION BY a.hadm_id ORDER BY i.intime ASC) as icu_seq,
                    p.dob, p.dod, i.intime as icu_intime, i.outtime as icu_outtime, 
                    i.los as icu_los,
                    round((EXTRACT(EPOCH FROM (a.dischtime-a.admittime))/60/60/24) :: NUMERIC, 4) as hosp_los, 
                    p.gender, 
                    round((EXTRACT(EPOCH FROM (a.admittime-p.dob))/60/60/24/365.242) :: NUMERIC, 4) as age_hosp_in,
                    round((EXTRACT(EPOCH FROM (i.intime-p.dob))/60/60/24/365.242) :: NUMERIC, 4) as age_icu_in,
                    hospital_expire_flag,
                    CASE WHEN p.dod IS NOT NULL 
                        AND p.dod >= i.intime - interval '6 hour'
                        AND p.dod <= i.outtime + interval '6 hour' THEN 1 
                        ELSE 0 END AS icu_expire_flag
                FROM admissions a
                INNER JOIN icustays i
                ON a.hadm_id = i.hadm_id
                INNER JOIN patients p
                ON a.subject_id = p.subject_id
                ORDER BY a.subject_id, i.intime)
            SELECT round(avg(age_icu_in)) as avg_age_icu, 
                   round(avg(hosp_los)) as avg_los_hosp, 
                   round(avg(icu_los)) as avg_los_icu
            FROM icuadmissions;
            """
            queryresult = pd.read_sql_query(query,self.con)
            self.assertEqual(queryresult['avg_age_icu'].values[0][0],65)
            self.assertEqual(queryresult['avg_los_hosp'].values[0][0],11)
            self.assertEqual(queryresult['avg_los_icu'].values[0][0],5)


def main():
    unittest.main()

if __name__ == '__main__':
    main()
