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

# Connect to default postgres database
con = psycopg2.connect(dbname='postgres', user=sqluser, host=hostname)
con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
cur = con.cursor()

# Create test database
cur.execute('CREATE DATABASE ' + testdbname)
cur.close()
con.close()

# Connect to the test database
con = psycopg2.connect(dbname=testdbname, user=sqluser, host=hostname)
con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
cur = con.cursor()

# Run the test SQL script
fn = curpath + 'testddl.sql'
cur.execute(open(fn, "r").read())

# Run the PostgreSQL build scripts
fn = curpath + '../postgres/postgres_create_tables.sql'
cur.execute(open(fn, "r").read())

cur.close()
con.close()

# Run the database scripts
fn = curpath + '../postgres/postgres_load_data.sql'
call(['psql','-f',fn,'-d',testdbname,'-U',sqluser,'-v','mimic_data_dir='+curpath+'testdata/'])

# Sample test query
# test_query = """
# SELECT 'hello world';
# """
# testq = pd.read_sql_query(test_query,con)

# Here's our "unit".
def isodd(n):
    return n % 2 == 1

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
class isoddtests(unittest.TestCase):

    def testOne(self):
        self.failUnless(isodd(1))

    def testTwo(self):
        self.failIf(isodd(2))

def main():
    unittest.main()

if __name__ == '__main__':
    main()