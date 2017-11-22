-- -------------------------------------------------------------------------------
--
-- Create the MIMIC-III tables
--
-- -------------------------------------------------------------------------------

--------------------------------------------------------
--  File created - Thursday-November-28-2015
--------------------------------------------------------

-- If running scripts individually, you can set the schema where all tables are created as follows:
-- SET search_path TO mimiciii;

-- Restoring the search path to its default value can be accomplished as follows:
--  SET search_path TO "$user",public;

/* Set the mimic_data_dir variable to point to directory containing
   all .csv files. If using Docker, this should not be changed here.
   Rather, when running the docker container, use the -v option
   to have Docker mount a host volume to the container path /mimic_data
   as explained in the README file
*/


--------------------------------------------------------
--  DDL for Table ADMISSIONS
--------------------------------------------------------

DROP TABLE IF EXISTS ADMISSIONS CASCADE;
CREATE TABLE ADMISSIONS
(
  ROW_ID INT NOT NULL,
  SUBJECT_ID INT NOT NULL,
  HADM_ID INT NOT NULL,
  ADMITTIME TIMESTAMP(0) NOT NULL,
  DISCHTIME TIMESTAMP(0) NOT NULL,
  DEATHTIME TIMESTAMP(0),
  ADMISSION_TYPE VARCHAR(50) NOT NULL,
  ADMISSION_LOCATION VARCHAR(50) NOT NULL,
  DISCHARGE_LOCATION VARCHAR(50) NOT NULL,
  INSURANCE VARCHAR(255) NOT NULL,
  LANGUAGE VARCHAR(10),
  RELIGION VARCHAR(50),
  MARITAL_STATUS VARCHAR(50),
  ETHNICITY VARCHAR(200) NOT NULL,
  EDREGTIME TIMESTAMP(0),
  EDOUTTIME TIMESTAMP(0),
  DIAGNOSIS VARCHAR(255),
  HOSPITAL_EXPIRE_FLAG SMALLINT,
  HAS_CHARTEVENTS_DATA SMALLINT NOT NULL,
  CONSTRAINT adm_rowid_pk PRIMARY KEY (ROW_ID),
  CONSTRAINT adm_hadm_unique UNIQUE (HADM_ID)
) ;

--------------------------------------------------------
--  DDL for Table CALLOUT
--------------------------------------------------------

DROP TABLE IF EXISTS CALLOUT CASCADE;
CREATE TABLE CALLOUT
(
  ROW_ID INT NOT NULL,
  SUBJECT_ID INT NOT NULL,
  HADM_ID INT NOT NULL,
  SUBMIT_WARDID INT,
  SUBMIT_CAREUNIT VARCHAR(15),
  CURR_WARDID INT,
  CURR_CAREUNIT VARCHAR(15),
  CALLOUT_WARDID INT,
  CALLOUT_SERVICE VARCHAR(10) NOT NULL,
  REQUEST_TELE SMALLINT NOT NULL,
  REQUEST_RESP SMALLINT NOT NULL,
  REQUEST_CDIFF SMALLINT NOT NULL,
  REQUEST_MRSA SMALLINT NOT NULL,
  REQUEST_VRE SMALLINT NOT NULL,
  CALLOUT_STATUS VARCHAR(20) NOT NULL,
  CALLOUT_OUTCOME VARCHAR(20) NOT NULL,
  DISCHARGE_WARDID INT,
  ACKNOWLEDGE_STATUS VARCHAR(20) NOT NULL,
  CREATETIME TIMESTAMP(0) NOT NULL,
  UPDATETIME TIMESTAMP(0) NOT NULL,
  ACKNOWLEDGETIME TIMESTAMP(0),
  OUTCOMETIME TIMESTAMP(0) NOT NULL,
  FIRSTRESERVATIONTIME TIMESTAMP(0),
  CURRENTRESERVATIONTIME TIMESTAMP(0),
  CONSTRAINT callout_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table CAREGIVERS
--------------------------------------------------------

DROP TABLE IF EXISTS CAREGIVERS CASCADE;
CREATE TABLE CAREGIVERS
(
  ROW_ID INT NOT NULL,
	CGID INT NOT NULL,
	LABEL VARCHAR(15),
	DESCRIPTION VARCHAR(30),
	CONSTRAINT cg_rowid_pk  PRIMARY KEY (ROW_ID),
	CONSTRAINT cg_cgid_unique UNIQUE (CGID)
) ;

--------------------------------------------------------
--  DDL for Table CHARTEVENTS
--------------------------------------------------------

DROP TABLE IF EXISTS chartevents CASCADE;
CREATE TABLE chartevents
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT,
	ICUSTAY_ID INT,
	ITEMID INT,
	CHARTTIME TIMESTAMP(0),
	STORETIME TIMESTAMP(0),
	CGID INT,
	VALUE VARCHAR(255),
	VALUENUM DOUBLE PRECISION,
	VALUEUOM VARCHAR(50),
	WARNING INT,
	ERROR INT,
	RESULTSTATUS VARCHAR(50),
	STOPPED VARCHAR(50)
) PARTITION BY RANGE (itemid);

--------------------------------------------------------
--  PARTITION for Table CHARTEVENTS
--------------------------------------------------------


CREATE TABLE chartevents_1 PARTITION OF chartevents
    FOR VALUES FROM (1) TO (27); -- Percentage: 0.0 - Rows: 22204
CREATE TABLE chartevents_2 PARTITION OF chartevents
    FOR VALUES FROM (27) TO (28); -- Percentage: 0.2 - Rows: 737224
CREATE TABLE chartevents_3 PARTITION OF chartevents
    FOR VALUES FROM (28) TO (31); -- Percentage: 0.0 - Rows: 56235
CREATE TABLE chartevents_4 PARTITION OF chartevents
    FOR VALUES FROM (31) TO (32); -- Percentage: 0.4 - Rows: 1442406
CREATE TABLE chartevents_5 PARTITION OF chartevents
    FOR VALUES FROM (32) TO (33); -- Percentage: 0.3 - Rows: 878442
CREATE TABLE chartevents_6 PARTITION OF chartevents
    FOR VALUES FROM (33) TO (49); -- Percentage: 0.5 - Rows: 1659172
CREATE TABLE chartevents_7 PARTITION OF chartevents
    FOR VALUES FROM (49) TO (50); -- Percentage: 0.2 - Rows: 636690
CREATE TABLE chartevents_8 PARTITION OF chartevents
    FOR VALUES FROM (50) TO (51); -- Percentage: 0.1 - Rows: 285028
CREATE TABLE chartevents_9 PARTITION OF chartevents
    FOR VALUES FROM (51) TO (52); -- Percentage: 0.6 - Rows: 2096678
CREATE TABLE chartevents_10 PARTITION OF chartevents
    FOR VALUES FROM (52) TO (53); -- Percentage: 0.6 - Rows: 2072743
CREATE TABLE chartevents_11 PARTITION OF chartevents
    FOR VALUES FROM (53) TO (54); -- Percentage: 0.0 - Rows: 178
