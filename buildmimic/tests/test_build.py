import unittest
import psycopg2
import pandas as pd
import os

# Config
sqluser = 'postgres'
dbname = 'mimic_test_db'
hostname = 'localhost'

# Set paths:
parentpath = os.path.join(os.path.dirname(__file__) + "/../") + '/'
curpath = os.path.join(os.path.dirname(__file__)) + '/'
sqlpath = curpath + "'testddl.sql'"

# Create the database and import the data
# Fail test on os.system failure: https://github.com/Amber-MD/pytraj/issues/238
os.system("psql -c 'create database " + dbname + ";' -U " + sqluser)
psqlcommand = "psql -f " + sqlpath + " -U " + sqluser + " --variable=mimic_data_dir=" + curpath 
psqlcommand = "psql -f " + parentpath + "postgres/postgres_create_tables.sql -U " + sqluser + " --variable=mimic_data_dir=" + curpath + "testdata/"
os.system(psqlcommand)

# Set up a database connection and query the data
conn = psycopg2.connect("dbname='" + dbname + 
                        "' user='" + sqluser + 
                        "' host='" + hostname + 
                        "'")

test_query = """
SELECT 'hello world';
"""

testq = pd.read_sql_query(test_query,conn)

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