import unittest
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import pandas as pd
import os
from subprocess import call

# Config
sqluser = 'postgres'
testdbname = 'mimic_test_db'
hostname = 'localhost'
datadir = 'testdata/v1_3/'

# Set paths for scripts to be tested
curpath = os.path.join(os.path.dirname(__file__)) + '/'

# Display environment variables
print(os.environ)

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
        mimic_data_dir = '/home/mimicadmin/data/mimiciii_1_2/'
    else: 
        mimic_data_dir = curpath+datadir
    call(['psql','-f',fn,'-d',testdbname,'-U',sqluser,'-v','mimic_data_dir='+mimic_data_dir])
    # Add constraints
    fn = curpath + '../buildmimic/postgres/postgres_add_constraints.sql'
    cur.execute(open(fn, "r").read())
    # Add indexes
    fn = curpath + '../buildmimic/postgres/postgres_add_indexes.sql'
    cur.execute(open(fn, "r").read())

# Class to run unit tests
class test_postgres(unittest.TestCase):
    # setUpClass runs once for the class
    @classmethod
    def setUpClass(cls):
        # Connect to default postgres database
        cls.con = psycopg2.connect(dbname='postgres', user=sqluser)
        cls.con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cls.cur = cls.con.cursor()
        # Create test database
        cls.cur.execute('CREATE DATABASE ' + testdbname)
        cls.cur.close()
        cls.con.close()
        # Connect to the test database
        cls.con = psycopg2.connect(dbname=testdbname, user=sqluser)
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
        cls.con = psycopg2.connect(dbname='postgres', user=sqluser)
        cls.con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cls.cur = cls.con.cursor()
        # Drop test database
        cls.cur.execute('DROP DATABASE ' + testdbname)
        cls.cur.close()
        cls.con.close()

    # setUp runs once for each test method
    def setUp(self):
        # Connect to the test database
        self.con = psycopg2.connect(dbname=testdbname, user=sqluser)
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
            "NOTEEVENTS": 2053403,
            "OUTPUTEVENTS": 4349339,
            "PATIENTS": 46520,
            "PRESCRIPTIONS": 4156848,
            "PROCEDUREEVENTS_MV": 258066,
            "PROCEDURES_ICD": 240095,
            "SERVICES": 73343,
            "TRANSFERS": 261897 }
            for tablename,expectedrows in row_dict.iteritems():
                query = "SELECT COUNT(*) FROM " + tablename + ";"
                queryresult = pd.read_sql_query(query,self.con)
                self.assertEqual(queryresult.values[0][0],expectedrows)

def main():
    unittest.main()

if __name__ == '__main__':
    main()