CREATE TABLE chartevents_12 PARTITION OF chartevents
    FOR VALUES FROM (54) TO (55); -- Percentage: 0.3 - Rows: 892239
CREATE TABLE chartevents_13 PARTITION OF chartevents
    FOR VALUES FROM (55) TO (80); -- Percentage: 0.4 - Rows: 1181039
CREATE TABLE chartevents_14 PARTITION OF chartevents
    FOR VALUES FROM (80) TO (81); -- Percentage: 0.3 - Rows: 1136214
CREATE TABLE chartevents_15 PARTITION OF chartevents
    FOR VALUES FROM (81) TO (113); -- Percentage: 1.0 - Rows: 3418901
CREATE TABLE chartevents_16 PARTITION OF chartevents
    FOR VALUES FROM (113) TO (114); -- Percentage: 0.4 - Rows: 1198681
CREATE TABLE chartevents_17 PARTITION OF chartevents
    FOR VALUES FROM (114) TO (128); -- Percentage: 0.3 - Rows: 1111444
CREATE TABLE chartevents_18 PARTITION OF chartevents
    FOR VALUES FROM (128) TO (129); -- Percentage: 1.0 - Rows: 3216866
CREATE TABLE chartevents_19 PARTITION OF chartevents
    FOR VALUES FROM (129) TO (154); -- Percentage: 0.5 - Rows: 1669170
CREATE TABLE chartevents_20 PARTITION OF chartevents
    FOR VALUES FROM (154) TO (155); -- Percentage: 0.2 - Rows: 818852
CREATE TABLE chartevents_21 PARTITION OF chartevents
    FOR VALUES FROM (155) TO (159); -- Percentage: 0.3 - Rows: 974476
CREATE TABLE chartevents_22 PARTITION OF chartevents
    FOR VALUES FROM (159) TO (160); -- Percentage: 0.8 - Rows: 2544519
CREATE TABLE chartevents_23 PARTITION OF chartevents
    FOR VALUES FROM (160) TO (161); -- Percentage: 0.0 - Rows: 9458
CREATE TABLE chartevents_24 PARTITION OF chartevents
    FOR VALUES FROM (161) TO (162); -- Percentage: 1.0 - Rows: 3236350
CREATE TABLE chartevents_25 PARTITION OF chartevents
    FOR VALUES FROM (162) TO (184); -- Percentage: 0.6 - Rows: 1837071
CREATE TABLE chartevents_26 PARTITION OF chartevents
    FOR VALUES FROM (184) TO (185); -- Percentage: 0.3 - Rows: 954139
CREATE TABLE chartevents_27 PARTITION OF chartevents
    FOR VALUES FROM (185) TO (198); -- Percentage: 0.4 - Rows: 1456328
CREATE TABLE chartevents_28 PARTITION OF chartevents
    FOR VALUES FROM (198) TO (199); -- Percentage: 0.3 - Rows: 945638
CREATE TABLE chartevents_29 PARTITION OF chartevents
    FOR VALUES FROM (199) TO (210); -- Percentage: 0.5 - Rows: 1545176
CREATE TABLE chartevents_30 PARTITION OF chartevents
    FOR VALUES FROM (210) TO (211); -- Percentage: 0.3 - Rows: 955452
CREATE TABLE chartevents_31 PARTITION OF chartevents
    FOR VALUES FROM (211) TO (212); -- Percentage: 1.6 - Rows: 5180809
CREATE TABLE chartevents_32 PARTITION OF chartevents
    FOR VALUES FROM (212) TO (213); -- Percentage: 1.0 - Rows: 3303151
CREATE TABLE chartevents_33 PARTITION OF chartevents
    FOR VALUES FROM (213) TO (250); -- Percentage: 1.1 - Rows: 3676785
CREATE TABLE chartevents_34 PARTITION OF chartevents
    FOR VALUES FROM (250) TO (425); -- Percentage: 2.4 - Rows: 7811955
CREATE TABLE chartevents_35 PARTITION OF chartevents
    FOR VALUES FROM (425) TO (426); -- Percentage: 0.2 - Rows: 783762
CREATE TABLE chartevents_36 PARTITION OF chartevents
    FOR VALUES FROM (426) TO (428); -- Percentage: 0.1 - Rows: 402022
CREATE TABLE chartevents_37 PARTITION OF chartevents
    FOR VALUES FROM (428) TO (429); -- Percentage: 0.2 - Rows: 786544
CREATE TABLE chartevents_38 PARTITION OF chartevents
    FOR VALUES FROM (429) TO (432); -- Percentage: 0.1 - Rows: 349997
CREATE TABLE chartevents_39 PARTITION OF chartevents
    FOR VALUES FROM (432) TO (433); -- Percentage: 0.3 - Rows: 1032728
CREATE TABLE chartevents_40 PARTITION OF chartevents
    FOR VALUES FROM (433) TO (454); -- Percentage: 0.5 - Rows: 1589945
CREATE TABLE chartevents_41 PARTITION OF chartevents
    FOR VALUES FROM (454) TO (455); -- Percentage: 0.3 - Rows: 950038
CREATE TABLE chartevents_42 PARTITION OF chartevents
    FOR VALUES FROM (455) TO (456); -- Percentage: 0.5 - Rows: 1579681
CREATE TABLE chartevents_43 PARTITION OF chartevents
    FOR VALUES FROM (456) TO (457); -- Percentage: 0.5 - Rows: 1553537
CREATE TABLE chartevents_44 PARTITION OF chartevents
    FOR VALUES FROM (457) TO (467); -- Percentage: 0.1 - Rows: 392595
CREATE TABLE chartevents_45 PARTITION OF chartevents
    FOR VALUES FROM (467) TO (468); -- Percentage: 0.3 - Rows: 1155571
CREATE TABLE chartevents_46 PARTITION OF chartevents
    FOR VALUES FROM (468) TO (478); -- Percentage: 0.3 - Rows: 985720
CREATE TABLE chartevents_47 PARTITION OF chartevents
    FOR VALUES FROM (478) TO (479); -- Percentage: 0.2 - Rows: 774157
CREATE TABLE chartevents_48 PARTITION OF chartevents
    FOR VALUES FROM (479) TO (480); -- Percentage: 0.3 - Rows: 917780
CREATE TABLE chartevents_49 PARTITION OF chartevents
    FOR VALUES FROM (480) TO (547); -- Percentage: 1.4 - Rows: 4595328
CREATE TABLE chartevents_50 PARTITION OF chartevents
    FOR VALUES FROM (547) TO (548); -- Percentage: 0.3 - Rows: 852968
CREATE TABLE chartevents_51 PARTITION OF chartevents
    FOR VALUES FROM (548) TO (550); -- Percentage: 0.3 - Rows: 883558
CREATE TABLE chartevents_52 PARTITION OF chartevents
    FOR VALUES FROM (550) TO (551); -- Percentage: 1.0 - Rows: 3205052
CREATE TABLE chartevents_53 PARTITION OF chartevents
    FOR VALUES FROM (551) TO (581); -- Percentage: 0.3 - Rows: 1022222
CREATE TABLE chartevents_54 PARTITION OF chartevents
    FOR VALUES FROM (581) TO (582); -- Percentage: 0.5 - Rows: 1641889
