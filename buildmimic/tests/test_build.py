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
datadir = 'testdata/'

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
    fn = curpath + '../postgres/postgres_create_tables.sql'
    cur.execute(open(fn, "r").read())
    # Add constraints
    fn = curpath + '../postgres/postgres_add_constraints.sql'
    cur.execute(open(fn, "r").read())
    # Add indexes
    fn = curpath + '../postgres/postgres_add_indexes.sql'
    cur.execute(open(fn, "r").read())
    # Loads data
    fn = curpath + '../postgres/postgres_load_data.sql'
    if os.environ.has_key('USER') and os.environ['USER'] == 'jenkins': 
        # use full dataset
        mimic_data_dir = '/home/mimicadmin/data/mimiciii_1_2/'
    else: 
        mimic_data_dir = curpath+datadir
    call(['psql','-f',fn,'-d',testdbname,'-U',sqluser,'-v','mimic_data_dir='+mimic_data_dir])

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

def main():
    unittest.main()

if __name__ == '__main__':
    main()
