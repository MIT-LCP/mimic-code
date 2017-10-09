import unittest
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import pandas as pd
import os
import subprocess
import glob

# Class to run unit tests
class test_postgres(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        """
        setUpClass runs once for the class
        """
        # database config
        cls.db = {}
        cls.db['user'] = 'postgres'
        cls.db['name'] = 'mimic_test_db'
        cls.db['host'] = 'localhost'
        cls.db['schema'] = 'mimiciii'

        # paths
        cls.paths = {}
        cls.paths['home'] = os.getenv('HOME')
        cls.paths['cwd'] = os.getcwd()
        cls.paths['data'] = os.path.join(cls.paths['cwd'], 'tests', 'travisdata/')
        cls.paths['build'] = os.path.join(cls.paths['cwd'],'buildmimic','postgres/')

        # physionet
        pn = {}
        pn['u'] = os.environ['PN_US']
        pn['p'] = os.environ['PN_P']
        pn['url'] = 'https://physionet.org/works/MIMICIIIClinicalDatabaseDemo/'

        # environment variables
        print('\n    {} \n'.format(os.environ))

        # get the demo dataset
        get_demo = 'wget --user {} --password {} -P {} -A csv.gz -m -p -E -k -K -np -q -nd {}'.format(pn['u'],
            pn['p'], cls.paths['data'], pn['url'])

        subprocess.call(get_demo, shell=True, cwd=cls.paths['build'])

        # Create mimic user
        make_user = 'make create-user DBNAME={}'.format(cls.db['name'])
        subprocess.call(make_user, shell=True, cwd=cls.paths['build'])

        # Build MIMIC demo
        make_mimic = 'make mimic-gz datadir={} DBNAME={}'.format(cls.paths['data'], cls.db['name'])
        subprocess.call(make_mimic, shell=True, cwd=cls.paths['build'])

    @classmethod
    def tearDownClass(cls):
        """
        tearDownClass runs once for the class
        """

        # delete the data files
        files = glob.glob(os.path.join(cls.paths['data'],'*'))
        for f in files:
            os.remove(f)
        os.rmdir(cls.paths['data'])

        # # Drop test database
        # cls.con = psycopg2.connect(dbname=cls.db['name'], user=cls.db['user'])
        # cls.con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        # cls.cur = con.cursor()
        # cls.cur.execute('DROP DATABASE ' + testdbname)
        # cls.cur.close()
        # cls.con.close()

    def setUp(self):
        """
        setUp runs once for each test method
        """
        self.con = psycopg2.connect(dbname=self.db['name'], user=self.db['user'])
        self.con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        self.cur = self.con.cursor()

    def tearDown(self):
        """
        tearDown runs once for each test method
        """
        self.cur.close()
        self.con.close()

    def test_hello_world(self):
        """
        Just a little hello world.
        """
        print('hello world')

    def test_run_hello_world_query_to_test_db_con(self):
        """
        Just another little hello world.
        """
        test_query = """
        SELECT 'another hello world';
        """
        hello_world = pd.read_sql_query(test_query,self.con)
        self.assertEqual(hello_world.values[0][0],'another hello world')

    def test_SELECT_min_subject_id(self):
        """
        Minimum subject_id in the demo is 10006
        """
        test_query = """
        SELECT min(subject_id)
        FROM {}.patients;
        """.format(self.db['schema'])

        min_id = pd.read_sql_query(test_query,self.con)
        print(min_id.values[0][0])
        self.assertEqual(min_id.values[0][0],10006)

    # The MIMIC test db has been created by this point
    # Add unit tests below

    # --------------------------------------------------
    # Run a series of checks to ensure ITEMIDs are valid
    # All checks should return 0.
    # --------------------------------------------------

    def test_itemids_in_inputevents_cv_are_shifted(self):
        """
        Number of ITEMIDs which were erroneously left as original value
        """
        query = """
        SELECT COUNT(*) FROM {}.inputevents_cv
        WHERE itemid < 30000;
        """.format(self.db['schema'])

        queryresult = pd.read_sql_query(query,self.con)
        self.assertEqual(queryresult.values[0][0],0)

    def test_itemids_in_inputevents_mv_are_shifted(self):
        """
        Number of ITEMIDs which were erroneously left as original value
        """
        query = """
        SELECT COUNT(*) FROM {}.inputevents_mv
        WHERE itemid < 220000;
        """.format(self.db['schema'])

        queryresult = pd.read_sql_query(query,self.con)
        self.assertEqual(queryresult.values[0][0],0)

    def test_itemids_in_outputevents_are_shifted(self):
        """
        Number of ITEMIDs which were erroneously left as original value
        """
        query = """
        SELECT COUNT(*) FROM {}.outputevents
        WHERE itemid < 30000;
        """.format(self.db['schema'])

        queryresult = pd.read_sql_query(query,self.con)
        self.assertEqual(queryresult.values[0][0],0)

    def test_itemids_in_inputevents_cv_are_in_range(self):
        """
        Number of ITEMIDs which are above the allowable range
        """
        query = """
        SELECT COUNT(*) FROM {}.inputevents_cv
        WHERE itemid > 50000;
        """.format(self.db['schema'])

        queryresult = pd.read_sql_query(query,self.con)
        self.assertEqual(queryresult.values[0][0],0)

    def test_itemids_in_outputevents_are_in_range(self):
        """
        Number of ITEMIDs which are not in the allowable range
        """
        query = """
        SELECT COUNT(*) FROM {}.outputevents
        WHERE itemid > 50000 AND itemid < 220000;
        """.format(self.db['schema'])

        queryresult = pd.read_sql_query(query,self.con)
        self.assertEqual(queryresult.values[0][0],0)

    def test_itemids_in_chartevents_are_in_range(self):
        """
        Number of ITEMIDs which are not in the allowable range
        """
        query = """
        SELECT COUNT(*) FROM {}.chartevents
        WHERE itemid > 20000 AND itemid < 220000;
        """.format(self.db['schema'])

        queryresult = pd.read_sql_query(query,self.con)
        self.assertEqual(queryresult.values[0][0],0)

    def test_itemids_in_procedureevents_mv_are_in_range(self):
        """
        Number of ITEMIDs which are not in the allowable range
        """
        query = """
        SELECT COUNT(*) FROM {}.procedureevents_mv
        WHERE itemid < 220000;
        """.format(self.db['schema'])

        queryresult = pd.read_sql_query(query,self.con)
        self.assertEqual(queryresult.values[0][0],0)

    def test_itemids_in_labevents_are_in_range(self):
        """
        Number of ITEMIDs which are not in the allowable range
        """
        query = """
        SELECT COUNT(*) FROM {}.labevents
        WHERE itemid < 50000 OR itemid > 60000;
        """.format(self.db['schema'])

        queryresult = pd.read_sql_query(query,self.con)
        self.assertEqual(queryresult.values[0][0],0)

    def test_itemids_in_microbiologyevents_are_in_range(self):
        """
        Number of ITEMIDs which are not in the allowable range
        """
        query = """
        SELECT COUNT(*) FROM {}.microbiologyevents
        WHERE SPEC_ITEMID < 70000 OR SPEC_ITEMID > 80000
        OR ORG_ITEMID < 80000 OR ORG_ITEMID > 90000
        OR AB_ITEMID < 90000 OR AB_ITEMID > 100000;
        """.format(self.db['schema'])

        queryresult = pd.read_sql_query(query,self.con)
        self.assertEqual(queryresult.values[0][0],0)

def main():
    unittest.main()

if __name__ == '__main__':
    main()