CREATE TABLE chartevents_55 PARTITION OF chartevents
    FOR VALUES FROM (582) TO (593); -- Percentage: 0.5 - Rows: 1654497
CREATE TABLE chartevents_56 PARTITION OF chartevents
    FOR VALUES FROM (593) TO (594); -- Percentage: 0.2 - Rows: 784361
CREATE TABLE chartevents_57 PARTITION OF chartevents
    FOR VALUES FROM (594) TO (599); -- Percentage: 0.3 - Rows: 913144
CREATE TABLE chartevents_58 PARTITION OF chartevents
    FOR VALUES FROM (599) TO (600); -- Percentage: 0.2 - Rows: 787137
CREATE TABLE chartevents_59 PARTITION OF chartevents
    FOR VALUES FROM (600) TO (614); -- Percentage: 0.4 - Rows: 1251345
CREATE TABLE chartevents_60 PARTITION OF chartevents
    FOR VALUES FROM (614) TO (617); -- Percentage: 0.2 - Rows: 774906
CREATE TABLE chartevents_61 PARTITION OF chartevents
    FOR VALUES FROM (617) TO (618); -- Percentage: 0.3 - Rows: 962191
CREATE TABLE chartevents_62 PARTITION OF chartevents
    FOR VALUES FROM (618) TO (619); -- Percentage: 1.0 - Rows: 3386719
CREATE TABLE chartevents_63 PARTITION OF chartevents
    FOR VALUES FROM (619) TO (621); -- Percentage: 0.2 - Rows: 580529
CREATE TABLE chartevents_64 PARTITION OF chartevents
    FOR VALUES FROM (621) TO (622); -- Percentage: 0.2 - Rows: 666496
CREATE TABLE chartevents_65 PARTITION OF chartevents
    FOR VALUES FROM (622) TO (637); -- Percentage: 0.6 - Rows: 2048955
CREATE TABLE chartevents_66 PARTITION OF chartevents
    FOR VALUES FROM (637) TO (638); -- Percentage: 0.3 - Rows: 954354
CREATE TABLE chartevents_67 PARTITION OF chartevents
    FOR VALUES FROM (638) TO (640); -- Percentage: 0.0 - Rows: 437
CREATE TABLE chartevents_68 PARTITION OF chartevents
    FOR VALUES FROM (640) TO (646); -- Percentage: 0.4 - Rows: 1447426
CREATE TABLE chartevents_69 PARTITION OF chartevents
    FOR VALUES FROM (646) TO (647); -- Percentage: 1.0 - Rows: 3418917
CREATE TABLE chartevents_70 PARTITION OF chartevents
    FOR VALUES FROM (647) TO (663); -- Percentage: 0.6 - Rows: 2135542
CREATE TABLE chartevents_71 PARTITION OF chartevents
    FOR VALUES FROM (663) TO (664); -- Percentage: 0.2 - Rows: 774213
CREATE TABLE chartevents_72 PARTITION OF chartevents
    FOR VALUES FROM (664) TO (674); -- Percentage: 0.1 - Rows: 300570
CREATE TABLE chartevents_73 PARTITION OF chartevents
    FOR VALUES FROM (674) TO (675); -- Percentage: 0.3 - Rows: 1042512
CREATE TABLE chartevents_74 PARTITION OF chartevents
    FOR VALUES FROM (675) TO (677); -- Percentage: 0.1 - Rows: 378549
CREATE TABLE chartevents_75 PARTITION OF chartevents
    FOR VALUES FROM (677) TO (678); -- Percentage: 0.2 - Rows: 772277
CREATE TABLE chartevents_76 PARTITION OF chartevents
    FOR VALUES FROM (678) TO (679); -- Percentage: 0.2 - Rows: 773891
CREATE TABLE chartevents_77 PARTITION OF chartevents
    FOR VALUES FROM (679) TO (680); -- Percentage: 0.1 - Rows: 376047
CREATE TABLE chartevents_78 PARTITION OF chartevents
    FOR VALUES FROM (680) TO (681); -- Percentage: 0.2 - Rows: 740176
CREATE TABLE chartevents_79 PARTITION OF chartevents
    FOR VALUES FROM (681) TO (704); -- Percentage: 0.3 - Rows: 1099236
CREATE TABLE chartevents_80 PARTITION OF chartevents
    FOR VALUES FROM (704) TO (705); -- Percentage: 0.3 - Rows: 933238
CREATE TABLE chartevents_81 PARTITION OF chartevents
    FOR VALUES FROM (705) TO (706); -- Percentage: 0.0 - Rows: 20754
CREATE TABLE chartevents_82 PARTITION OF chartevents
    FOR VALUES FROM (706) TO (707); -- Percentage: 0.2 - Rows: 727719
CREATE TABLE chartevents_83 PARTITION OF chartevents
    FOR VALUES FROM (707) TO (708); -- Percentage: 0.3 - Rows: 937064
CREATE TABLE chartevents_84 PARTITION OF chartevents
    FOR VALUES FROM (708) TO (723); -- Percentage: 0.3 - Rows: 1049706
CREATE TABLE chartevents_85 PARTITION OF chartevents
    FOR VALUES FROM (723) TO (724); -- Percentage: 0.3 - Rows: 952177
CREATE TABLE chartevents_86 PARTITION OF chartevents
    FOR VALUES FROM (724) TO (742); -- Percentage: 0.1 - Rows: 321012
CREATE TABLE chartevents_87 PARTITION OF chartevents
    FOR VALUES FROM (742) TO (743); -- Percentage: 1.0 - Rows: 3464326
CREATE TABLE chartevents_88 PARTITION OF chartevents
    FOR VALUES FROM (743) TO (834); -- Percentage: 1.8 - Rows: 5925297
CREATE TABLE chartevents_89 PARTITION OF chartevents
    FOR VALUES FROM (834) TO (835); -- Percentage: 0.5 - Rows: 1716561
CREATE TABLE chartevents_90 PARTITION OF chartevents
    FOR VALUES FROM (835) TO (1046); -- Percentage: 0.4 - Rows: 1417336
CREATE TABLE chartevents_91 PARTITION OF chartevents
    FOR VALUES FROM (1046) TO (1047); -- Percentage: 0.2 - Rows: 803816
CREATE TABLE chartevents_92 PARTITION OF chartevents
    FOR VALUES FROM (1047) TO (1087); -- Percentage: 0.1 - Rows: 423898
CREATE TABLE chartevents_93 PARTITION OF chartevents
    FOR VALUES FROM (1087) TO (1088); -- Percentage: 0.2 - Rows: 592344
CREATE TABLE chartevents_94 PARTITION OF chartevents
    FOR VALUES FROM (1088) TO (1125); -- Percentage: 0.1 - Rows: 250247
CREATE TABLE chartevents_95 PARTITION OF chartevents
    FOR VALUES FROM (1125) TO (1126); -- Percentage: 0.9 - Rows: 2955851
CREATE TABLE chartevents_96 PARTITION OF chartevents
    FOR VALUES FROM (1126) TO (1337); -- Percentage: 0.2 - Rows: 808725
