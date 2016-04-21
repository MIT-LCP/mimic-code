import unittest
import pandas as pd
import os
from subprocess import call
import MySQLdb

# Config
sqluser = 'root'
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

def run_mysql_build_scripts(cur):
    # Create tables and loads data
    fn = curpath + '../buildmimic/mysql/1-define.sql'
    cur.execute(open(fn, "r").read())
    if os.environ.has_key('USER') and os.environ['USER'] == 'jenkins': 
        # use full dataset
        mimic_data_dir = '/home/mimicadmin/data/mimiciii_1_3/'
    else: 
        mimic_data_dir = curpath+datadir
    call(['mysql','-f',fn,'-d',testdbname,'-U',sqluser,'-v','mimic_data_dir='+mimic_data_dir])
    # # Add constraints
    # fn = curpath + '../buildmimic/mysql/3-constraints.sql'
    # cur.execute(open(fn, "r").read())
    # # Add indexes
    # fn = curpath + '../buildmimic/mysql/2-indexes.sql'
    # cur.execute(open(fn, "r").read())
    pass


# Class to run unit tests
class test_mysql(unittest.TestCase):
    # setUpClass runs once for the class
    @classmethod
    def setUpClass(cls):
        # Connect to default mysql database
        cls.con = MySQLdb.connect(host=hostname, user=sqluser)
        cls.cur = cls.con.cursor()
        # Create test database
        try: 
            cls.cur.execute('DROP DATABASE ' + testdbname)
        except MySQLdb.OperationalError:
            pass
        cls.cur.execute('CREATE DATABASE ' + testdbname)
        cls.cur.close()
        cls.con.close()
        # Connect to the test database
        cls.con = MySQLdb.connect(db=testdbname, user=sqluser)
        cls.cur = cls.con.cursor()
        # Build the test database
        # run_mysql_build_scripts(cls.cur)
        cls.cur.close()
        cls.con.close()

    # tearDownClass runs once for the class
    @classmethod
    def tearDownClass(cls):
        # Connect to default mysql database
        cls.con = MySQLdb.connect(host=hostname, user=sqluser)
        cls.cur = cls.con.cursor()
        # Drop test database
        cls.cur.execute('DROP DATABASE ' + testdbname)
        cls.cur.close()
        cls.con.close()

    # setUp runs once for each test method
    def setUp(self):
        # Connect to the test database
        self.con = MySQLdb.connect(db=testdbname, user=sqluser)
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

    # def test_testddl(self):
    #     # Creates and drops an example schema and table
    #     fn = curpath + 'testddl.sql'
    #     self.cur.execute(open(fn, "r").read())
    #     # self.assertEqual(1,1)

    # --------------------------------------------------
    # Run a series of checks to ensure ITEMIDs are valid
    # All checks should return 0.
    # --------------------------------------------------


    # ----------------------------------------------------
    # RUN THE FOLLOWING TESTS ON THE FULL DATASET ONLY ---
    # ----------------------------------------------------

    # if os.environ.has_key('USER') and os.environ['USER'] == 'jenkins':
    #     def test_row_counts_are_as_expected(self):
    #         for tablename,expectedrows in row_dict.iteritems():
    #             query = "SELECT COUNT(*) FROM " + schema + "." + tablename + ";"
    #             queryresult = pd.read_sql_query(query,self.con)
    #             self.assertEqual(queryresult.values[0][0],expectedrows)

def main():
    unittest.main()

if __name__ == '__main__':
    main()
