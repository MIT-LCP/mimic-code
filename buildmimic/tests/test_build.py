import unittest
import psycopg2
import pandas as pd
import os


# Fail test on os.system failure: https://github.com/Amber-MD/pytraj/issues/238
os.system("psql -c 'create database mimic_test;' -U postgres")
# os.system("psql -c 'create schema mimiciii;' -d mimic_test -U postgres")
# os.system("psql -f './buildmimic/postgres/postgres_create_tables.sql' -U mimic")
os.system("psql -f './buildmimic/postgres/testddl.sql' -U postgres")

conn = psycopg2.connect("dbname='mimic_test' user='postgres' host='localhost'")

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