CREATE TABLE chartevents_97 PARTITION OF chartevents
    FOR VALUES FROM (1337) TO (1338); -- Percentage: 0.3 - Rows: 1083809
CREATE TABLE chartevents_98 PARTITION OF chartevents
    FOR VALUES FROM (1338) TO (1484); -- Percentage: 0.4 - Rows: 1281335
CREATE TABLE chartevents_99 PARTITION OF chartevents
    FOR VALUES FROM (1484) TO (1485); -- Percentage: 0.7 - Rows: 2261065
CREATE TABLE chartevents_100 PARTITION OF chartevents
    FOR VALUES FROM (1485) TO (1703); -- Percentage: 1.1 - Rows: 3561885
CREATE TABLE chartevents_101 PARTITION OF chartevents
    FOR VALUES FROM (1703) TO (1704); -- Percentage: 0.4 - Rows: 1174868
CREATE TABLE chartevents_102 PARTITION OF chartevents
    FOR VALUES FROM (1704) TO (1800); -- Percentage: 0.1 - Rows: 293325
CREATE TABLE chartevents_103 PARTITION OF chartevents
    FOR VALUES FROM (1800) TO (2500); -- Percentage: 0.1 - Rows: 249776
CREATE TABLE chartevents_104 PARTITION OF chartevents
    FOR VALUES FROM (2500) TO (3327); -- Percentage: 0.9 - Rows: 3010424
CREATE TABLE chartevents_105 PARTITION OF chartevents
    FOR VALUES FROM (3327) TO (3328); -- Percentage: 0.2 - Rows: 679113
CREATE TABLE chartevents_106 PARTITION OF chartevents
    FOR VALUES FROM (3328) TO (3420); -- Percentage: 1.6 - Rows: 5208156
CREATE TABLE chartevents_107 PARTITION OF chartevents
    FOR VALUES FROM (3420) TO (3421); -- Percentage: 0.2 - Rows: 673719
CREATE TABLE chartevents_108 PARTITION OF chartevents
    FOR VALUES FROM (3421) TO (3450); -- Percentage: 0.8 - Rows: 2785057
CREATE TABLE chartevents_109 PARTITION OF chartevents
    FOR VALUES FROM (3450) TO (3451); -- Percentage: 0.5 - Rows: 1687886
CREATE TABLE chartevents_110 PARTITION OF chartevents
    FOR VALUES FROM (3451) TO (3500); -- Percentage: 0.7 - Rows: 2445808
CREATE TABLE chartevents_111 PARTITION OF chartevents
    FOR VALUES FROM (3500) TO (3550); -- Percentage: 0.7 - Rows: 2433936
CREATE TABLE chartevents_112 PARTITION OF chartevents
    FOR VALUES FROM (3550) TO (3603); -- Percentage: 1.3 - Rows: 4449487
CREATE TABLE chartevents_113 PARTITION OF chartevents
    FOR VALUES FROM (3603) TO (3604); -- Percentage: 0.5 - Rows: 1676872
CREATE TABLE chartevents_114 PARTITION OF chartevents
    FOR VALUES FROM (3604) TO (3609); -- Percentage: 0.1 - Rows: 476670
CREATE TABLE chartevents_115 PARTITION OF chartevents
    FOR VALUES FROM (3609) TO (3610); -- Percentage: 0.5 - Rows: 1621393
CREATE TABLE chartevents_116 PARTITION OF chartevents
    FOR VALUES FROM (3610) TO (3645); -- Percentage: 0.7 - Rows: 2309226
CREATE TABLE chartevents_117 PARTITION OF chartevents
    FOR VALUES FROM (3645) TO (3646); -- Percentage: 0.2 - Rows: 690295
CREATE TABLE chartevents_118 PARTITION OF chartevents
    FOR VALUES FROM (3646) TO (3656); -- Percentage: 0.3 - Rows: 1009254
CREATE TABLE chartevents_119 PARTITION OF chartevents
    FOR VALUES FROM (3656) TO (3657); -- Percentage: 0.2 - Rows: 803881
CREATE TABLE chartevents_120 PARTITION OF chartevents
    FOR VALUES FROM (3657) TO (3700); -- Percentage: 0.7 - Rows: 2367096
CREATE TABLE chartevents_121 PARTITION OF chartevents
    FOR VALUES FROM (3700) TO (5813); -- Percentage: 0.4 - Rows: 1360432
CREATE TABLE chartevents_122 PARTITION OF chartevents
    FOR VALUES FROM (5813) TO (5814); -- Percentage: 0.3 - Rows: 982518
CREATE TABLE chartevents_123 PARTITION OF chartevents
    FOR VALUES FROM (5814) TO (5815); -- Percentage: 0.2 - Rows: 655454
CREATE TABLE chartevents_124 PARTITION OF chartevents
    FOR VALUES FROM (5815) TO (5816); -- Percentage: 0.5 - Rows: 1807316
CREATE TABLE chartevents_125 PARTITION OF chartevents
    FOR VALUES FROM (5816) TO (5817); -- Percentage: 0.0 - Rows: 34909
CREATE TABLE chartevents_126 PARTITION OF chartevents
    FOR VALUES FROM (5817) TO (5818); -- Percentage: 0.4 - Rows: 1378959
CREATE TABLE chartevents_127 PARTITION OF chartevents
    FOR VALUES FROM (5818) TO (5819); -- Percentage: 0.1 - Rows: 178112
CREATE TABLE chartevents_128 PARTITION OF chartevents
    FOR VALUES FROM (5819) TO (5820); -- Percentage: 0.5 - Rows: 1772387
CREATE TABLE chartevents_129 PARTITION OF chartevents
    FOR VALUES FROM (5820) TO (5821); -- Percentage: 0.5 - Rows: 1802684
CREATE TABLE chartevents_130 PARTITION OF chartevents
    FOR VALUES FROM (5821) TO (8000); -- Percentage: 0.5 - Rows: 1622363
CREATE TABLE chartevents_131 PARTITION OF chartevents
    FOR VALUES FROM (8000) TO (8367); -- Percentage: 0.0 - Rows: 43749
CREATE TABLE chartevents_132 PARTITION OF chartevents
    FOR VALUES FROM (8367) TO (8368); -- Percentage: 0.2 - Rows: 601818
CREATE TABLE chartevents_133 PARTITION OF chartevents
    FOR VALUES FROM (8368) TO (8369); -- Percentage: 0.6 - Rows: 2085994
CREATE TABLE chartevents_134 PARTITION OF chartevents
    FOR VALUES FROM (8369) TO (8441); -- Percentage: 1.6 - Rows: 5266438
CREATE TABLE chartevents_135 PARTITION OF chartevents
    FOR VALUES FROM (8441) TO (8442); -- Percentage: 0.5 - Rows: 1573583
CREATE TABLE chartevents_136 PARTITION OF chartevents
    FOR VALUES FROM (8442) TO (8480); -- Percentage: 1.2 - Rows: 3870155
CREATE TABLE chartevents_137 PARTITION OF chartevents
    FOR VALUES FROM (8480) TO (8481); -- Percentage: 0.2 - Rows: 719203
