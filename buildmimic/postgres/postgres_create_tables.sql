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

DROP TABLE IF EXISTS CHARTEVENTS CASCADE;
CREATE TABLE CHARTEVENTS
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
	STOPPED VARCHAR(50),
	CONSTRAINT chartevents_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
--  PARTITION for Table CHARTEVENTS
--------------------------------------------------------

-- CREATE CHARTEVENTS TABLE

CREATE TABLE chartevents_1 ( CHECK ( itemid >= 1  AND itemid < 27 )) INHERITS (chartevents); -- Percentage: 0.0 - Rows: 22204
CREATE TABLE chartevents_2 ( CHECK ( itemid >= 27  AND itemid < 28 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 737224
CREATE TABLE chartevents_3 ( CHECK ( itemid >= 28  AND itemid < 31 )) INHERITS (chartevents); -- Percentage: 0.0 - Rows: 56235
CREATE TABLE chartevents_4 ( CHECK ( itemid >= 31  AND itemid < 32 )) INHERITS (chartevents); -- Percentage: 0.4 - Rows: 1442406
CREATE TABLE chartevents_5 ( CHECK ( itemid >= 32  AND itemid < 33 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 878442
CREATE TABLE chartevents_6 ( CHECK ( itemid >= 33  AND itemid < 49 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1659172
CREATE TABLE chartevents_7 ( CHECK ( itemid >= 49  AND itemid < 50 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 636690
CREATE TABLE chartevents_8 ( CHECK ( itemid >= 50  AND itemid < 51 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 285028
CREATE TABLE chartevents_9 ( CHECK ( itemid >= 51  AND itemid < 52 )) INHERITS (chartevents); -- Percentage: 0.6 - Rows: 2096678
CREATE TABLE chartevents_10 ( CHECK ( itemid >= 52  AND itemid < 53 )) INHERITS (chartevents); -- Percentage: 0.6 - Rows: 2072743
CREATE TABLE chartevents_11 ( CHECK ( itemid >= 53  AND itemid < 54 )) INHERITS (chartevents); -- Percentage: 0.0 - Rows: 178
CREATE TABLE chartevents_12 ( CHECK ( itemid >= 54  AND itemid < 55 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 892239
CREATE TABLE chartevents_13 ( CHECK ( itemid >= 55  AND itemid < 80 )) INHERITS (chartevents); -- Percentage: 0.4 - Rows: 1181039
CREATE TABLE chartevents_14 ( CHECK ( itemid >= 80  AND itemid < 81 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 1136214
CREATE TABLE chartevents_15 ( CHECK ( itemid >= 81  AND itemid < 113 )) INHERITS (chartevents); -- Percentage: 1.0 - Rows: 3418901
CREATE TABLE chartevents_16 ( CHECK ( itemid >= 113  AND itemid < 114 )) INHERITS (chartevents); -- Percentage: 0.4 - Rows: 1198681
CREATE TABLE chartevents_17 ( CHECK ( itemid >= 114  AND itemid < 128 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 1111444
CREATE TABLE chartevents_18 ( CHECK ( itemid >= 128  AND itemid < 129 )) INHERITS (chartevents); -- Percentage: 1.0 - Rows: 3216866
CREATE TABLE chartevents_19 ( CHECK ( itemid >= 129  AND itemid < 154 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1669170
CREATE TABLE chartevents_20 ( CHECK ( itemid >= 154  AND itemid < 155 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 818852
CREATE TABLE chartevents_21 ( CHECK ( itemid >= 155  AND itemid < 159 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 974476
CREATE TABLE chartevents_22 ( CHECK ( itemid >= 159  AND itemid < 160 )) INHERITS (chartevents); -- Percentage: 0.8 - Rows: 2544519
CREATE TABLE chartevents_23 ( CHECK ( itemid >= 160  AND itemid < 161 )) INHERITS (chartevents); -- Percentage: 0.0 - Rows: 9458
CREATE TABLE chartevents_24 ( CHECK ( itemid >= 161  AND itemid < 162 )) INHERITS (chartevents); -- Percentage: 1.0 - Rows: 3236350
CREATE TABLE chartevents_25 ( CHECK ( itemid >= 162  AND itemid < 184 )) INHERITS (chartevents); -- Percentage: 0.6 - Rows: 1837071
CREATE TABLE chartevents_26 ( CHECK ( itemid >= 184  AND itemid < 185 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 954139
CREATE TABLE chartevents_27 ( CHECK ( itemid >= 185  AND itemid < 198 )) INHERITS (chartevents); -- Percentage: 0.4 - Rows: 1456328
CREATE TABLE chartevents_28 ( CHECK ( itemid >= 198  AND itemid < 199 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 945638
CREATE TABLE chartevents_29 ( CHECK ( itemid >= 199  AND itemid < 210 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1545176
CREATE TABLE chartevents_30 ( CHECK ( itemid >= 210  AND itemid < 211 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 955452
CREATE TABLE chartevents_31 ( CHECK ( itemid >= 211  AND itemid < 212 )) INHERITS (chartevents); -- Percentage: 1.6 - Rows: 5180809
CREATE TABLE chartevents_32 ( CHECK ( itemid >= 212  AND itemid < 213 )) INHERITS (chartevents); -- Percentage: 1.0 - Rows: 3303151
CREATE TABLE chartevents_33 ( CHECK ( itemid >= 213  AND itemid < 250 )) INHERITS (chartevents); -- Percentage: 1.1 - Rows: 3676785
CREATE TABLE chartevents_34 ( CHECK ( itemid >= 250  AND itemid < 425 )) INHERITS (chartevents); -- Percentage: 2.4 - Rows: 7811955
CREATE TABLE chartevents_35 ( CHECK ( itemid >= 425  AND itemid < 426 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 783762
CREATE TABLE chartevents_36 ( CHECK ( itemid >= 426  AND itemid < 428 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 402022
CREATE TABLE chartevents_37 ( CHECK ( itemid >= 428  AND itemid < 429 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 786544
CREATE TABLE chartevents_38 ( CHECK ( itemid >= 429  AND itemid < 432 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 349997
CREATE TABLE chartevents_39 ( CHECK ( itemid >= 432  AND itemid < 433 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 1032728
CREATE TABLE chartevents_40 ( CHECK ( itemid >= 433  AND itemid < 454 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1589945
CREATE TABLE chartevents_41 ( CHECK ( itemid >= 454  AND itemid < 455 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 950038
CREATE TABLE chartevents_42 ( CHECK ( itemid >= 455  AND itemid < 456 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1579681
CREATE TABLE chartevents_43 ( CHECK ( itemid >= 456  AND itemid < 457 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1553537
CREATE TABLE chartevents_44 ( CHECK ( itemid >= 457  AND itemid < 467 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 392595
CREATE TABLE chartevents_45 ( CHECK ( itemid >= 467  AND itemid < 468 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 1155571
CREATE TABLE chartevents_46 ( CHECK ( itemid >= 468  AND itemid < 478 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 985720
CREATE TABLE chartevents_47 ( CHECK ( itemid >= 478  AND itemid < 479 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 774157
CREATE TABLE chartevents_48 ( CHECK ( itemid >= 479  AND itemid < 480 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 917780
CREATE TABLE chartevents_49 ( CHECK ( itemid >= 480  AND itemid < 547 )) INHERITS (chartevents); -- Percentage: 1.4 - Rows: 4595328
CREATE TABLE chartevents_50 ( CHECK ( itemid >= 547  AND itemid < 548 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 852968
CREATE TABLE chartevents_51 ( CHECK ( itemid >= 548  AND itemid < 550 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 883558
CREATE TABLE chartevents_52 ( CHECK ( itemid >= 550  AND itemid < 551 )) INHERITS (chartevents); -- Percentage: 1.0 - Rows: 3205052
CREATE TABLE chartevents_53 ( CHECK ( itemid >= 551  AND itemid < 581 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 1022222
CREATE TABLE chartevents_54 ( CHECK ( itemid >= 581  AND itemid < 582 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1641889
CREATE TABLE chartevents_55 ( CHECK ( itemid >= 582  AND itemid < 593 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1654497
CREATE TABLE chartevents_56 ( CHECK ( itemid >= 593  AND itemid < 594 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 784361
CREATE TABLE chartevents_57 ( CHECK ( itemid >= 594  AND itemid < 599 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 913144
CREATE TABLE chartevents_58 ( CHECK ( itemid >= 599  AND itemid < 600 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 787137
CREATE TABLE chartevents_59 ( CHECK ( itemid >= 600  AND itemid < 614 )) INHERITS (chartevents); -- Percentage: 0.4 - Rows: 1251345
CREATE TABLE chartevents_60 ( CHECK ( itemid >= 614  AND itemid < 617 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 774906
CREATE TABLE chartevents_61 ( CHECK ( itemid >= 617  AND itemid < 618 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 962191
CREATE TABLE chartevents_62 ( CHECK ( itemid >= 618  AND itemid < 619 )) INHERITS (chartevents); -- Percentage: 1.0 - Rows: 3386719
CREATE TABLE chartevents_63 ( CHECK ( itemid >= 619  AND itemid < 621 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 580529
CREATE TABLE chartevents_64 ( CHECK ( itemid >= 621  AND itemid < 622 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 666496
CREATE TABLE chartevents_65 ( CHECK ( itemid >= 622  AND itemid < 637 )) INHERITS (chartevents); -- Percentage: 0.6 - Rows: 2048955
CREATE TABLE chartevents_66 ( CHECK ( itemid >= 637  AND itemid < 638 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 954354
CREATE TABLE chartevents_67 ( CHECK ( itemid >= 638  AND itemid < 640 )) INHERITS (chartevents); -- Percentage: 0.0 - Rows: 437
CREATE TABLE chartevents_68 ( CHECK ( itemid >= 640  AND itemid < 646 )) INHERITS (chartevents); -- Percentage: 0.4 - Rows: 1447426
CREATE TABLE chartevents_69 ( CHECK ( itemid >= 646  AND itemid < 647 )) INHERITS (chartevents); -- Percentage: 1.0 - Rows: 3418917
CREATE TABLE chartevents_70 ( CHECK ( itemid >= 647  AND itemid < 663 )) INHERITS (chartevents); -- Percentage: 0.6 - Rows: 2135542
CREATE TABLE chartevents_71 ( CHECK ( itemid >= 663  AND itemid < 664 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 774213
CREATE TABLE chartevents_72 ( CHECK ( itemid >= 664  AND itemid < 674 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 300570
CREATE TABLE chartevents_73 ( CHECK ( itemid >= 674  AND itemid < 675 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 1042512
CREATE TABLE chartevents_74 ( CHECK ( itemid >= 675  AND itemid < 677 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 378549
CREATE TABLE chartevents_75 ( CHECK ( itemid >= 677  AND itemid < 678 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 772277
CREATE TABLE chartevents_76 ( CHECK ( itemid >= 678  AND itemid < 679 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 773891
CREATE TABLE chartevents_77 ( CHECK ( itemid >= 679  AND itemid < 680 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 376047
CREATE TABLE chartevents_78 ( CHECK ( itemid >= 680  AND itemid < 681 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 740176
CREATE TABLE chartevents_79 ( CHECK ( itemid >= 681  AND itemid < 704 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 1099236
CREATE TABLE chartevents_80 ( CHECK ( itemid >= 704  AND itemid < 705 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 933238
CREATE TABLE chartevents_81 ( CHECK ( itemid >= 705  AND itemid < 706 )) INHERITS (chartevents); -- Percentage: 0.0 - Rows: 20754
CREATE TABLE chartevents_82 ( CHECK ( itemid >= 706  AND itemid < 707 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 727719
CREATE TABLE chartevents_83 ( CHECK ( itemid >= 707  AND itemid < 708 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 937064
CREATE TABLE chartevents_84 ( CHECK ( itemid >= 708  AND itemid < 723 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 1049706
CREATE TABLE chartevents_85 ( CHECK ( itemid >= 723  AND itemid < 724 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 952177
CREATE TABLE chartevents_86 ( CHECK ( itemid >= 724  AND itemid < 742 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 321012
CREATE TABLE chartevents_87 ( CHECK ( itemid >= 742  AND itemid < 743 )) INHERITS (chartevents); -- Percentage: 1.0 - Rows: 3464326
CREATE TABLE chartevents_88 ( CHECK ( itemid >= 743  AND itemid < 834 )) INHERITS (chartevents); -- Percentage: 1.8 - Rows: 5925297
CREATE TABLE chartevents_89 ( CHECK ( itemid >= 834  AND itemid < 835 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1716561
CREATE TABLE chartevents_90 ( CHECK ( itemid >= 835  AND itemid < 1046 )) INHERITS (chartevents); -- Percentage: 0.4 - Rows: 1417336
CREATE TABLE chartevents_91 ( CHECK ( itemid >= 1046  AND itemid < 1047 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 803816
CREATE TABLE chartevents_92 ( CHECK ( itemid >= 1047  AND itemid < 1087 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 423898
CREATE TABLE chartevents_93 ( CHECK ( itemid >= 1087  AND itemid < 1088 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 592344
CREATE TABLE chartevents_94 ( CHECK ( itemid >= 1088  AND itemid < 1125 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 250247
CREATE TABLE chartevents_95 ( CHECK ( itemid >= 1125  AND itemid < 1126 )) INHERITS (chartevents); -- Percentage: 0.9 - Rows: 2955851
CREATE TABLE chartevents_96 ( CHECK ( itemid >= 1126  AND itemid < 1337 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 808725
CREATE TABLE chartevents_97 ( CHECK ( itemid >= 1337  AND itemid < 1338 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 1083809
CREATE TABLE chartevents_98 ( CHECK ( itemid >= 1338  AND itemid < 1484 )) INHERITS (chartevents); -- Percentage: 0.4 - Rows: 1281335
CREATE TABLE chartevents_99 ( CHECK ( itemid >= 1484  AND itemid < 1485 )) INHERITS (chartevents); -- Percentage: 0.7 - Rows: 2261065
CREATE TABLE chartevents_100 ( CHECK ( itemid >= 1485  AND itemid < 1703 )) INHERITS (chartevents); -- Percentage: 1.1 - Rows: 3561885
CREATE TABLE chartevents_101 ( CHECK ( itemid >= 1703  AND itemid < 1704 )) INHERITS (chartevents); -- Percentage: 0.4 - Rows: 1174868
CREATE TABLE chartevents_102 ( CHECK ( itemid >= 1704  AND itemid < 1800 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 293325
CREATE TABLE chartevents_103 ( CHECK ( itemid >= 1800  AND itemid < 2500 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 249776
CREATE TABLE chartevents_104 ( CHECK ( itemid >= 2500  AND itemid < 3327 )) INHERITS (chartevents); -- Percentage: 0.9 - Rows: 3010424
CREATE TABLE chartevents_105 ( CHECK ( itemid >= 3327  AND itemid < 3328 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 679113
CREATE TABLE chartevents_106 ( CHECK ( itemid >= 3328  AND itemid < 3420 )) INHERITS (chartevents); -- Percentage: 1.6 - Rows: 5208156
CREATE TABLE chartevents_107 ( CHECK ( itemid >= 3420  AND itemid < 3421 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 673719
CREATE TABLE chartevents_108 ( CHECK ( itemid >= 3421  AND itemid < 3450 )) INHERITS (chartevents); -- Percentage: 0.8 - Rows: 2785057
CREATE TABLE chartevents_109 ( CHECK ( itemid >= 3450  AND itemid < 3451 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1687886
CREATE TABLE chartevents_110 ( CHECK ( itemid >= 3451  AND itemid < 3500 )) INHERITS (chartevents); -- Percentage: 0.7 - Rows: 2445808
CREATE TABLE chartevents_111 ( CHECK ( itemid >= 3500  AND itemid < 3550 )) INHERITS (chartevents); -- Percentage: 0.7 - Rows: 2433936
CREATE TABLE chartevents_112 ( CHECK ( itemid >= 3550  AND itemid < 3603 )) INHERITS (chartevents); -- Percentage: 1.3 - Rows: 4449487
CREATE TABLE chartevents_113 ( CHECK ( itemid >= 3603  AND itemid < 3604 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1676872
CREATE TABLE chartevents_114 ( CHECK ( itemid >= 3604  AND itemid < 3609 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 476670
CREATE TABLE chartevents_115 ( CHECK ( itemid >= 3609  AND itemid < 3610 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1621393
CREATE TABLE chartevents_116 ( CHECK ( itemid >= 3610  AND itemid < 3645 )) INHERITS (chartevents); -- Percentage: 0.7 - Rows: 2309226
CREATE TABLE chartevents_117 ( CHECK ( itemid >= 3645  AND itemid < 3646 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 690295
CREATE TABLE chartevents_118 ( CHECK ( itemid >= 3646  AND itemid < 3656 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 1009254
CREATE TABLE chartevents_119 ( CHECK ( itemid >= 3656  AND itemid < 3657 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 803881
CREATE TABLE chartevents_120 ( CHECK ( itemid >= 3657  AND itemid < 3700 )) INHERITS (chartevents); -- Percentage: 0.7 - Rows: 2367096
CREATE TABLE chartevents_121 ( CHECK ( itemid >= 3700  AND itemid < 5813 )) INHERITS (chartevents); -- Percentage: 0.4 - Rows: 1360432
CREATE TABLE chartevents_122 ( CHECK ( itemid >= 5813  AND itemid < 5814 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 982518
CREATE TABLE chartevents_123 ( CHECK ( itemid >= 5814  AND itemid < 5815 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 655454
CREATE TABLE chartevents_124 ( CHECK ( itemid >= 5815  AND itemid < 5816 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1807316
CREATE TABLE chartevents_125 ( CHECK ( itemid >= 5816  AND itemid < 5817 )) INHERITS (chartevents); -- Percentage: 0.0 - Rows: 34909
CREATE TABLE chartevents_126 ( CHECK ( itemid >= 5817  AND itemid < 5818 )) INHERITS (chartevents); -- Percentage: 0.4 - Rows: 1378959
CREATE TABLE chartevents_127 ( CHECK ( itemid >= 5818  AND itemid < 5819 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 178112
CREATE TABLE chartevents_128 ( CHECK ( itemid >= 5819  AND itemid < 5820 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1772387
CREATE TABLE chartevents_129 ( CHECK ( itemid >= 5820  AND itemid < 5821 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1802684
CREATE TABLE chartevents_130 ( CHECK ( itemid >= 5821  AND itemid < 8000 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1622363
CREATE TABLE chartevents_131 ( CHECK ( itemid >= 8000  AND itemid < 8367 )) INHERITS (chartevents); -- Percentage: 0.0 - Rows: 43749
CREATE TABLE chartevents_132 ( CHECK ( itemid >= 8367  AND itemid < 8368 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 601818
CREATE TABLE chartevents_133 ( CHECK ( itemid >= 8368  AND itemid < 8369 )) INHERITS (chartevents); -- Percentage: 0.6 - Rows: 2085994
CREATE TABLE chartevents_134 ( CHECK ( itemid >= 8369  AND itemid < 8441 )) INHERITS (chartevents); -- Percentage: 1.6 - Rows: 5266438
CREATE TABLE chartevents_135 ( CHECK ( itemid >= 8441  AND itemid < 8442 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1573583
CREATE TABLE chartevents_136 ( CHECK ( itemid >= 8442  AND itemid < 8480 )) INHERITS (chartevents); -- Percentage: 1.2 - Rows: 3870155
CREATE TABLE chartevents_137 ( CHECK ( itemid >= 8480  AND itemid < 8481 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 719203
CREATE TABLE chartevents_138 ( CHECK ( itemid >= 8481  AND itemid < 8518 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1600973
CREATE TABLE chartevents_139 ( CHECK ( itemid >= 8518  AND itemid < 8519 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1687615
CREATE TABLE chartevents_140 ( CHECK ( itemid >= 8519  AND itemid < 8532 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 1146136
CREATE TABLE chartevents_141 ( CHECK ( itemid >= 8532  AND itemid < 8533 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1619782
CREATE TABLE chartevents_142 ( CHECK ( itemid >= 8533  AND itemid < 8537 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 204405
CREATE TABLE chartevents_143 ( CHECK ( itemid >= 8537  AND itemid < 8538 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 725866
CREATE TABLE chartevents_144 ( CHECK ( itemid >= 8538  AND itemid < 8547 )) INHERITS (chartevents); -- Percentage: 0.0 - Rows: 302
CREATE TABLE chartevents_145 ( CHECK ( itemid >= 8547  AND itemid < 8548 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 976252
CREATE TABLE chartevents_146 ( CHECK ( itemid >= 8548  AND itemid < 8549 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 649745
CREATE TABLE chartevents_147 ( CHECK ( itemid >= 8549  AND itemid < 8550 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1804988
CREATE TABLE chartevents_148 ( CHECK ( itemid >= 8550  AND itemid < 8551 )) INHERITS (chartevents); -- Percentage: 0.0 - Rows: 33554
CREATE TABLE chartevents_149 ( CHECK ( itemid >= 8551  AND itemid < 8552 )) INHERITS (chartevents); -- Percentage: 0.4 - Rows: 1375295
CREATE TABLE chartevents_150 ( CHECK ( itemid >= 8552  AND itemid < 8553 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 174222
CREATE TABLE chartevents_151 ( CHECK ( itemid >= 8553  AND itemid < 8554 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1769925
CREATE TABLE chartevents_152 ( CHECK ( itemid >= 8554  AND itemid < 8555 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1796313
CREATE TABLE chartevents_153 ( CHECK ( itemid >= 8555  AND itemid < 220000 )) INHERITS (chartevents); -- Percentage: 0.0 - Rows: 18753
CREATE TABLE chartevents_154 ( CHECK ( itemid >= 220000  AND itemid < 220045 )) INHERITS (chartevents); -- Percentage:  - Rows:
CREATE TABLE chartevents_155 ( CHECK ( itemid >= 220045  AND itemid < 220046 )) INHERITS (chartevents); -- Percentage: 0.8 - Rows: 2762225
CREATE TABLE chartevents_156 ( CHECK ( itemid >= 220046  AND itemid < 220048 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 431909
CREATE TABLE chartevents_157 ( CHECK ( itemid >= 220048  AND itemid < 220049 )) INHERITS (chartevents); -- Percentage: 0.6 - Rows: 2023672
CREATE TABLE chartevents_158 ( CHECK ( itemid >= 220049  AND itemid < 220050 )) INHERITS (chartevents); -- Percentage:  - Rows:
CREATE TABLE chartevents_159 ( CHECK ( itemid >= 220050  AND itemid < 220051 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 1149788
CREATE TABLE chartevents_160 ( CHECK ( itemid >= 220051  AND itemid < 220052 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 1149537
CREATE TABLE chartevents_161 ( CHECK ( itemid >= 220052  AND itemid < 220053 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 1156173
CREATE TABLE chartevents_162 ( CHECK ( itemid >= 220053  AND itemid < 220074 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 648200
CREATE TABLE chartevents_163 ( CHECK ( itemid >= 220074  AND itemid < 220179 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 526472
CREATE TABLE chartevents_164 ( CHECK ( itemid >= 220179  AND itemid < 220180 )) INHERITS (chartevents); -- Percentage: 0.4 - Rows: 1290488
CREATE TABLE chartevents_165 ( CHECK ( itemid >= 220180  AND itemid < 220181 )) INHERITS (chartevents); -- Percentage: 0.4 - Rows: 1289885
CREATE TABLE chartevents_166 ( CHECK ( itemid >= 220181  AND itemid < 220182 )) INHERITS (chartevents); -- Percentage: 0.4 - Rows: 1292916
CREATE TABLE chartevents_167 ( CHECK ( itemid >= 220182  AND itemid < 220210 )) INHERITS (chartevents); -- Percentage: 0.0 - Rows: 208
CREATE TABLE chartevents_168 ( CHECK ( itemid >= 220210  AND itemid < 220211 )) INHERITS (chartevents); -- Percentage: 0.8 - Rows: 2737105
CREATE TABLE chartevents_169 ( CHECK ( itemid >= 220211  AND itemid < 220277 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 466344
CREATE TABLE chartevents_170 ( CHECK ( itemid >= 220277  AND itemid < 220278 )) INHERITS (chartevents); -- Percentage: 0.8 - Rows: 2671816
CREATE TABLE chartevents_171 ( CHECK ( itemid >= 220278  AND itemid < 222000 )) INHERITS (chartevents); -- Percentage: 1.0 - Rows: 3262258
CREATE TABLE chartevents_172 ( CHECK ( itemid >= 222000  AND itemid < 223792 )) INHERITS (chartevents); -- Percentage: 1.2 - Rows: 4068153
CREATE TABLE chartevents_173 ( CHECK ( itemid >= 223792  AND itemid < 223793 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 765274
CREATE TABLE chartevents_174 ( CHECK ( itemid >= 223793  AND itemid < 223800 )) INHERITS (chartevents); -- Percentage: 0.3 - Rows: 1139355
CREATE TABLE chartevents_175 ( CHECK ( itemid >= 223800  AND itemid < 223850 )) INHERITS (chartevents); -- Percentage: 0.6 - Rows: 1983602
CREATE TABLE chartevents_176 ( CHECK ( itemid >= 223850  AND itemid < 223900 )) INHERITS (chartevents); -- Percentage: 0.7 - Rows: 2185541
CREATE TABLE chartevents_177 ( CHECK ( itemid >= 223900  AND itemid < 223912 )) INHERITS (chartevents); -- Percentage: 1.1 - Rows: 3552998
CREATE TABLE chartevents_178 ( CHECK ( itemid >= 223912  AND itemid < 223925 )) INHERITS (chartevents); -- Percentage: 0.7 - Rows: 2289753
CREATE TABLE chartevents_179 ( CHECK ( itemid >= 223925  AND itemid < 223950 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1610057
CREATE TABLE chartevents_180 ( CHECK ( itemid >= 223950  AND itemid < 223974 )) INHERITS (chartevents); -- Percentage: 0.1 - Rows: 395061
CREATE TABLE chartevents_181 ( CHECK ( itemid >= 223974  AND itemid < 224000 )) INHERITS (chartevents); -- Percentage: 1.5 - Rows: 4797667
CREATE TABLE chartevents_182 ( CHECK ( itemid >= 224000  AND itemid < 224020 )) INHERITS (chartevents); -- Percentage: 1.0 - Rows: 3317320
CREATE TABLE chartevents_183 ( CHECK ( itemid >= 224020  AND itemid < 224040 )) INHERITS (chartevents); -- Percentage: 0.8 - Rows: 2611372
CREATE TABLE chartevents_184 ( CHECK ( itemid >= 224040  AND itemid < 224080 )) INHERITS (chartevents); -- Percentage: 1.2 - Rows: 4089672
CREATE TABLE chartevents_185 ( CHECK ( itemid >= 224080  AND itemid < 224083 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1559194
CREATE TABLE chartevents_186 ( CHECK ( itemid >= 224083  AND itemid < 224087 )) INHERITS (chartevents); -- Percentage: 0.6 - Rows: 2089736
CREATE TABLE chartevents_187 ( CHECK ( itemid >= 224087  AND itemid < 224093 )) INHERITS (chartevents); -- Percentage: 0.4 - Rows: 1465008
CREATE TABLE chartevents_188 ( CHECK ( itemid >= 224093  AND itemid < 224094 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 717326
CREATE TABLE chartevents_189 ( CHECK ( itemid >= 224094  AND itemid < 224300 )) INHERITS (chartevents); -- Percentage: 0.9 - Rows: 2933324
CREATE TABLE chartevents_190 ( CHECK ( itemid >= 224300  AND itemid < 224642 )) INHERITS (chartevents); -- Percentage: 0.9 - Rows: 3110922
CREATE TABLE chartevents_191 ( CHECK ( itemid >= 224642  AND itemid < 224643 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 618565
CREATE TABLE chartevents_192 ( CHECK ( itemid >= 224643  AND itemid < 224650 )) INHERITS (chartevents); -- Percentage: 0.0 - Rows: 1165
CREATE TABLE chartevents_193 ( CHECK ( itemid >= 224650  AND itemid < 224651 )) INHERITS (chartevents); -- Percentage: 0.6 - Rows: 1849287
CREATE TABLE chartevents_194 ( CHECK ( itemid >= 224651  AND itemid < 224700 )) INHERITS (chartevents); -- Percentage: 1.2 - Rows: 4059618
CREATE TABLE chartevents_195 ( CHECK ( itemid >= 224700  AND itemid < 224800 )) INHERITS (chartevents); -- Percentage: 1.0 - Rows: 3154406
CREATE TABLE chartevents_196 ( CHECK ( itemid >= 224800  AND itemid < 224900 )) INHERITS (chartevents); -- Percentage: 0.9 - Rows: 2873716
CREATE TABLE chartevents_197 ( CHECK ( itemid >= 224900  AND itemid < 225000 )) INHERITS (chartevents); -- Percentage: 0.8 - Rows: 2659813
CREATE TABLE chartevents_198 ( CHECK ( itemid >= 225000  AND itemid < 225500 )) INHERITS (chartevents); -- Percentage: 1.1 - Rows: 3763143
CREATE TABLE chartevents_199 ( CHECK ( itemid >= 225500  AND itemid < 226000 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1718572
CREATE TABLE chartevents_200 ( CHECK ( itemid >= 226000  AND itemid < 226500 )) INHERITS (chartevents); -- Percentage: 0.8 - Rows: 2662741
CREATE TABLE chartevents_201 ( CHECK ( itemid >= 226500  AND itemid < 227000 )) INHERITS (chartevents); -- Percentage: 0.5 - Rows: 1605091
CREATE TABLE chartevents_202 ( CHECK ( itemid >= 227000  AND itemid < 227500 )) INHERITS (chartevents); -- Percentage: 1.7 - Rows: 5553957
CREATE TABLE chartevents_203 ( CHECK ( itemid >= 227500  AND itemid < 227958 )) INHERITS (chartevents); -- Percentage: 1.7 - Rows: 5627006
CREATE TABLE chartevents_204 ( CHECK ( itemid >= 227958  AND itemid < 227959 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 716961
CREATE TABLE chartevents_205 ( CHECK ( itemid >= 227959  AND itemid < 227969 )) INHERITS (chartevents); -- Percentage: 0.2 - Rows: 816157
CREATE TABLE chartevents_206 ( CHECK ( itemid >= 227969  AND itemid < 227970 )) INHERITS (chartevents); -- Percentage: 0.6 - Rows: 1862707
CREATE TABLE chartevents_207 ( CHECK ( itemid >= 227970  AND itemid < 1000000 )) INHERITS (chartevents); -- Percentage: 0.7 - Rows: 2313406

-- CREATE CHARTEVENTS TRIGGER
CREATE OR REPLACE FUNCTION chartevents_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
IF ( NEW.itemid >= 1 AND NEW.itemid < 27 ) THEN INSERT INTO chartevents_1 VALUES (NEW.*); -- Percentage: 0.0 - Rows: 22204
ELSIF ( NEW.itemid >= 27 AND NEW.itemid < 28 ) THEN INSERT INTO chartevents_2 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 737224
ELSIF ( NEW.itemid >= 28 AND NEW.itemid < 31 ) THEN INSERT INTO chartevents_3 VALUES (NEW.*); -- Percentage: 0.0 - Rows: 56235
ELSIF ( NEW.itemid >= 31 AND NEW.itemid < 32 ) THEN INSERT INTO chartevents_4 VALUES (NEW.*); -- Percentage: 0.4 - Rows: 1442406
ELSIF ( NEW.itemid >= 32 AND NEW.itemid < 33 ) THEN INSERT INTO chartevents_5 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 878442
ELSIF ( NEW.itemid >= 33 AND NEW.itemid < 49 ) THEN INSERT INTO chartevents_6 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1659172
ELSIF ( NEW.itemid >= 49 AND NEW.itemid < 50 ) THEN INSERT INTO chartevents_7 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 636690
ELSIF ( NEW.itemid >= 50 AND NEW.itemid < 51 ) THEN INSERT INTO chartevents_8 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 285028
ELSIF ( NEW.itemid >= 51 AND NEW.itemid < 52 ) THEN INSERT INTO chartevents_9 VALUES (NEW.*); -- Percentage: 0.6 - Rows: 2096678
ELSIF ( NEW.itemid >= 52 AND NEW.itemid < 53 ) THEN INSERT INTO chartevents_10 VALUES (NEW.*); -- Percentage: 0.6 - Rows: 2072743
ELSIF ( NEW.itemid >= 53 AND NEW.itemid < 54 ) THEN INSERT INTO chartevents_11 VALUES (NEW.*); -- Percentage: 0.0 - Rows: 178
ELSIF ( NEW.itemid >= 54 AND NEW.itemid < 55 ) THEN INSERT INTO chartevents_12 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 892239
ELSIF ( NEW.itemid >= 55 AND NEW.itemid < 80 ) THEN INSERT INTO chartevents_13 VALUES (NEW.*); -- Percentage: 0.4 - Rows: 1181039
ELSIF ( NEW.itemid >= 80 AND NEW.itemid < 81 ) THEN INSERT INTO chartevents_14 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 1136214
ELSIF ( NEW.itemid >= 81 AND NEW.itemid < 113 ) THEN INSERT INTO chartevents_15 VALUES (NEW.*); -- Percentage: 1.0 - Rows: 3418901
ELSIF ( NEW.itemid >= 113 AND NEW.itemid < 114 ) THEN INSERT INTO chartevents_16 VALUES (NEW.*); -- Percentage: 0.4 - Rows: 1198681
ELSIF ( NEW.itemid >= 114 AND NEW.itemid < 128 ) THEN INSERT INTO chartevents_17 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 1111444
ELSIF ( NEW.itemid >= 128 AND NEW.itemid < 129 ) THEN INSERT INTO chartevents_18 VALUES (NEW.*); -- Percentage: 1.0 - Rows: 3216866
ELSIF ( NEW.itemid >= 129 AND NEW.itemid < 154 ) THEN INSERT INTO chartevents_19 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1669170
ELSIF ( NEW.itemid >= 154 AND NEW.itemid < 155 ) THEN INSERT INTO chartevents_20 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 818852
ELSIF ( NEW.itemid >= 155 AND NEW.itemid < 159 ) THEN INSERT INTO chartevents_21 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 974476
ELSIF ( NEW.itemid >= 159 AND NEW.itemid < 160 ) THEN INSERT INTO chartevents_22 VALUES (NEW.*); -- Percentage: 0.8 - Rows: 2544519
ELSIF ( NEW.itemid >= 160 AND NEW.itemid < 161 ) THEN INSERT INTO chartevents_23 VALUES (NEW.*); -- Percentage: 0.0 - Rows: 9458
ELSIF ( NEW.itemid >= 161 AND NEW.itemid < 162 ) THEN INSERT INTO chartevents_24 VALUES (NEW.*); -- Percentage: 1.0 - Rows: 3236350
ELSIF ( NEW.itemid >= 162 AND NEW.itemid < 184 ) THEN INSERT INTO chartevents_25 VALUES (NEW.*); -- Percentage: 0.6 - Rows: 1837071
ELSIF ( NEW.itemid >= 184 AND NEW.itemid < 185 ) THEN INSERT INTO chartevents_26 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 954139
ELSIF ( NEW.itemid >= 185 AND NEW.itemid < 198 ) THEN INSERT INTO chartevents_27 VALUES (NEW.*); -- Percentage: 0.4 - Rows: 1456328
ELSIF ( NEW.itemid >= 198 AND NEW.itemid < 199 ) THEN INSERT INTO chartevents_28 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 945638
ELSIF ( NEW.itemid >= 199 AND NEW.itemid < 210 ) THEN INSERT INTO chartevents_29 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1545176
ELSIF ( NEW.itemid >= 210 AND NEW.itemid < 211 ) THEN INSERT INTO chartevents_30 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 955452
ELSIF ( NEW.itemid >= 211 AND NEW.itemid < 212 ) THEN INSERT INTO chartevents_31 VALUES (NEW.*); -- Percentage: 1.6 - Rows: 5180809
ELSIF ( NEW.itemid >= 212 AND NEW.itemid < 213 ) THEN INSERT INTO chartevents_32 VALUES (NEW.*); -- Percentage: 1.0 - Rows: 3303151
ELSIF ( NEW.itemid >= 213 AND NEW.itemid < 250 ) THEN INSERT INTO chartevents_33 VALUES (NEW.*); -- Percentage: 1.1 - Rows: 3676785
ELSIF ( NEW.itemid >= 250 AND NEW.itemid < 425 ) THEN INSERT INTO chartevents_34 VALUES (NEW.*); -- Percentage: 2.4 - Rows: 7811955
ELSIF ( NEW.itemid >= 425 AND NEW.itemid < 426 ) THEN INSERT INTO chartevents_35 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 783762
ELSIF ( NEW.itemid >= 426 AND NEW.itemid < 428 ) THEN INSERT INTO chartevents_36 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 402022
ELSIF ( NEW.itemid >= 428 AND NEW.itemid < 429 ) THEN INSERT INTO chartevents_37 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 786544
ELSIF ( NEW.itemid >= 429 AND NEW.itemid < 432 ) THEN INSERT INTO chartevents_38 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 349997
ELSIF ( NEW.itemid >= 432 AND NEW.itemid < 433 ) THEN INSERT INTO chartevents_39 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 1032728
ELSIF ( NEW.itemid >= 433 AND NEW.itemid < 454 ) THEN INSERT INTO chartevents_40 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1589945
ELSIF ( NEW.itemid >= 454 AND NEW.itemid < 455 ) THEN INSERT INTO chartevents_41 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 950038
ELSIF ( NEW.itemid >= 455 AND NEW.itemid < 456 ) THEN INSERT INTO chartevents_42 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1579681
ELSIF ( NEW.itemid >= 456 AND NEW.itemid < 457 ) THEN INSERT INTO chartevents_43 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1553537
ELSIF ( NEW.itemid >= 457 AND NEW.itemid < 467 ) THEN INSERT INTO chartevents_44 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 392595
ELSIF ( NEW.itemid >= 467 AND NEW.itemid < 468 ) THEN INSERT INTO chartevents_45 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 1155571
ELSIF ( NEW.itemid >= 468 AND NEW.itemid < 478 ) THEN INSERT INTO chartevents_46 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 985720
ELSIF ( NEW.itemid >= 478 AND NEW.itemid < 479 ) THEN INSERT INTO chartevents_47 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 774157
ELSIF ( NEW.itemid >= 479 AND NEW.itemid < 480 ) THEN INSERT INTO chartevents_48 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 917780
ELSIF ( NEW.itemid >= 480 AND NEW.itemid < 547 ) THEN INSERT INTO chartevents_49 VALUES (NEW.*); -- Percentage: 1.4 - Rows: 4595328
ELSIF ( NEW.itemid >= 547 AND NEW.itemid < 548 ) THEN INSERT INTO chartevents_50 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 852968
ELSIF ( NEW.itemid >= 548 AND NEW.itemid < 550 ) THEN INSERT INTO chartevents_51 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 883558
ELSIF ( NEW.itemid >= 550 AND NEW.itemid < 551 ) THEN INSERT INTO chartevents_52 VALUES (NEW.*); -- Percentage: 1.0 - Rows: 3205052
ELSIF ( NEW.itemid >= 551 AND NEW.itemid < 581 ) THEN INSERT INTO chartevents_53 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 1022222
ELSIF ( NEW.itemid >= 581 AND NEW.itemid < 582 ) THEN INSERT INTO chartevents_54 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1641889
ELSIF ( NEW.itemid >= 582 AND NEW.itemid < 593 ) THEN INSERT INTO chartevents_55 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1654497
ELSIF ( NEW.itemid >= 593 AND NEW.itemid < 594 ) THEN INSERT INTO chartevents_56 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 784361
ELSIF ( NEW.itemid >= 594 AND NEW.itemid < 599 ) THEN INSERT INTO chartevents_57 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 913144
ELSIF ( NEW.itemid >= 599 AND NEW.itemid < 600 ) THEN INSERT INTO chartevents_58 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 787137
ELSIF ( NEW.itemid >= 600 AND NEW.itemid < 614 ) THEN INSERT INTO chartevents_59 VALUES (NEW.*); -- Percentage: 0.4 - Rows: 1251345
ELSIF ( NEW.itemid >= 614 AND NEW.itemid < 617 ) THEN INSERT INTO chartevents_60 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 774906
ELSIF ( NEW.itemid >= 617 AND NEW.itemid < 618 ) THEN INSERT INTO chartevents_61 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 962191
ELSIF ( NEW.itemid >= 618 AND NEW.itemid < 619 ) THEN INSERT INTO chartevents_62 VALUES (NEW.*); -- Percentage: 1.0 - Rows: 3386719
ELSIF ( NEW.itemid >= 619 AND NEW.itemid < 621 ) THEN INSERT INTO chartevents_63 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 580529
ELSIF ( NEW.itemid >= 621 AND NEW.itemid < 622 ) THEN INSERT INTO chartevents_64 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 666496
ELSIF ( NEW.itemid >= 622 AND NEW.itemid < 637 ) THEN INSERT INTO chartevents_65 VALUES (NEW.*); -- Percentage: 0.6 - Rows: 2048955
ELSIF ( NEW.itemid >= 637 AND NEW.itemid < 638 ) THEN INSERT INTO chartevents_66 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 954354
ELSIF ( NEW.itemid >= 638 AND NEW.itemid < 640 ) THEN INSERT INTO chartevents_67 VALUES (NEW.*); -- Percentage: 0.0 - Rows: 437
ELSIF ( NEW.itemid >= 640 AND NEW.itemid < 646 ) THEN INSERT INTO chartevents_68 VALUES (NEW.*); -- Percentage: 0.4 - Rows: 1447426
ELSIF ( NEW.itemid >= 646 AND NEW.itemid < 647 ) THEN INSERT INTO chartevents_69 VALUES (NEW.*); -- Percentage: 1.0 - Rows: 3418917
ELSIF ( NEW.itemid >= 647 AND NEW.itemid < 663 ) THEN INSERT INTO chartevents_70 VALUES (NEW.*); -- Percentage: 0.6 - Rows: 2135542
ELSIF ( NEW.itemid >= 663 AND NEW.itemid < 664 ) THEN INSERT INTO chartevents_71 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 774213
ELSIF ( NEW.itemid >= 664 AND NEW.itemid < 674 ) THEN INSERT INTO chartevents_72 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 300570
ELSIF ( NEW.itemid >= 674 AND NEW.itemid < 675 ) THEN INSERT INTO chartevents_73 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 1042512
ELSIF ( NEW.itemid >= 675 AND NEW.itemid < 677 ) THEN INSERT INTO chartevents_74 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 378549
ELSIF ( NEW.itemid >= 677 AND NEW.itemid < 678 ) THEN INSERT INTO chartevents_75 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 772277
ELSIF ( NEW.itemid >= 678 AND NEW.itemid < 679 ) THEN INSERT INTO chartevents_76 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 773891
ELSIF ( NEW.itemid >= 679 AND NEW.itemid < 680 ) THEN INSERT INTO chartevents_77 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 376047
ELSIF ( NEW.itemid >= 680 AND NEW.itemid < 681 ) THEN INSERT INTO chartevents_78 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 740176
ELSIF ( NEW.itemid >= 681 AND NEW.itemid < 704 ) THEN INSERT INTO chartevents_79 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 1099236
ELSIF ( NEW.itemid >= 704 AND NEW.itemid < 705 ) THEN INSERT INTO chartevents_80 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 933238
ELSIF ( NEW.itemid >= 705 AND NEW.itemid < 706 ) THEN INSERT INTO chartevents_81 VALUES (NEW.*); -- Percentage: 0.0 - Rows: 20754
ELSIF ( NEW.itemid >= 706 AND NEW.itemid < 707 ) THEN INSERT INTO chartevents_82 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 727719
ELSIF ( NEW.itemid >= 707 AND NEW.itemid < 708 ) THEN INSERT INTO chartevents_83 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 937064
ELSIF ( NEW.itemid >= 708 AND NEW.itemid < 723 ) THEN INSERT INTO chartevents_84 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 1049706
ELSIF ( NEW.itemid >= 723 AND NEW.itemid < 724 ) THEN INSERT INTO chartevents_85 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 952177
ELSIF ( NEW.itemid >= 724 AND NEW.itemid < 742 ) THEN INSERT INTO chartevents_86 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 321012
ELSIF ( NEW.itemid >= 742 AND NEW.itemid < 743 ) THEN INSERT INTO chartevents_87 VALUES (NEW.*); -- Percentage: 1.0 - Rows: 3464326
ELSIF ( NEW.itemid >= 743 AND NEW.itemid < 834 ) THEN INSERT INTO chartevents_88 VALUES (NEW.*); -- Percentage: 1.8 - Rows: 5925297
ELSIF ( NEW.itemid >= 834 AND NEW.itemid < 835 ) THEN INSERT INTO chartevents_89 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1716561
ELSIF ( NEW.itemid >= 835 AND NEW.itemid < 1046 ) THEN INSERT INTO chartevents_90 VALUES (NEW.*); -- Percentage: 0.4 - Rows: 1417336
ELSIF ( NEW.itemid >= 1046 AND NEW.itemid < 1047 ) THEN INSERT INTO chartevents_91 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 803816
ELSIF ( NEW.itemid >= 1047 AND NEW.itemid < 1087 ) THEN INSERT INTO chartevents_92 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 423898
ELSIF ( NEW.itemid >= 1087 AND NEW.itemid < 1088 ) THEN INSERT INTO chartevents_93 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 592344
ELSIF ( NEW.itemid >= 1088 AND NEW.itemid < 1125 ) THEN INSERT INTO chartevents_94 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 250247
ELSIF ( NEW.itemid >= 1125 AND NEW.itemid < 1126 ) THEN INSERT INTO chartevents_95 VALUES (NEW.*); -- Percentage: 0.9 - Rows: 2955851
ELSIF ( NEW.itemid >= 1126 AND NEW.itemid < 1337 ) THEN INSERT INTO chartevents_96 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 808725
ELSIF ( NEW.itemid >= 1337 AND NEW.itemid < 1338 ) THEN INSERT INTO chartevents_97 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 1083809
ELSIF ( NEW.itemid >= 1338 AND NEW.itemid < 1484 ) THEN INSERT INTO chartevents_98 VALUES (NEW.*); -- Percentage: 0.4 - Rows: 1281335
ELSIF ( NEW.itemid >= 1484 AND NEW.itemid < 1485 ) THEN INSERT INTO chartevents_99 VALUES (NEW.*); -- Percentage: 0.7 - Rows: 2261065
ELSIF ( NEW.itemid >= 1485 AND NEW.itemid < 1703 ) THEN INSERT INTO chartevents_100 VALUES (NEW.*); -- Percentage: 1.1 - Rows: 3561885
ELSIF ( NEW.itemid >= 1703 AND NEW.itemid < 1704 ) THEN INSERT INTO chartevents_101 VALUES (NEW.*); -- Percentage: 0.4 - Rows: 1174868
ELSIF ( NEW.itemid >= 1704 AND NEW.itemid < 1800 ) THEN INSERT INTO chartevents_102 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 293325
ELSIF ( NEW.itemid >= 1800 AND NEW.itemid < 2500 ) THEN INSERT INTO chartevents_103 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 249776
ELSIF ( NEW.itemid >= 2500 AND NEW.itemid < 3327 ) THEN INSERT INTO chartevents_104 VALUES (NEW.*); -- Percentage: 0.9 - Rows: 3010424
ELSIF ( NEW.itemid >= 3327 AND NEW.itemid < 3328 ) THEN INSERT INTO chartevents_105 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 679113
ELSIF ( NEW.itemid >= 3328 AND NEW.itemid < 3420 ) THEN INSERT INTO chartevents_106 VALUES (NEW.*); -- Percentage: 1.6 - Rows: 5208156
ELSIF ( NEW.itemid >= 3420 AND NEW.itemid < 3421 ) THEN INSERT INTO chartevents_107 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 673719
ELSIF ( NEW.itemid >= 3421 AND NEW.itemid < 3450 ) THEN INSERT INTO chartevents_108 VALUES (NEW.*); -- Percentage: 0.8 - Rows: 2785057
ELSIF ( NEW.itemid >= 3450 AND NEW.itemid < 3451 ) THEN INSERT INTO chartevents_109 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1687886
ELSIF ( NEW.itemid >= 3451 AND NEW.itemid < 3500 ) THEN INSERT INTO chartevents_110 VALUES (NEW.*); -- Percentage: 0.7 - Rows: 2445808
ELSIF ( NEW.itemid >= 3500 AND NEW.itemid < 3550 ) THEN INSERT INTO chartevents_111 VALUES (NEW.*); -- Percentage: 0.7 - Rows: 2433936
ELSIF ( NEW.itemid >= 3550 AND NEW.itemid < 3603 ) THEN INSERT INTO chartevents_112 VALUES (NEW.*); -- Percentage: 1.3 - Rows: 4449487
ELSIF ( NEW.itemid >= 3603 AND NEW.itemid < 3604 ) THEN INSERT INTO chartevents_113 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1676872
ELSIF ( NEW.itemid >= 3604 AND NEW.itemid < 3609 ) THEN INSERT INTO chartevents_114 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 476670
ELSIF ( NEW.itemid >= 3609 AND NEW.itemid < 3610 ) THEN INSERT INTO chartevents_115 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1621393
ELSIF ( NEW.itemid >= 3610 AND NEW.itemid < 3645 ) THEN INSERT INTO chartevents_116 VALUES (NEW.*); -- Percentage: 0.7 - Rows: 2309226
ELSIF ( NEW.itemid >= 3645 AND NEW.itemid < 3646 ) THEN INSERT INTO chartevents_117 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 690295
ELSIF ( NEW.itemid >= 3646 AND NEW.itemid < 3656 ) THEN INSERT INTO chartevents_118 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 1009254
ELSIF ( NEW.itemid >= 3656 AND NEW.itemid < 3657 ) THEN INSERT INTO chartevents_119 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 803881
ELSIF ( NEW.itemid >= 3657 AND NEW.itemid < 3700 ) THEN INSERT INTO chartevents_120 VALUES (NEW.*); -- Percentage: 0.7 - Rows: 2367096
ELSIF ( NEW.itemid >= 3700 AND NEW.itemid < 5813 ) THEN INSERT INTO chartevents_121 VALUES (NEW.*); -- Percentage: 0.4 - Rows: 1360432
ELSIF ( NEW.itemid >= 5813 AND NEW.itemid < 5814 ) THEN INSERT INTO chartevents_122 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 982518
ELSIF ( NEW.itemid >= 5814 AND NEW.itemid < 5815 ) THEN INSERT INTO chartevents_123 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 655454
ELSIF ( NEW.itemid >= 5815 AND NEW.itemid < 5816 ) THEN INSERT INTO chartevents_124 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1807316
ELSIF ( NEW.itemid >= 5816 AND NEW.itemid < 5817 ) THEN INSERT INTO chartevents_125 VALUES (NEW.*); -- Percentage: 0.0 - Rows: 34909
ELSIF ( NEW.itemid >= 5817 AND NEW.itemid < 5818 ) THEN INSERT INTO chartevents_126 VALUES (NEW.*); -- Percentage: 0.4 - Rows: 1378959
ELSIF ( NEW.itemid >= 5818 AND NEW.itemid < 5819 ) THEN INSERT INTO chartevents_127 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 178112
ELSIF ( NEW.itemid >= 5819 AND NEW.itemid < 5820 ) THEN INSERT INTO chartevents_128 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1772387
ELSIF ( NEW.itemid >= 5820 AND NEW.itemid < 5821 ) THEN INSERT INTO chartevents_129 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1802684
ELSIF ( NEW.itemid >= 5821 AND NEW.itemid < 8000 ) THEN INSERT INTO chartevents_130 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1622363
ELSIF ( NEW.itemid >= 8000 AND NEW.itemid < 8367 ) THEN INSERT INTO chartevents_131 VALUES (NEW.*); -- Percentage: 0.0 - Rows: 43749
ELSIF ( NEW.itemid >= 8367 AND NEW.itemid < 8368 ) THEN INSERT INTO chartevents_132 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 601818
ELSIF ( NEW.itemid >= 8368 AND NEW.itemid < 8369 ) THEN INSERT INTO chartevents_133 VALUES (NEW.*); -- Percentage: 0.6 - Rows: 2085994
ELSIF ( NEW.itemid >= 8369 AND NEW.itemid < 8441 ) THEN INSERT INTO chartevents_134 VALUES (NEW.*); -- Percentage: 1.6 - Rows: 5266438
ELSIF ( NEW.itemid >= 8441 AND NEW.itemid < 8442 ) THEN INSERT INTO chartevents_135 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1573583
ELSIF ( NEW.itemid >= 8442 AND NEW.itemid < 8480 ) THEN INSERT INTO chartevents_136 VALUES (NEW.*); -- Percentage: 1.2 - Rows: 3870155
ELSIF ( NEW.itemid >= 8480 AND NEW.itemid < 8481 ) THEN INSERT INTO chartevents_137 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 719203
ELSIF ( NEW.itemid >= 8481 AND NEW.itemid < 8518 ) THEN INSERT INTO chartevents_138 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1600973
ELSIF ( NEW.itemid >= 8518 AND NEW.itemid < 8519 ) THEN INSERT INTO chartevents_139 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1687615
ELSIF ( NEW.itemid >= 8519 AND NEW.itemid < 8532 ) THEN INSERT INTO chartevents_140 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 1146136
ELSIF ( NEW.itemid >= 8532 AND NEW.itemid < 8533 ) THEN INSERT INTO chartevents_141 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1619782
ELSIF ( NEW.itemid >= 8533 AND NEW.itemid < 8537 ) THEN INSERT INTO chartevents_142 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 204405
ELSIF ( NEW.itemid >= 8537 AND NEW.itemid < 8538 ) THEN INSERT INTO chartevents_143 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 725866
ELSIF ( NEW.itemid >= 8538 AND NEW.itemid < 8547 ) THEN INSERT INTO chartevents_144 VALUES (NEW.*); -- Percentage: 0.0 - Rows: 302
ELSIF ( NEW.itemid >= 8547 AND NEW.itemid < 8548 ) THEN INSERT INTO chartevents_145 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 976252
ELSIF ( NEW.itemid >= 8548 AND NEW.itemid < 8549 ) THEN INSERT INTO chartevents_146 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 649745
ELSIF ( NEW.itemid >= 8549 AND NEW.itemid < 8550 ) THEN INSERT INTO chartevents_147 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1804988
ELSIF ( NEW.itemid >= 8550 AND NEW.itemid < 8551 ) THEN INSERT INTO chartevents_148 VALUES (NEW.*); -- Percentage: 0.0 - Rows: 33554
ELSIF ( NEW.itemid >= 8551 AND NEW.itemid < 8552 ) THEN INSERT INTO chartevents_149 VALUES (NEW.*); -- Percentage: 0.4 - Rows: 1375295
ELSIF ( NEW.itemid >= 8552 AND NEW.itemid < 8553 ) THEN INSERT INTO chartevents_150 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 174222
ELSIF ( NEW.itemid >= 8553 AND NEW.itemid < 8554 ) THEN INSERT INTO chartevents_151 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1769925
ELSIF ( NEW.itemid >= 8554 AND NEW.itemid < 8555 ) THEN INSERT INTO chartevents_152 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1796313
ELSIF ( NEW.itemid >= 8555 AND NEW.itemid < 220000 ) THEN INSERT INTO chartevents_153 VALUES (NEW.*); -- Percentage: 0.0 - Rows: 18753
ELSIF ( NEW.itemid >= 220000 AND NEW.itemid < 220045 ) THEN INSERT INTO chartevents_154 VALUES (NEW.*); -- Percentage:  - Rows:
ELSIF ( NEW.itemid >= 220045 AND NEW.itemid < 220046 ) THEN INSERT INTO chartevents_155 VALUES (NEW.*); -- Percentage: 0.8 - Rows: 2762225
ELSIF ( NEW.itemid >= 220046 AND NEW.itemid < 220048 ) THEN INSERT INTO chartevents_156 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 431909
ELSIF ( NEW.itemid >= 220048 AND NEW.itemid < 220049 ) THEN INSERT INTO chartevents_157 VALUES (NEW.*); -- Percentage: 0.6 - Rows: 2023672
ELSIF ( NEW.itemid >= 220049 AND NEW.itemid < 220050 ) THEN INSERT INTO chartevents_158 VALUES (NEW.*); -- Percentage:  - Rows:
ELSIF ( NEW.itemid >= 220050 AND NEW.itemid < 220051 ) THEN INSERT INTO chartevents_159 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 1149788
ELSIF ( NEW.itemid >= 220051 AND NEW.itemid < 220052 ) THEN INSERT INTO chartevents_160 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 1149537
ELSIF ( NEW.itemid >= 220052 AND NEW.itemid < 220053 ) THEN INSERT INTO chartevents_161 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 1156173
ELSIF ( NEW.itemid >= 220053 AND NEW.itemid < 220074 ) THEN INSERT INTO chartevents_162 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 648200
ELSIF ( NEW.itemid >= 220074 AND NEW.itemid < 220179 ) THEN INSERT INTO chartevents_163 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 526472
ELSIF ( NEW.itemid >= 220179 AND NEW.itemid < 220180 ) THEN INSERT INTO chartevents_164 VALUES (NEW.*); -- Percentage: 0.4 - Rows: 1290488
ELSIF ( NEW.itemid >= 220180 AND NEW.itemid < 220181 ) THEN INSERT INTO chartevents_165 VALUES (NEW.*); -- Percentage: 0.4 - Rows: 1289885
ELSIF ( NEW.itemid >= 220181 AND NEW.itemid < 220182 ) THEN INSERT INTO chartevents_166 VALUES (NEW.*); -- Percentage: 0.4 - Rows: 1292916
ELSIF ( NEW.itemid >= 220182 AND NEW.itemid < 220210 ) THEN INSERT INTO chartevents_167 VALUES (NEW.*); -- Percentage: 0.0 - Rows: 208
ELSIF ( NEW.itemid >= 220210 AND NEW.itemid < 220211 ) THEN INSERT INTO chartevents_168 VALUES (NEW.*); -- Percentage: 0.8 - Rows: 2737105
ELSIF ( NEW.itemid >= 220211 AND NEW.itemid < 220277 ) THEN INSERT INTO chartevents_169 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 466344
ELSIF ( NEW.itemid >= 220277 AND NEW.itemid < 220278 ) THEN INSERT INTO chartevents_170 VALUES (NEW.*); -- Percentage: 0.8 - Rows: 2671816
ELSIF ( NEW.itemid >= 220278 AND NEW.itemid < 222000 ) THEN INSERT INTO chartevents_171 VALUES (NEW.*); -- Percentage: 1.0 - Rows: 3262258
ELSIF ( NEW.itemid >= 222000 AND NEW.itemid < 223792 ) THEN INSERT INTO chartevents_172 VALUES (NEW.*); -- Percentage: 1.2 - Rows: 4068153
ELSIF ( NEW.itemid >= 223792 AND NEW.itemid < 223793 ) THEN INSERT INTO chartevents_173 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 765274
ELSIF ( NEW.itemid >= 223793 AND NEW.itemid < 223800 ) THEN INSERT INTO chartevents_174 VALUES (NEW.*); -- Percentage: 0.3 - Rows: 1139355
ELSIF ( NEW.itemid >= 223800 AND NEW.itemid < 223850 ) THEN INSERT INTO chartevents_175 VALUES (NEW.*); -- Percentage: 0.6 - Rows: 1983602
ELSIF ( NEW.itemid >= 223850 AND NEW.itemid < 223900 ) THEN INSERT INTO chartevents_176 VALUES (NEW.*); -- Percentage: 0.7 - Rows: 2185541
ELSIF ( NEW.itemid >= 223900 AND NEW.itemid < 223912 ) THEN INSERT INTO chartevents_177 VALUES (NEW.*); -- Percentage: 1.1 - Rows: 3552998
ELSIF ( NEW.itemid >= 223912 AND NEW.itemid < 223925 ) THEN INSERT INTO chartevents_178 VALUES (NEW.*); -- Percentage: 0.7 - Rows: 2289753
ELSIF ( NEW.itemid >= 223925 AND NEW.itemid < 223950 ) THEN INSERT INTO chartevents_179 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1610057
ELSIF ( NEW.itemid >= 223950 AND NEW.itemid < 223974 ) THEN INSERT INTO chartevents_180 VALUES (NEW.*); -- Percentage: 0.1 - Rows: 395061
ELSIF ( NEW.itemid >= 223974 AND NEW.itemid < 224000 ) THEN INSERT INTO chartevents_181 VALUES (NEW.*); -- Percentage: 1.5 - Rows: 4797667
ELSIF ( NEW.itemid >= 224000 AND NEW.itemid < 224020 ) THEN INSERT INTO chartevents_182 VALUES (NEW.*); -- Percentage: 1.0 - Rows: 3317320
ELSIF ( NEW.itemid >= 224020 AND NEW.itemid < 224040 ) THEN INSERT INTO chartevents_183 VALUES (NEW.*); -- Percentage: 0.8 - Rows: 2611372
ELSIF ( NEW.itemid >= 224040 AND NEW.itemid < 224080 ) THEN INSERT INTO chartevents_184 VALUES (NEW.*); -- Percentage: 1.2 - Rows: 4089672
ELSIF ( NEW.itemid >= 224080 AND NEW.itemid < 224083 ) THEN INSERT INTO chartevents_185 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1559194
ELSIF ( NEW.itemid >= 224083 AND NEW.itemid < 224087 ) THEN INSERT INTO chartevents_186 VALUES (NEW.*); -- Percentage: 0.6 - Rows: 2089736
ELSIF ( NEW.itemid >= 224087 AND NEW.itemid < 224093 ) THEN INSERT INTO chartevents_187 VALUES (NEW.*); -- Percentage: 0.4 - Rows: 1465008
ELSIF ( NEW.itemid >= 224093 AND NEW.itemid < 224094 ) THEN INSERT INTO chartevents_188 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 717326
ELSIF ( NEW.itemid >= 224094 AND NEW.itemid < 224300 ) THEN INSERT INTO chartevents_189 VALUES (NEW.*); -- Percentage: 0.9 - Rows: 2933324
ELSIF ( NEW.itemid >= 224300 AND NEW.itemid < 224642 ) THEN INSERT INTO chartevents_190 VALUES (NEW.*); -- Percentage: 0.9 - Rows: 3110922
ELSIF ( NEW.itemid >= 224642 AND NEW.itemid < 224643 ) THEN INSERT INTO chartevents_191 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 618565
ELSIF ( NEW.itemid >= 224643 AND NEW.itemid < 224650 ) THEN INSERT INTO chartevents_192 VALUES (NEW.*); -- Percentage: 0.0 - Rows: 1165
ELSIF ( NEW.itemid >= 224650 AND NEW.itemid < 224651 ) THEN INSERT INTO chartevents_193 VALUES (NEW.*); -- Percentage: 0.6 - Rows: 1849287
ELSIF ( NEW.itemid >= 224651 AND NEW.itemid < 224700 ) THEN INSERT INTO chartevents_194 VALUES (NEW.*); -- Percentage: 1.2 - Rows: 4059618
ELSIF ( NEW.itemid >= 224700 AND NEW.itemid < 224800 ) THEN INSERT INTO chartevents_195 VALUES (NEW.*); -- Percentage: 1.0 - Rows: 3154406
ELSIF ( NEW.itemid >= 224800 AND NEW.itemid < 224900 ) THEN INSERT INTO chartevents_196 VALUES (NEW.*); -- Percentage: 0.9 - Rows: 2873716
ELSIF ( NEW.itemid >= 224900 AND NEW.itemid < 225000 ) THEN INSERT INTO chartevents_197 VALUES (NEW.*); -- Percentage: 0.8 - Rows: 2659813
ELSIF ( NEW.itemid >= 225000 AND NEW.itemid < 225500 ) THEN INSERT INTO chartevents_198 VALUES (NEW.*); -- Percentage: 1.1 - Rows: 3763143
ELSIF ( NEW.itemid >= 225500 AND NEW.itemid < 226000 ) THEN INSERT INTO chartevents_199 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1718572
ELSIF ( NEW.itemid >= 226000 AND NEW.itemid < 226500 ) THEN INSERT INTO chartevents_200 VALUES (NEW.*); -- Percentage: 0.8 - Rows: 2662741
ELSIF ( NEW.itemid >= 226500 AND NEW.itemid < 227000 ) THEN INSERT INTO chartevents_201 VALUES (NEW.*); -- Percentage: 0.5 - Rows: 1605091
ELSIF ( NEW.itemid >= 227000 AND NEW.itemid < 227500 ) THEN INSERT INTO chartevents_202 VALUES (NEW.*); -- Percentage: 1.7 - Rows: 5553957
ELSIF ( NEW.itemid >= 227500 AND NEW.itemid < 227958 ) THEN INSERT INTO chartevents_203 VALUES (NEW.*); -- Percentage: 1.7 - Rows: 5627006
ELSIF ( NEW.itemid >= 227958 AND NEW.itemid < 227959 ) THEN INSERT INTO chartevents_204 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 716961
ELSIF ( NEW.itemid >= 227959 AND NEW.itemid < 227969 ) THEN INSERT INTO chartevents_205 VALUES (NEW.*); -- Percentage: 0.2 - Rows: 816157
ELSIF ( NEW.itemid >= 227969 AND NEW.itemid < 227970 ) THEN INSERT INTO chartevents_206 VALUES (NEW.*); -- Percentage: 0.6 - Rows: 1862707
ELSIF ( NEW.itemid >= 227970 AND NEW.itemid < 1000000 ) THEN INSERT INTO chartevents_207 VALUES (NEW.*); -- Percentage: 0.7 - Rows: 2313406
ELSE
	INSERT INTO chartevents_null VALUES (NEW.*);
END IF;
RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_chartevents_trigger
    BEFORE INSERT ON chartevents
    FOR EACH ROW EXECUTE PROCEDURE chartevents_insert_trigger();

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
