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

# Set paths for scripts to be tested
curpath = os.path.join(os.path.dirname(__file__)) + '/'

# Load build scripts
def executescripts(filename):
    # Open and read the file as a single buffer
    fd = open(filename, 'r')
    sqlFile = fd.read()
    fd.close()

    # all SQL commands (split on ';')
    sqlcommands = sqlFile.split(';')

    # Execute every command from the input file
    for command in sqlcommands:
        # This will skip and report errors
        # For example, if the tables do not yet exist, this will skip over
        # the DROP TABLE commands
        try:
            c.execute(command)
        except OperationalError, msg:
            print "Command skipped: ", msg


# Here's our "unit tests".
class test_postgres(unittest.TestCase):
    # setUpClass runs once for the class
    @classmethod
    def setUpClass(cls):
        # Connect to default postgres database
        cls.con = psycopg2.connect(dbname='postgres', user=sqluser, host=hostname)
        cls.con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cls.cur = cls.con.cursor()
        # Create test database
        cls.cur.execute('CREATE DATABASE ' + testdbname)
        cls.cur.close()
        cls.con.close()

    # tearDownClass runs once for the class
    @classmethod
    def tearDownClass(cls):
        # Connect to default postgres database
        cls.con = psycopg2.connect(dbname='postgres', user=sqluser, host=hostname)
        cls.con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cls.cur = cls.con.cursor()
        # Create test database
        cls.cur.execute('DROP DATABASE ' + testdbname)
        cls.cur.close()
        cls.con.close()

    # setUp runs once for each test method
    def setUp(self):
        # Connect to the test database
        self.con = psycopg2.connect(dbname=testdbname, user=sqluser, host=hostname)
        self.con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        self.cur = self.con.cursor()

    # tearDown runs once for each test method
    def tearDown(self):
        self.cur.close()
        self.con.close()

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

    def test_build_mimic(self):
        # Create tables
        fn = curpath + '../postgres/postgres_create_tables.sql'
        self.cur.execute(open(fn, "r").read())
        # Add constraints
        fn = curpath + '../postgres/postgres_add_constraints.sql'
        self.cur.execute(open(fn, "r").read())
        # Add indexes
        fn = curpath + '../postgres/postgres_add_indexes.sql'
        self.cur.execute(open(fn, "r").read())
        # Loads data
        fn = curpath + '../postgres/postgres_load_data.sql'
        call(['psql','-f',fn,'-d',testdbname,'-U',sqluser,'-v','mimic_data_dir='+curpath+'testdata/'])
        # Expect something...
        # self.assertEqual(1,1)

def main():
    unittest.main()

if __name__ == '__main__':
    main()