CREATE TABLE chartevents_138 PARTITION OF chartevents
    FOR VALUES FROM (8481) TO (8518); -- Percentage: 0.5 - Rows: 1600973
CREATE TABLE chartevents_139 PARTITION OF chartevents
    FOR VALUES FROM (8518) TO (8519); -- Percentage: 0.5 - Rows: 1687615
CREATE TABLE chartevents_140 PARTITION OF chartevents
    FOR VALUES FROM (8519) TO (8532); -- Percentage: 0.3 - Rows: 1146136
CREATE TABLE chartevents_141 PARTITION OF chartevents
    FOR VALUES FROM (8532) TO (8533); -- Percentage: 0.5 - Rows: 1619782
CREATE TABLE chartevents_142 PARTITION OF chartevents
    FOR VALUES FROM (8533) TO (8537); -- Percentage: 0.1 - Rows: 204405
CREATE TABLE chartevents_143 PARTITION OF chartevents
    FOR VALUES FROM (8537) TO (8538); -- Percentage: 0.2 - Rows: 725866
CREATE TABLE chartevents_144 PARTITION OF chartevents
    FOR VALUES FROM (8538) TO (8547); -- Percentage: 0.0 - Rows: 302
CREATE TABLE chartevents_145 PARTITION OF chartevents
    FOR VALUES FROM (8547) TO (8548); -- Percentage: 0.3 - Rows: 976252
CREATE TABLE chartevents_146 PARTITION OF chartevents
    FOR VALUES FROM (8548) TO (8549); -- Percentage: 0.2 - Rows: 649745
CREATE TABLE chartevents_147 PARTITION OF chartevents
    FOR VALUES FROM (8549) TO (8550); -- Percentage: 0.5 - Rows: 1804988
CREATE TABLE chartevents_148 PARTITION OF chartevents
    FOR VALUES FROM (8550) TO (8551); -- Percentage: 0.0 - Rows: 33554
CREATE TABLE chartevents_149 PARTITION OF chartevents
    FOR VALUES FROM (8551) TO (8552); -- Percentage: 0.4 - Rows: 1375295
CREATE TABLE chartevents_150 PARTITION OF chartevents
    FOR VALUES FROM (8552) TO (8553); -- Percentage: 0.1 - Rows: 174222
CREATE TABLE chartevents_151 PARTITION OF chartevents
    FOR VALUES FROM (8553) TO (8554); -- Percentage: 0.5 - Rows: 1769925
CREATE TABLE chartevents_152 PARTITION OF chartevents
    FOR VALUES FROM (8554) TO (8555); -- Percentage: 0.5 - Rows: 1796313
CREATE TABLE chartevents_153 PARTITION OF chartevents
    FOR VALUES FROM (8555) TO (220000); -- Percentage: 0.0 - Rows: 18753
CREATE TABLE chartevents_154 PARTITION OF chartevents
    FOR VALUES FROM (220000) TO (220045); -- Percentage:  - Rows:
CREATE TABLE chartevents_155 PARTITION OF chartevents
    FOR VALUES FROM (220045) TO (220046); -- Percentage: 0.8 - Rows: 2762225
CREATE TABLE chartevents_156 PARTITION OF chartevents
    FOR VALUES FROM (220046) TO (220048); -- Percentage: 0.1 - Rows: 431909
CREATE TABLE chartevents_157 PARTITION OF chartevents
    FOR VALUES FROM (220048) TO (220049); -- Percentage: 0.6 - Rows: 2023672
CREATE TABLE chartevents_158 PARTITION OF chartevents
    FOR VALUES FROM (220049) TO (220050); -- Percentage:  - Rows:
CREATE TABLE chartevents_159 PARTITION OF chartevents
    FOR VALUES FROM (220050) TO (220051); -- Percentage: 0.3 - Rows: 1149788
CREATE TABLE chartevents_160 PARTITION OF chartevents
    FOR VALUES FROM (220051) TO (220052); -- Percentage: 0.3 - Rows: 1149537
CREATE TABLE chartevents_161 PARTITION OF chartevents
    FOR VALUES FROM (220052) TO (220053); -- Percentage: 0.3 - Rows: 1156173
CREATE TABLE chartevents_162 PARTITION OF chartevents
    FOR VALUES FROM (220053) TO (220074); -- Percentage: 0.2 - Rows: 648200
CREATE TABLE chartevents_163 PARTITION OF chartevents
    FOR VALUES FROM (220074) TO (220179); -- Percentage: 0.2 - Rows: 526472
CREATE TABLE chartevents_164 PARTITION OF chartevents
    FOR VALUES FROM (220179) TO (220180); -- Percentage: 0.4 - Rows: 1290488
CREATE TABLE chartevents_165 PARTITION OF chartevents
    FOR VALUES FROM (220180) TO (220181); -- Percentage: 0.4 - Rows: 1289885
CREATE TABLE chartevents_166 PARTITION OF chartevents
    FOR VALUES FROM (220181) TO (220182); -- Percentage: 0.4 - Rows: 1292916
CREATE TABLE chartevents_167 PARTITION OF chartevents
    FOR VALUES FROM (220182) TO (220210); -- Percentage: 0.0 - Rows: 208
CREATE TABLE chartevents_168 PARTITION OF chartevents
    FOR VALUES FROM (220210) TO (220211); -- Percentage: 0.8 - Rows: 2737105
CREATE TABLE chartevents_169 PARTITION OF chartevents
    FOR VALUES FROM (220211) TO (220277); -- Percentage: 0.1 - Rows: 466344
CREATE TABLE chartevents_170 PARTITION OF chartevents
    FOR VALUES FROM (220277) TO (220278); -- Percentage: 0.8 - Rows: 2671816
CREATE TABLE chartevents_171 PARTITION OF chartevents
    FOR VALUES FROM (220278) TO (222000); -- Percentage: 1.0 - Rows: 3262258
CREATE TABLE chartevents_172 PARTITION OF chartevents
    FOR VALUES FROM (222000) TO (223792); -- Percentage: 1.2 - Rows: 4068153
CREATE TABLE chartevents_173 PARTITION OF chartevents
    FOR VALUES FROM (223792) TO (223793); -- Percentage: 0.2 - Rows: 765274
CREATE TABLE chartevents_174 PARTITION OF chartevents
    FOR VALUES FROM (223793) TO (223800); -- Percentage: 0.3 - Rows: 1139355
CREATE TABLE chartevents_175 PARTITION OF chartevents
    FOR VALUES FROM (223800) TO (223850); -- Percentage: 0.6 - Rows: 1983602
CREATE TABLE chartevents_176 PARTITION OF chartevents
    FOR VALUES FROM (223850) TO (223900); -- Percentage: 0.7 - Rows: 2185541
CREATE TABLE chartevents_177 PARTITION OF chartevents
    FOR VALUES FROM (223900) TO (223912); -- Percentage: 1.1 - Rows: 3552998
CREATE TABLE chartevents_178 PARTITION OF chartevents
    FOR VALUES FROM (223912) TO (223925); -- Percentage: 0.7 - Rows: 2289753
CREATE TABLE chartevents_179 PARTITION OF chartevents
    FOR VALUES FROM (223925) TO (223950); -- Percentage: 0.5 - Rows: 1610057
CREATE TABLE chartevents_180 PARTITION OF chartevents
    FOR VALUES FROM (223950) TO (223974); -- Percentage: 0.1 - Rows: 395061
CREATE TABLE chartevents_181 PARTITION OF chartevents
    FOR VALUES FROM (223974) TO (224000); -- Percentage: 1.5 - Rows: 4797667
CREATE TABLE chartevents_182 PARTITION OF chartevents
    FOR VALUES FROM (224000) TO (224020); -- Percentage: 1.0 - Rows: 3317320
CREATE TABLE chartevents_183 PARTITION OF chartevents
    FOR VALUES FROM (224020) TO (224040); -- Percentage: 0.8 - Rows: 2611372
CREATE TABLE chartevents_184 PARTITION OF chartevents
    FOR VALUES FROM (224040) TO (224080); -- Percentage: 1.2 - Rows: 4089672
CREATE TABLE chartevents_185 PARTITION OF chartevents
    FOR VALUES FROM (224080) TO (224083); -- Percentage: 0.5 - Rows: 1559194
CREATE TABLE chartevents_186 PARTITION OF chartevents
    FOR VALUES FROM (224083) TO (224087); -- Percentage: 0.6 - Rows: 2089736
CREATE TABLE chartevents_187 PARTITION OF chartevents
    FOR VALUES FROM (224087) TO (224093); -- Percentage: 0.4 - Rows: 1465008
CREATE TABLE chartevents_188 PARTITION OF chartevents
    FOR VALUES FROM (224093) TO (224094); -- Percentage: 0.2 - Rows: 717326
CREATE TABLE chartevents_189 PARTITION OF chartevents
    FOR VALUES FROM (224094) TO (224300); -- Percentage: 0.9 - Rows: 2933324
CREATE TABLE chartevents_190 PARTITION OF chartevents
    FOR VALUES FROM (224300) TO (224642); -- Percentage: 0.9 - Rows: 3110922
CREATE TABLE chartevents_191 PARTITION OF chartevents
    FOR VALUES FROM (224642) TO (224643); -- Percentage: 0.2 - Rows: 618565
CREATE TABLE chartevents_192 PARTITION OF chartevents
    FOR VALUES FROM (224643) TO (224650); -- Percentage: 0.0 - Rows: 1165
CREATE TABLE chartevents_193 PARTITION OF chartevents
    FOR VALUES FROM (224650) TO (224651); -- Percentage: 0.6 - Rows: 1849287
CREATE TABLE chartevents_194 PARTITION OF chartevents
    FOR VALUES FROM (224651) TO (224700); -- Percentage: 1.2 - Rows: 4059618
CREATE TABLE chartevents_195 PARTITION OF chartevents
    FOR VALUES FROM (224700) TO (224800); -- Percentage: 1.0 - Rows: 3154406
CREATE TABLE chartevents_196 PARTITION OF chartevents
    FOR VALUES FROM (224800) TO (224900); -- Percentage: 0.9 - Rows: 2873716
CREATE TABLE chartevents_197 PARTITION OF chartevents
    FOR VALUES FROM (224900) TO (225000); -- Percentage: 0.8 - Rows: 2659813
CREATE TABLE chartevents_198 PARTITION OF chartevents
    FOR VALUES FROM (225000) TO (225500); -- Percentage: 1.1 - Rows: 3763143
CREATE TABLE chartevents_199 PARTITION OF chartevents
    FOR VALUES FROM (225500) TO (226000); -- Percentage: 0.5 - Rows: 1718572
CREATE TABLE chartevents_200 PARTITION OF chartevents
    FOR VALUES FROM (226000) TO (226500); -- Percentage: 0.8 - Rows: 2662741
CREATE TABLE chartevents_201 PARTITION OF chartevents
    FOR VALUES FROM (226500) TO (227000); -- Percentage: 0.5 - Rows: 1605091
CREATE TABLE chartevents_202 PARTITION OF chartevents
    FOR VALUES FROM (227000) TO (227500); -- Percentage: 1.7 - Rows: 5553957
CREATE TABLE chartevents_203 PARTITION OF chartevents
    FOR VALUES FROM (227500) TO (227958); -- Percentage: 1.7 - Rows: 5627006
CREATE TABLE chartevents_204 PARTITION OF chartevents
    FOR VALUES FROM (227958) TO (227959); -- Percentage: 0.2 - Rows: 716961
CREATE TABLE chartevents_205 PARTITION OF chartevents
    FOR VALUES FROM (227959) TO (227969); -- Percentage: 0.2 - Rows: 816157
CREATE TABLE chartevents_206 PARTITION OF chartevents
    FOR VALUES FROM (227969) TO (227970); -- Percentage: 0.6 - Rows: 1862707
CREATE TABLE chartevents_207 PARTITION OF chartevents
    FOR VALUES FROM (227970) TO (1000000); -- Percentage: 0.7 - Rows: 2313406

--------------------------------------------------------
--  DDL for Table CPTEVENTS
--------------------------------------------------------

DROP TABLE IF EXISTS CPTEVENTS CASCADE;
CREATE TABLE CPTEVENTS
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT NOT NULL,
	COSTCENTER VARCHAR(10) NOT NULL,
	CHARTDATE TIMESTAMP(0),
	CPT_CD VARCHAR(10) NOT NULL,
	CPT_NUMBER INT,
	CPT_SUFFIX VARCHAR(5),
	TICKET_ID_SEQ INT,
	SECTIONHEADER VARCHAR(50),
	SUBSECTIONHEADER VARCHAR(255),
	DESCRIPTION VARCHAR(200),
	CONSTRAINT cpt_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table DATETIMEEVENTS
--------------------------------------------------------

DROP TABLE IF EXISTS DATETIMEEVENTS CASCADE;
CREATE TABLE DATETIMEEVENTS
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT,
	ICUSTAY_ID INT,
	ITEMID INT NOT NULL,
	CHARTTIME TIMESTAMP(0) NOT NULL,
	STORETIME TIMESTAMP(0) NOT NULL,
	CGID INT NOT NULL,
	VALUE TIMESTAMP(0),
	VALUEUOM VARCHAR(50) NOT NULL,
	WARNING SMALLINT,
	ERROR SMALLINT,
	RESULTSTATUS VARCHAR(50),
	STOPPED VARCHAR(50),
	CONSTRAINT datetime_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table DIAGNOSES_ICD
--------------------------------------------------------

DROP TABLE IF EXISTS DIAGNOSES_ICD CASCADE;
CREATE TABLE DIAGNOSES_ICD
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT NOT NULL,
	SEQ_NUM INT,
	ICD9_CODE VARCHAR(10),
	CONSTRAINT diagnosesicd_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table DRGCODES
--------------------------------------------------------

DROP TABLE IF EXISTS DRGCODES CASCADE;
CREATE TABLE DRGCODES
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT NOT NULL,
	DRG_TYPE VARCHAR(20) NOT NULL,
	DRG_CODE VARCHAR(20) NOT NULL,
	DESCRIPTION VARCHAR(255),
	DRG_SEVERITY SMALLINT,
	DRG_MORTALITY SMALLINT,
	CONSTRAINT drg_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table D_CPT
--------------------------------------------------------

DROP TABLE IF EXISTS D_CPT CASCADE;
CREATE TABLE D_CPT
(
  ROW_ID INT NOT NULL,
	CATEGORY SMALLINT NOT NULL,
	SECTIONRANGE VARCHAR(100) NOT NULL,
	SECTIONHEADER VARCHAR(50) NOT NULL,
	SUBSECTIONRANGE VARCHAR(100) NOT NULL,
	SUBSECTIONHEADER VARCHAR(255) NOT NULL,
	CODESUFFIX VARCHAR(5),
	MINCODEINSUBSECTION INT NOT NULL,
	MAXCODEINSUBSECTION INT NOT NULL,
	CONSTRAINT dcpt_ssrange_unique UNIQUE (SUBSECTIONRANGE),
	CONSTRAINT dcpt_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table D_ICD_DIAGNOSES
--------------------------------------------------------

DROP TABLE IF EXISTS D_ICD_DIAGNOSES CASCADE;
CREATE TABLE D_ICD_DIAGNOSES
(
  ROW_ID INT NOT NULL,
	ICD9_CODE VARCHAR(10) NOT NULL,
	SHORT_TITLE VARCHAR(50) NOT NULL,
	LONG_TITLE VARCHAR(255) NOT NULL,
	CONSTRAINT d_icd_diag_code_unique UNIQUE (ICD9_CODE),
	CONSTRAINT d_icd_diag_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table D_ICD_PROCEDURES
--------------------------------------------------------

DROP TABLE IF EXISTS D_ICD_PROCEDURES CASCADE;
CREATE TABLE D_ICD_PROCEDURES
(
  ROW_ID INT NOT NULL,
	ICD9_CODE VARCHAR(10) NOT NULL,
	SHORT_TITLE VARCHAR(50) NOT NULL,
	LONG_TITLE VARCHAR(255) NOT NULL,
	CONSTRAINT d_icd_proc_code_unique UNIQUE (ICD9_CODE),
	CONSTRAINT d_icd_proc_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table D_ITEMS
--------------------------------------------------------

DROP TABLE IF EXISTS D_ITEMS CASCADE;
CREATE TABLE D_ITEMS
(
  ROW_ID INT NOT NULL,
	ITEMID INT NOT NULL,
	LABEL VARCHAR(200),
	ABBREVIATION VARCHAR(100),
	DBSOURCE VARCHAR(20),
	LINKSTO VARCHAR(50),
	CATEGORY VARCHAR(100),
	UNITNAME VARCHAR(100),
	PARAM_TYPE VARCHAR(30),
	CONCEPTID INT,
	CONSTRAINT ditems_itemid_unique UNIQUE (ITEMID),
	CONSTRAINT ditems_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table D_LABITEMS
--------------------------------------------------------

DROP TABLE IF EXISTS D_LABITEMS CASCADE;
CREATE TABLE D_LABITEMS
(
  ROW_ID INT NOT NULL,
	ITEMID INT NOT NULL,
	LABEL VARCHAR(100) NOT NULL,
	FLUID VARCHAR(100) NOT NULL,
	CATEGORY VARCHAR(100) NOT NULL,
	LOINC_CODE VARCHAR(100),
	CONSTRAINT dlabitems_itemid_unique UNIQUE (ITEMID),
	CONSTRAINT dlabitems_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table ICUSTAYS
--------------------------------------------------------

DROP TABLE IF EXISTS ICUSTAYS CASCADE;
CREATE TABLE ICUSTAYS
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT NOT NULL,
	ICUSTAY_ID INT NOT NULL,
	DBSOURCE VARCHAR(20) NOT NULL,
	FIRST_CAREUNIT VARCHAR(20) NOT NULL,
	LAST_CAREUNIT VARCHAR(20) NOT NULL,
	FIRST_WARDID SMALLINT NOT NULL,
	LAST_WARDID SMALLINT NOT NULL,
	INTIME TIMESTAMP(0) NOT NULL,
	OUTTIME TIMESTAMP(0),
	LOS DOUBLE PRECISION,
	CONSTRAINT icustay_icustayid_unique UNIQUE (ICUSTAY_ID),
	CONSTRAINT icustay_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table INPUTEVENTS_CV
--------------------------------------------------------

DROP TABLE IF EXISTS INPUTEVENTS_CV CASCADE;
CREATE TABLE INPUTEVENTS_CV
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT,
	ICUSTAY_ID INT,
	CHARTTIME TIMESTAMP(0),
	ITEMID INT,
	AMOUNT DOUBLE PRECISION,
	AMOUNTUOM VARCHAR(30),
	RATE DOUBLE PRECISION,
	RATEUOM VARCHAR(30),
	STORETIME TIMESTAMP(0),
	CGID INT,
	ORDERID INT,
	LINKORDERID INT,
	STOPPED VARCHAR(30),
	NEWBOTTLE INT,
	ORIGINALAMOUNT DOUBLE PRECISION,
	ORIGINALAMOUNTUOM VARCHAR(30),
	ORIGINALROUTE VARCHAR(30),
	ORIGINALRATE DOUBLE PRECISION,
	ORIGINALRATEUOM VARCHAR(30),
	ORIGINALSITE VARCHAR(30),
	CONSTRAINT inputevents_cv_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table INPUTEVENTS_MV
--------------------------------------------------------

DROP TABLE IF EXISTS INPUTEVENTS_MV CASCADE;
CREATE TABLE INPUTEVENTS_MV
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT,
	ICUSTAY_ID INT,
	STARTTIME TIMESTAMP(0),
	ENDTIME TIMESTAMP(0),
	ITEMID INT,
	AMOUNT DOUBLE PRECISION,
	AMOUNTUOM VARCHAR(30),
	RATE DOUBLE PRECISION,
	RATEUOM VARCHAR(30),
	STORETIME TIMESTAMP(0),
	CGID INT,
	ORDERID INT,
	LINKORDERID INT,
	ORDERCATEGORYNAME VARCHAR(100),
	SECONDARYORDERCATEGORYNAME VARCHAR(100),
	ORDERCOMPONENTTYPEDESCRIPTION VARCHAR(200),
	ORDERCATEGORYDESCRIPTION VARCHAR(50),
	PATIENTWEIGHT DOUBLE PRECISION,
	TOTALAMOUNT DOUBLE PRECISION,
	TOTALAMOUNTUOM VARCHAR(50),
	ISOPENBAG SMALLINT,
	CONTINUEINNEXTDEPT SMALLINT,
	CANCELREASON SMALLINT,
	STATUSDESCRIPTION VARCHAR(30),
	COMMENTS_EDITEDBY VARCHAR(30),
	COMMENTS_CANCELEDBY VARCHAR(40),
	COMMENTS_DATE TIMESTAMP(0),
	ORIGINALAMOUNT DOUBLE PRECISION,
	ORIGINALRATE DOUBLE PRECISION,
	CONSTRAINT inputevents_mv_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table LABEVENTS
--------------------------------------------------------

DROP TABLE IF EXISTS LABEVENTS CASCADE;
CREATE TABLE LABEVENTS
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT,
	ITEMID INT NOT NULL,
	CHARTTIME TIMESTAMP(0),
	VALUE VARCHAR(200),
	VALUENUM DOUBLE PRECISION,
	VALUEUOM VARCHAR(20),
	FLAG VARCHAR(20),
	CONSTRAINT labevents_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table MICROBIOLOGYEVENTS
--------------------------------------------------------

DROP TABLE IF EXISTS MICROBIOLOGYEVENTS CASCADE;
CREATE TABLE MICROBIOLOGYEVENTS
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT,
	CHARTDATE TIMESTAMP(0),
	CHARTTIME TIMESTAMP(0),
	SPEC_ITEMID INT,
	SPEC_TYPE_DESC VARCHAR(100),
	ORG_ITEMID INT,
	ORG_NAME VARCHAR(100),
	ISOLATE_NUM SMALLINT,
	AB_ITEMID INT,
	AB_NAME VARCHAR(30),
	DILUTION_TEXT VARCHAR(10),
	DILUTION_COMPARISON VARCHAR(20),
	DILUTION_VALUE DOUBLE PRECISION,
	INTERPRETATION VARCHAR(5),
	CONSTRAINT micro_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table NOTEEVENTS
--------------------------------------------------------

DROP TABLE IF EXISTS NOTEEVENTS CASCADE;
CREATE TABLE NOTEEVENTS
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT,
	CHARTDATE TIMESTAMP(0),
	CHARTTIME TIMESTAMP(0),
	STORETIME TIMESTAMP(0),
	CATEGORY VARCHAR(50),
	DESCRIPTION VARCHAR(255),
	CGID INT,
	ISERROR CHAR(1),
	TEXT TEXT,
	CONSTRAINT noteevents_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table OUTPUTEVENTS
--------------------------------------------------------

DROP TABLE IF EXISTS OUTPUTEVENTS CASCADE;
CREATE TABLE OUTPUTEVENTS
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT,
	ICUSTAY_ID INT,
	CHARTTIME TIMESTAMP(0),
	ITEMID INT,
	VALUE DOUBLE PRECISION,
	VALUEUOM VARCHAR(30),
	STORETIME TIMESTAMP(0),
	CGID INT,
	STOPPED VARCHAR(30),
	NEWBOTTLE CHAR(1),
	ISERROR INT,
	CONSTRAINT outputevents_cv_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table PATIENTS
--------------------------------------------------------

DROP TABLE IF EXISTS PATIENTS CASCADE;
CREATE TABLE PATIENTS
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	GENDER VARCHAR(5) NOT NULL,
	DOB TIMESTAMP(0) NOT NULL,
	DOD TIMESTAMP(0),
	DOD_HOSP TIMESTAMP(0),
	DOD_SSN TIMESTAMP(0),
	EXPIRE_FLAG INT NOT NULL,
	CONSTRAINT pat_subid_unique UNIQUE (SUBJECT_ID),
	CONSTRAINT pat_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table PRESCRIPTIONS
--------------------------------------------------------

DROP TABLE IF EXISTS PRESCRIPTIONS CASCADE;
CREATE TABLE PRESCRIPTIONS
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT NOT NULL,
	ICUSTAY_ID INT,
	STARTDATE TIMESTAMP(0),
	ENDDATE TIMESTAMP(0),
	DRUG_TYPE VARCHAR(100) NOT NULL,
	DRUG VARCHAR(100) NOT NULL,
	DRUG_NAME_POE VARCHAR(100),
	DRUG_NAME_GENERIC VARCHAR(100),
	FORMULARY_DRUG_CD VARCHAR(120),
	GSN VARCHAR(200),
	NDC VARCHAR(120),
	PROD_STRENGTH VARCHAR(120),
	DOSE_VAL_RX VARCHAR(120),
	DOSE_UNIT_RX VARCHAR(120),
	FORM_VAL_DISP VARCHAR(120),
	FORM_UNIT_DISP VARCHAR(120),
	ROUTE VARCHAR(120),
	CONSTRAINT prescription_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table PROCEDUREEVENTS_MV
--------------------------------------------------------

DROP TABLE IF EXISTS PROCEDUREEVENTS_MV CASCADE;
CREATE TABLE PROCEDUREEVENTS_MV
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT NOT NULL,
	ICUSTAY_ID INT,
	STARTTIME TIMESTAMP(0),
	ENDTIME TIMESTAMP(0),
	ITEMID INT,
	VALUE DOUBLE PRECISION,
	VALUEUOM VARCHAR(30),
	LOCATION VARCHAR(30),
	LOCATIONCATEGORY VARCHAR(30),
	STORETIME TIMESTAMP(0),
	CGID INT,
	ORDERID INT,
	LINKORDERID INT,
	ORDERCATEGORYNAME VARCHAR(100),
	SECONDARYORDERCATEGORYNAME VARCHAR(100),
	ORDERCATEGORYDESCRIPTION VARCHAR(50),
	ISOPENBAG SMALLINT,
	CONTINUEINNEXTDEPT SMALLINT,
	CANCELREASON SMALLINT,
	STATUSDESCRIPTION VARCHAR(30),
	COMMENTS_EDITEDBY VARCHAR(30),
	COMMENTS_CANCELEDBY VARCHAR(30),
	COMMENTS_DATE TIMESTAMP(0),
	CONSTRAINT procedureevents_mv_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table PROCEDURES_ICD
--------------------------------------------------------

DROP TABLE IF EXISTS PROCEDURES_ICD CASCADE;
CREATE TABLE PROCEDURES_ICD
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT NOT NULL,
	SEQ_NUM INT NOT NULL,
	ICD9_CODE VARCHAR(10) NOT NULL,
	CONSTRAINT proceduresicd_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table SERVICES
--------------------------------------------------------

DROP TABLE IF EXISTS SERVICES CASCADE;
CREATE TABLE SERVICES
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT NOT NULL,
	TRANSFERTIME TIMESTAMP(0) NOT NULL,
	PREV_SERVICE VARCHAR(20),
	CURR_SERVICE VARCHAR(20),
	CONSTRAINT services_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  DDL for Table TRANSFERS
--------------------------------------------------------

DROP TABLE IF EXISTS TRANSFERS CASCADE;
CREATE TABLE TRANSFERS
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT NOT NULL,
	ICUSTAY_ID INT,
	DBSOURCE VARCHAR(20),
	EVENTTYPE VARCHAR(20),
	PREV_CAREUNIT VARCHAR(20),
	CURR_CAREUNIT VARCHAR(20),
	PREV_WARDID SMALLINT,
	CURR_WARDID SMALLINT,
	INTIME TIMESTAMP(0),
	OUTTIME TIMESTAMP(0),
	LOS DOUBLE PRECISION,
	CONSTRAINT transfers_rowid_pk PRIMARY KEY (ROW_ID)
) ;
