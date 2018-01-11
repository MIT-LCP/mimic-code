-- ----------------------------------------------------------------
--
-- This is a script to add the MIMIC-III indexes for Postgres.
--
-- ----------------------------------------------------------------

-- If running scripts individually, you can set the schema where all tables are created as follows:
-- SET search_path TO mimiciii;

-- Restoring the search path to its default value can be accomplished as follows:
-- SET search_path TO "$user",public;

-------------
-- ADMISSIONS
-------------

DROP INDEX IF EXISTS ADMISSIONS_idx01;
CREATE INDEX ADMISSIONS_IDX01
  ON ADMISSIONS (SUBJECT_ID);

DROP INDEX IF EXISTS ADMISSIONS_idx02;
CREATE INDEX ADMISSIONS_IDX02
  ON ADMISSIONS (HADM_ID);

-- DROP INDEX IF EXISTS ADMISSIONS_idx03;
-- CREATE INDEX ADMISSIONS_IDX03
--   ON ADMISSIONS (ADMISSION_TYPE);


-----------
--CALLOUT--
-----------

DROP INDEX IF EXISTS CALLOUT_idx01;
CREATE INDEX CALLOUT_IDX01
  ON CALLOUT (SUBJECT_ID);

DROP INDEX IF EXISTS CALLOUT_idx02;
CREATE INDEX CALLOUT_IDX02
  ON CALLOUT (HADM_ID);

-- DROP INDEX IF EXISTS CALLOUT_idx03;
-- CREATE INDEX CALLOUT_IDX03
--   ON CALLOUT (CALLOUT_SERVICE);

-- DROP INDEX IF EXISTS CALLOUT_idx04;
-- CREATE INDEX CALLOUT_IDX04
--   ON CALLOUT (CURR_WARDID, CALLOUT_WARDID,
--     DISCHARGE_WARDID);

-- DROP INDEX IF EXISTS CALLOUT_idx05;
-- CREATE INDEX CALLOUT_IDX05
--   ON CALLOUT (CALLOUT_STATUS,
--     CALLOUT_OUTCOME);

-- DROP INDEX IF EXISTS CALLOUT_idx06;
-- CREATE INDEX CALLOUT_IDX06
--   ON CALLOUT (CREATETIME, UPDATETIME,
--     ACKNOWLEDGETIME, OUTCOMETIME);

---------------
-- CAREGIVERS
---------------

-- DROP INDEX IF EXISTS CAREGIVERS_idx01;
-- CREATE INDEX CAREGIVERS_IDX01
--   ON CAREGIVERS (CGID, LABEL);

---------------
-- CHARTEVENTS
---------------

-- CHARTEVENTS is built in 10 partitions which are inherited by a single mother table, "CHARTEVENTS"
-- Therefore, indices need to be added on every single inherited (or partitioned) table.

DROP INDEX IF EXISTS chartevents_1_idx01;
CREATE INDEX chartevents_1_idx01 ON chartevents_1 (itemid);
DROP INDEX IF EXISTS chartevents_2_idx01;
CREATE INDEX chartevents_2_idx01 ON chartevents_2 (itemid);
DROP INDEX IF EXISTS chartevents_3_idx01;
CREATE INDEX chartevents_3_idx01 ON chartevents_3 (itemid);
DROP INDEX IF EXISTS chartevents_4_idx01;
CREATE INDEX chartevents_4_idx01 ON chartevents_4 (itemid);
DROP INDEX IF EXISTS chartevents_5_idx01;
CREATE INDEX chartevents_5_idx01 ON chartevents_5 (itemid);
DROP INDEX IF EXISTS chartevents_6_idx01;
CREATE INDEX chartevents_6_idx01 ON chartevents_6 (itemid);
DROP INDEX IF EXISTS chartevents_7_idx01;
CREATE INDEX chartevents_7_idx01 ON chartevents_7 (itemid);
DROP INDEX IF EXISTS chartevents_8_idx01;
CREATE INDEX chartevents_8_idx01 ON chartevents_8 (itemid);
DROP INDEX IF EXISTS chartevents_9_idx01;
CREATE INDEX chartevents_9_idx01 ON chartevents_9 (itemid);
DROP INDEX IF EXISTS chartevents_10_idx01;
CREATE INDEX chartevents_10_idx01 ON chartevents_10 (itemid);
DROP INDEX IF EXISTS chartevents_11_idx01;
CREATE INDEX chartevents_11_idx01 ON chartevents_11 (itemid);
DROP INDEX IF EXISTS chartevents_12_idx01;
CREATE INDEX chartevents_12_idx01 ON chartevents_12 (itemid);
DROP INDEX IF EXISTS chartevents_13_idx01;
CREATE INDEX chartevents_13_idx01 ON chartevents_13 (itemid);
DROP INDEX IF EXISTS chartevents_14_idx01;
CREATE INDEX chartevents_14_idx01 ON chartevents_14 (itemid);
DROP INDEX IF EXISTS chartevents_15_idx01;
CREATE INDEX chartevents_15_idx01 ON chartevents_15 (itemid);
DROP INDEX IF EXISTS chartevents_16_idx01;
CREATE INDEX chartevents_16_idx01 ON chartevents_16 (itemid);
DROP INDEX IF EXISTS chartevents_17_idx01;
CREATE INDEX chartevents_17_idx01 ON chartevents_17 (itemid);

-- only create these indices if we have sufficient partitions
DO $$
BEGIN

IF EXISTS (
    SELECT 1
    FROM         pg_class c
    INNER JOIN   pg_namespace n
      ON n.oid = c.relnamespace
    WHERE  c.relname = 'chartevents_207'
  ) THEN

  DROP INDEX IF EXISTS chartevents_18_idx01;
  CREATE INDEX chartevents_18_idx01 ON chartevents_18 (itemid);
  DROP INDEX IF EXISTS chartevents_19_idx01;
  CREATE INDEX chartevents_19_idx01 ON chartevents_19 (itemid);
  DROP INDEX IF EXISTS chartevents_20_idx01;
  CREATE INDEX chartevents_20_idx01 ON chartevents_20 (itemid);
  DROP INDEX IF EXISTS chartevents_21_idx01;
  CREATE INDEX chartevents_21_idx01 ON chartevents_21 (itemid);
  DROP INDEX IF EXISTS chartevents_22_idx01;
  CREATE INDEX chartevents_22_idx01 ON chartevents_22 (itemid);
  DROP INDEX IF EXISTS chartevents_23_idx01;
  CREATE INDEX chartevents_23_idx01 ON chartevents_23 (itemid);
  DROP INDEX IF EXISTS chartevents_24_idx01;
  CREATE INDEX chartevents_24_idx01 ON chartevents_24 (itemid);
  DROP INDEX IF EXISTS chartevents_25_idx01;
  CREATE INDEX chartevents_25_idx01 ON chartevents_25 (itemid);
  DROP INDEX IF EXISTS chartevents_26_idx01;
  CREATE INDEX chartevents_26_idx01 ON chartevents_26 (itemid);
  DROP INDEX IF EXISTS chartevents_27_idx01;
  CREATE INDEX chartevents_27_idx01 ON chartevents_27 (itemid);
  DROP INDEX IF EXISTS chartevents_28_idx01;
  CREATE INDEX chartevents_28_idx01 ON chartevents_28 (itemid);
  DROP INDEX IF EXISTS chartevents_29_idx01;
  CREATE INDEX chartevents_29_idx01 ON chartevents_29 (itemid);
  DROP INDEX IF EXISTS chartevents_30_idx01;
  CREATE INDEX chartevents_30_idx01 ON chartevents_30 (itemid);
  DROP INDEX IF EXISTS chartevents_31_idx01;
  CREATE INDEX chartevents_31_idx01 ON chartevents_31 (itemid);
  DROP INDEX IF EXISTS chartevents_32_idx01;
  CREATE INDEX chartevents_32_idx01 ON chartevents_32 (itemid);
  DROP INDEX IF EXISTS chartevents_33_idx01;
  CREATE INDEX chartevents_33_idx01 ON chartevents_33 (itemid);
  DROP INDEX IF EXISTS chartevents_34_idx01;
  CREATE INDEX chartevents_34_idx01 ON chartevents_34 (itemid);
  DROP INDEX IF EXISTS chartevents_35_idx01;
  CREATE INDEX chartevents_35_idx01 ON chartevents_35 (itemid);
  DROP INDEX IF EXISTS chartevents_36_idx01;
  CREATE INDEX chartevents_36_idx01 ON chartevents_36 (itemid);
  DROP INDEX IF EXISTS chartevents_37_idx01;
  CREATE INDEX chartevents_37_idx01 ON chartevents_37 (itemid);
  DROP INDEX IF EXISTS chartevents_38_idx01;
  CREATE INDEX chartevents_38_idx01 ON chartevents_38 (itemid);
  DROP INDEX IF EXISTS chartevents_39_idx01;
  CREATE INDEX chartevents_39_idx01 ON chartevents_39 (itemid);
  DROP INDEX IF EXISTS chartevents_40_idx01;
  CREATE INDEX chartevents_40_idx01 ON chartevents_40 (itemid);
  DROP INDEX IF EXISTS chartevents_41_idx01;
  CREATE INDEX chartevents_41_idx01 ON chartevents_41 (itemid);
  DROP INDEX IF EXISTS chartevents_42_idx01;
  CREATE INDEX chartevents_42_idx01 ON chartevents_42 (itemid);
  DROP INDEX IF EXISTS chartevents_43_idx01;
  CREATE INDEX chartevents_43_idx01 ON chartevents_43 (itemid);
  DROP INDEX IF EXISTS chartevents_44_idx01;
  CREATE INDEX chartevents_44_idx01 ON chartevents_44 (itemid);
  DROP INDEX IF EXISTS chartevents_45_idx01;
  CREATE INDEX chartevents_45_idx01 ON chartevents_45 (itemid);
  DROP INDEX IF EXISTS chartevents_46_idx01;
  CREATE INDEX chartevents_46_idx01 ON chartevents_46 (itemid);
  DROP INDEX IF EXISTS chartevents_47_idx01;
  CREATE INDEX chartevents_47_idx01 ON chartevents_47 (itemid);
  DROP INDEX IF EXISTS chartevents_48_idx01;
  CREATE INDEX chartevents_48_idx01 ON chartevents_48 (itemid);
  DROP INDEX IF EXISTS chartevents_49_idx01;
  CREATE INDEX chartevents_49_idx01 ON chartevents_49 (itemid);
  DROP INDEX IF EXISTS chartevents_50_idx01;
  CREATE INDEX chartevents_50_idx01 ON chartevents_50 (itemid);
  DROP INDEX IF EXISTS chartevents_51_idx01;
  CREATE INDEX chartevents_51_idx01 ON chartevents_51 (itemid);
  DROP INDEX IF EXISTS chartevents_52_idx01;
  CREATE INDEX chartevents_52_idx01 ON chartevents_52 (itemid);
  DROP INDEX IF EXISTS chartevents_53_idx01;
  CREATE INDEX chartevents_53_idx01 ON chartevents_53 (itemid);
  DROP INDEX IF EXISTS chartevents_54_idx01;
  CREATE INDEX chartevents_54_idx01 ON chartevents_54 (itemid);
  DROP INDEX IF EXISTS chartevents_55_idx01;
  CREATE INDEX chartevents_55_idx01 ON chartevents_55 (itemid);
  DROP INDEX IF EXISTS chartevents_56_idx01;
  CREATE INDEX chartevents_56_idx01 ON chartevents_56 (itemid);
  DROP INDEX IF EXISTS chartevents_57_idx01;
  CREATE INDEX chartevents_57_idx01 ON chartevents_57 (itemid);
  DROP INDEX IF EXISTS chartevents_58_idx01;
  CREATE INDEX chartevents_58_idx01 ON chartevents_58 (itemid);
  DROP INDEX IF EXISTS chartevents_59_idx01;
  CREATE INDEX chartevents_59_idx01 ON chartevents_59 (itemid);
  DROP INDEX IF EXISTS chartevents_60_idx01;
  CREATE INDEX chartevents_60_idx01 ON chartevents_60 (itemid);
  DROP INDEX IF EXISTS chartevents_61_idx01;
  CREATE INDEX chartevents_61_idx01 ON chartevents_61 (itemid);
  DROP INDEX IF EXISTS chartevents_62_idx01;
  CREATE INDEX chartevents_62_idx01 ON chartevents_62 (itemid);
  DROP INDEX IF EXISTS chartevents_63_idx01;
  CREATE INDEX chartevents_63_idx01 ON chartevents_63 (itemid);
  DROP INDEX IF EXISTS chartevents_64_idx01;
  CREATE INDEX chartevents_64_idx01 ON chartevents_64 (itemid);
  DROP INDEX IF EXISTS chartevents_65_idx01;
  CREATE INDEX chartevents_65_idx01 ON chartevents_65 (itemid);
  DROP INDEX IF EXISTS chartevents_66_idx01;
  CREATE INDEX chartevents_66_idx01 ON chartevents_66 (itemid);
  DROP INDEX IF EXISTS chartevents_67_idx01;
  CREATE INDEX chartevents_67_idx01 ON chartevents_67 (itemid);
  DROP INDEX IF EXISTS chartevents_68_idx01;
  CREATE INDEX chartevents_68_idx01 ON chartevents_68 (itemid);
  DROP INDEX IF EXISTS chartevents_69_idx01;
  CREATE INDEX chartevents_69_idx01 ON chartevents_69 (itemid);
  DROP INDEX IF EXISTS chartevents_70_idx01;
  CREATE INDEX chartevents_70_idx01 ON chartevents_70 (itemid);
  DROP INDEX IF EXISTS chartevents_71_idx01;
  CREATE INDEX chartevents_71_idx01 ON chartevents_71 (itemid);
  DROP INDEX IF EXISTS chartevents_72_idx01;
  CREATE INDEX chartevents_72_idx01 ON chartevents_72 (itemid);
  DROP INDEX IF EXISTS chartevents_73_idx01;
  CREATE INDEX chartevents_73_idx01 ON chartevents_73 (itemid);
  DROP INDEX IF EXISTS chartevents_74_idx01;
  CREATE INDEX chartevents_74_idx01 ON chartevents_74 (itemid);
  DROP INDEX IF EXISTS chartevents_75_idx01;
  CREATE INDEX chartevents_75_idx01 ON chartevents_75 (itemid);
  DROP INDEX IF EXISTS chartevents_76_idx01;
  CREATE INDEX chartevents_76_idx01 ON chartevents_76 (itemid);
  DROP INDEX IF EXISTS chartevents_77_idx01;
  CREATE INDEX chartevents_77_idx01 ON chartevents_77 (itemid);
  DROP INDEX IF EXISTS chartevents_78_idx01;
  CREATE INDEX chartevents_78_idx01 ON chartevents_78 (itemid);
  DROP INDEX IF EXISTS chartevents_79_idx01;
  CREATE INDEX chartevents_79_idx01 ON chartevents_79 (itemid);
  DROP INDEX IF EXISTS chartevents_80_idx01;
  CREATE INDEX chartevents_80_idx01 ON chartevents_80 (itemid);
  DROP INDEX IF EXISTS chartevents_81_idx01;
  CREATE INDEX chartevents_81_idx01 ON chartevents_81 (itemid);
  DROP INDEX IF EXISTS chartevents_82_idx01;
  CREATE INDEX chartevents_82_idx01 ON chartevents_82 (itemid);
  DROP INDEX IF EXISTS chartevents_83_idx01;
  CREATE INDEX chartevents_83_idx01 ON chartevents_83 (itemid);
  DROP INDEX IF EXISTS chartevents_84_idx01;
  CREATE INDEX chartevents_84_idx01 ON chartevents_84 (itemid);
  DROP INDEX IF EXISTS chartevents_85_idx01;
  CREATE INDEX chartevents_85_idx01 ON chartevents_85 (itemid);
  DROP INDEX IF EXISTS chartevents_86_idx01;
  CREATE INDEX chartevents_86_idx01 ON chartevents_86 (itemid);
  DROP INDEX IF EXISTS chartevents_87_idx01;
  CREATE INDEX chartevents_87_idx01 ON chartevents_87 (itemid);
  DROP INDEX IF EXISTS chartevents_88_idx01;
  CREATE INDEX chartevents_88_idx01 ON chartevents_88 (itemid);
  DROP INDEX IF EXISTS chartevents_89_idx01;
  CREATE INDEX chartevents_89_idx01 ON chartevents_89 (itemid);
  DROP INDEX IF EXISTS chartevents_90_idx01;
  CREATE INDEX chartevents_90_idx01 ON chartevents_90 (itemid);
  DROP INDEX IF EXISTS chartevents_91_idx01;
  CREATE INDEX chartevents_91_idx01 ON chartevents_91 (itemid);
  DROP INDEX IF EXISTS chartevents_92_idx01;
  CREATE INDEX chartevents_92_idx01 ON chartevents_92 (itemid);
  DROP INDEX IF EXISTS chartevents_93_idx01;
  CREATE INDEX chartevents_93_idx01 ON chartevents_93 (itemid);
  DROP INDEX IF EXISTS chartevents_94_idx01;
  CREATE INDEX chartevents_94_idx01 ON chartevents_94 (itemid);
  DROP INDEX IF EXISTS chartevents_95_idx01;
  CREATE INDEX chartevents_95_idx01 ON chartevents_95 (itemid);
  DROP INDEX IF EXISTS chartevents_96_idx01;
  CREATE INDEX chartevents_96_idx01 ON chartevents_96 (itemid);
  DROP INDEX IF EXISTS chartevents_97_idx01;
  CREATE INDEX chartevents_97_idx01 ON chartevents_97 (itemid);
  DROP INDEX IF EXISTS chartevents_98_idx01;
  CREATE INDEX chartevents_98_idx01 ON chartevents_98 (itemid);
  DROP INDEX IF EXISTS chartevents_99_idx01;
  CREATE INDEX chartevents_99_idx01 ON chartevents_99 (itemid);
  DROP INDEX IF EXISTS chartevents_100_idx01;
  CREATE INDEX chartevents_100_idx01 ON chartevents_100 (itemid);
  DROP INDEX IF EXISTS chartevents_101_idx01;
  CREATE INDEX chartevents_101_idx01 ON chartevents_101 (itemid);
  DROP INDEX IF EXISTS chartevents_102_idx01;
  CREATE INDEX chartevents_102_idx01 ON chartevents_102 (itemid);
  DROP INDEX IF EXISTS chartevents_103_idx01;
  CREATE INDEX chartevents_103_idx01 ON chartevents_103 (itemid);
  DROP INDEX IF EXISTS chartevents_104_idx01;
  CREATE INDEX chartevents_104_idx01 ON chartevents_104 (itemid);
  DROP INDEX IF EXISTS chartevents_105_idx01;
  CREATE INDEX chartevents_105_idx01 ON chartevents_105 (itemid);
  DROP INDEX IF EXISTS chartevents_106_idx01;
  CREATE INDEX chartevents_106_idx01 ON chartevents_106 (itemid);
  DROP INDEX IF EXISTS chartevents_107_idx01;
  CREATE INDEX chartevents_107_idx01 ON chartevents_107 (itemid);
  DROP INDEX IF EXISTS chartevents_108_idx01;
  CREATE INDEX chartevents_108_idx01 ON chartevents_108 (itemid);
  DROP INDEX IF EXISTS chartevents_109_idx01;
  CREATE INDEX chartevents_109_idx01 ON chartevents_109 (itemid);
  DROP INDEX IF EXISTS chartevents_110_idx01;
  CREATE INDEX chartevents_110_idx01 ON chartevents_110 (itemid);
  DROP INDEX IF EXISTS chartevents_111_idx01;
  CREATE INDEX chartevents_111_idx01 ON chartevents_111 (itemid);
  DROP INDEX IF EXISTS chartevents_112_idx01;
  CREATE INDEX chartevents_112_idx01 ON chartevents_112 (itemid);
  DROP INDEX IF EXISTS chartevents_113_idx01;
  CREATE INDEX chartevents_113_idx01 ON chartevents_113 (itemid);
  DROP INDEX IF EXISTS chartevents_114_idx01;
  CREATE INDEX chartevents_114_idx01 ON chartevents_114 (itemid);
  DROP INDEX IF EXISTS chartevents_115_idx01;
  CREATE INDEX chartevents_115_idx01 ON chartevents_115 (itemid);
  DROP INDEX IF EXISTS chartevents_116_idx01;
  CREATE INDEX chartevents_116_idx01 ON chartevents_116 (itemid);
  DROP INDEX IF EXISTS chartevents_117_idx01;
  CREATE INDEX chartevents_117_idx01 ON chartevents_117 (itemid);
  DROP INDEX IF EXISTS chartevents_118_idx01;
  CREATE INDEX chartevents_118_idx01 ON chartevents_118 (itemid);
  DROP INDEX IF EXISTS chartevents_119_idx01;
  CREATE INDEX chartevents_119_idx01 ON chartevents_119 (itemid);
  DROP INDEX IF EXISTS chartevents_120_idx01;
  CREATE INDEX chartevents_120_idx01 ON chartevents_120 (itemid);
  DROP INDEX IF EXISTS chartevents_121_idx01;
  CREATE INDEX chartevents_121_idx01 ON chartevents_121 (itemid);
  DROP INDEX IF EXISTS chartevents_122_idx01;
  CREATE INDEX chartevents_122_idx01 ON chartevents_122 (itemid);
  DROP INDEX IF EXISTS chartevents_123_idx01;
  CREATE INDEX chartevents_123_idx01 ON chartevents_123 (itemid);
  DROP INDEX IF EXISTS chartevents_124_idx01;
  CREATE INDEX chartevents_124_idx01 ON chartevents_124 (itemid);
  DROP INDEX IF EXISTS chartevents_125_idx01;
  CREATE INDEX chartevents_125_idx01 ON chartevents_125 (itemid);
  DROP INDEX IF EXISTS chartevents_126_idx01;
  CREATE INDEX chartevents_126_idx01 ON chartevents_126 (itemid);
  DROP INDEX IF EXISTS chartevents_127_idx01;
  CREATE INDEX chartevents_127_idx01 ON chartevents_127 (itemid);
  DROP INDEX IF EXISTS chartevents_128_idx01;
  CREATE INDEX chartevents_128_idx01 ON chartevents_128 (itemid);
  DROP INDEX IF EXISTS chartevents_129_idx01;
  CREATE INDEX chartevents_129_idx01 ON chartevents_129 (itemid);
  DROP INDEX IF EXISTS chartevents_130_idx01;
  CREATE INDEX chartevents_130_idx01 ON chartevents_130 (itemid);
  DROP INDEX IF EXISTS chartevents_131_idx01;
  CREATE INDEX chartevents_131_idx01 ON chartevents_131 (itemid);
  DROP INDEX IF EXISTS chartevents_132_idx01;
  CREATE INDEX chartevents_132_idx01 ON chartevents_132 (itemid);
  DROP INDEX IF EXISTS chartevents_133_idx01;
  CREATE INDEX chartevents_133_idx01 ON chartevents_133 (itemid);
  DROP INDEX IF EXISTS chartevents_134_idx01;
  CREATE INDEX chartevents_134_idx01 ON chartevents_134 (itemid);
  DROP INDEX IF EXISTS chartevents_135_idx01;
  CREATE INDEX chartevents_135_idx01 ON chartevents_135 (itemid);
  DROP INDEX IF EXISTS chartevents_136_idx01;
  CREATE INDEX chartevents_136_idx01 ON chartevents_136 (itemid);
  DROP INDEX IF EXISTS chartevents_137_idx01;
  CREATE INDEX chartevents_137_idx01 ON chartevents_137 (itemid);
  DROP INDEX IF EXISTS chartevents_138_idx01;
  CREATE INDEX chartevents_138_idx01 ON chartevents_138 (itemid);
  DROP INDEX IF EXISTS chartevents_139_idx01;
  CREATE INDEX chartevents_139_idx01 ON chartevents_139 (itemid);
  DROP INDEX IF EXISTS chartevents_140_idx01;
  CREATE INDEX chartevents_140_idx01 ON chartevents_140 (itemid);
  DROP INDEX IF EXISTS chartevents_141_idx01;
  CREATE INDEX chartevents_141_idx01 ON chartevents_141 (itemid);
  DROP INDEX IF EXISTS chartevents_142_idx01;
  CREATE INDEX chartevents_142_idx01 ON chartevents_142 (itemid);
  DROP INDEX IF EXISTS chartevents_143_idx01;
  CREATE INDEX chartevents_143_idx01 ON chartevents_143 (itemid);
  DROP INDEX IF EXISTS chartevents_144_idx01;
  CREATE INDEX chartevents_144_idx01 ON chartevents_144 (itemid);
  DROP INDEX IF EXISTS chartevents_145_idx01;
  CREATE INDEX chartevents_145_idx01 ON chartevents_145 (itemid);
  DROP INDEX IF EXISTS chartevents_146_idx01;
  CREATE INDEX chartevents_146_idx01 ON chartevents_146 (itemid);
  DROP INDEX IF EXISTS chartevents_147_idx01;
  CREATE INDEX chartevents_147_idx01 ON chartevents_147 (itemid);
  DROP INDEX IF EXISTS chartevents_148_idx01;
  CREATE INDEX chartevents_148_idx01 ON chartevents_148 (itemid);
  DROP INDEX IF EXISTS chartevents_149_idx01;
  CREATE INDEX chartevents_149_idx01 ON chartevents_149 (itemid);
  DROP INDEX IF EXISTS chartevents_150_idx01;
  CREATE INDEX chartevents_150_idx01 ON chartevents_150 (itemid);
  DROP INDEX IF EXISTS chartevents_151_idx01;
  CREATE INDEX chartevents_151_idx01 ON chartevents_151 (itemid);
  DROP INDEX IF EXISTS chartevents_152_idx01;
  CREATE INDEX chartevents_152_idx01 ON chartevents_152 (itemid);
  DROP INDEX IF EXISTS chartevents_153_idx01;
  CREATE INDEX chartevents_153_idx01 ON chartevents_153 (itemid);
  DROP INDEX IF EXISTS chartevents_154_idx01;
  CREATE INDEX chartevents_154_idx01 ON chartevents_154 (itemid);
  DROP INDEX IF EXISTS chartevents_155_idx01;
  CREATE INDEX chartevents_155_idx01 ON chartevents_155 (itemid);
  DROP INDEX IF EXISTS chartevents_156_idx01;
  CREATE INDEX chartevents_156_idx01 ON chartevents_156 (itemid);
  DROP INDEX IF EXISTS chartevents_157_idx01;
  CREATE INDEX chartevents_157_idx01 ON chartevents_157 (itemid);
  DROP INDEX IF EXISTS chartevents_158_idx01;
  CREATE INDEX chartevents_158_idx01 ON chartevents_158 (itemid);
  DROP INDEX IF EXISTS chartevents_159_idx01;
  CREATE INDEX chartevents_159_idx01 ON chartevents_159 (itemid);
  DROP INDEX IF EXISTS chartevents_160_idx01;
  CREATE INDEX chartevents_160_idx01 ON chartevents_160 (itemid);
  DROP INDEX IF EXISTS chartevents_161_idx01;
  CREATE INDEX chartevents_161_idx01 ON chartevents_161 (itemid);
  DROP INDEX IF EXISTS chartevents_162_idx01;
  CREATE INDEX chartevents_162_idx01 ON chartevents_162 (itemid);
  DROP INDEX IF EXISTS chartevents_163_idx01;
  CREATE INDEX chartevents_163_idx01 ON chartevents_163 (itemid);
  DROP INDEX IF EXISTS chartevents_164_idx01;
  CREATE INDEX chartevents_164_idx01 ON chartevents_164 (itemid);
  DROP INDEX IF EXISTS chartevents_165_idx01;
  CREATE INDEX chartevents_165_idx01 ON chartevents_165 (itemid);
  DROP INDEX IF EXISTS chartevents_166_idx01;
  CREATE INDEX chartevents_166_idx01 ON chartevents_166 (itemid);
  DROP INDEX IF EXISTS chartevents_167_idx01;
  CREATE INDEX chartevents_167_idx01 ON chartevents_167 (itemid);
  DROP INDEX IF EXISTS chartevents_168_idx01;
  CREATE INDEX chartevents_168_idx01 ON chartevents_168 (itemid);
  DROP INDEX IF EXISTS chartevents_169_idx01;
  CREATE INDEX chartevents_169_idx01 ON chartevents_169 (itemid);
  DROP INDEX IF EXISTS chartevents_170_idx01;
  CREATE INDEX chartevents_170_idx01 ON chartevents_170 (itemid);
  DROP INDEX IF EXISTS chartevents_171_idx01;
  CREATE INDEX chartevents_171_idx01 ON chartevents_171 (itemid);
  DROP INDEX IF EXISTS chartevents_172_idx01;
  CREATE INDEX chartevents_172_idx01 ON chartevents_172 (itemid);
  DROP INDEX IF EXISTS chartevents_173_idx01;
  CREATE INDEX chartevents_173_idx01 ON chartevents_173 (itemid);
  DROP INDEX IF EXISTS chartevents_174_idx01;
  CREATE INDEX chartevents_174_idx01 ON chartevents_174 (itemid);
  DROP INDEX IF EXISTS chartevents_175_idx01;
  CREATE INDEX chartevents_175_idx01 ON chartevents_175 (itemid);
  DROP INDEX IF EXISTS chartevents_176_idx01;
  CREATE INDEX chartevents_176_idx01 ON chartevents_176 (itemid);
  DROP INDEX IF EXISTS chartevents_177_idx01;
  CREATE INDEX chartevents_177_idx01 ON chartevents_177 (itemid);
  DROP INDEX IF EXISTS chartevents_178_idx01;
  CREATE INDEX chartevents_178_idx01 ON chartevents_178 (itemid);
  DROP INDEX IF EXISTS chartevents_179_idx01;
  CREATE INDEX chartevents_179_idx01 ON chartevents_179 (itemid);
  DROP INDEX IF EXISTS chartevents_180_idx01;
  CREATE INDEX chartevents_180_idx01 ON chartevents_180 (itemid);
  DROP INDEX IF EXISTS chartevents_181_idx01;
  CREATE INDEX chartevents_181_idx01 ON chartevents_181 (itemid);
  DROP INDEX IF EXISTS chartevents_182_idx01;
  CREATE INDEX chartevents_182_idx01 ON chartevents_182 (itemid);
  DROP INDEX IF EXISTS chartevents_183_idx01;
  CREATE INDEX chartevents_183_idx01 ON chartevents_183 (itemid);
  DROP INDEX IF EXISTS chartevents_184_idx01;
  CREATE INDEX chartevents_184_idx01 ON chartevents_184 (itemid);
  DROP INDEX IF EXISTS chartevents_185_idx01;
  CREATE INDEX chartevents_185_idx01 ON chartevents_185 (itemid);
  DROP INDEX IF EXISTS chartevents_186_idx01;
  CREATE INDEX chartevents_186_idx01 ON chartevents_186 (itemid);
  DROP INDEX IF EXISTS chartevents_187_idx01;
  CREATE INDEX chartevents_187_idx01 ON chartevents_187 (itemid);
  DROP INDEX IF EXISTS chartevents_188_idx01;
  CREATE INDEX chartevents_188_idx01 ON chartevents_188 (itemid);
  DROP INDEX IF EXISTS chartevents_189_idx01;
  CREATE INDEX chartevents_189_idx01 ON chartevents_189 (itemid);
  DROP INDEX IF EXISTS chartevents_190_idx01;
  CREATE INDEX chartevents_190_idx01 ON chartevents_190 (itemid);
  DROP INDEX IF EXISTS chartevents_191_idx01;
  CREATE INDEX chartevents_191_idx01 ON chartevents_191 (itemid);
  DROP INDEX IF EXISTS chartevents_192_idx01;
  CREATE INDEX chartevents_192_idx01 ON chartevents_192 (itemid);
  DROP INDEX IF EXISTS chartevents_193_idx01;
  CREATE INDEX chartevents_193_idx01 ON chartevents_193 (itemid);
  DROP INDEX IF EXISTS chartevents_194_idx01;
  CREATE INDEX chartevents_194_idx01 ON chartevents_194 (itemid);
  DROP INDEX IF EXISTS chartevents_195_idx01;
  CREATE INDEX chartevents_195_idx01 ON chartevents_195 (itemid);
  DROP INDEX IF EXISTS chartevents_196_idx01;
  CREATE INDEX chartevents_196_idx01 ON chartevents_196 (itemid);
  DROP INDEX IF EXISTS chartevents_197_idx01;
  CREATE INDEX chartevents_197_idx01 ON chartevents_197 (itemid);
  DROP INDEX IF EXISTS chartevents_198_idx01;
  CREATE INDEX chartevents_198_idx01 ON chartevents_198 (itemid);
  DROP INDEX IF EXISTS chartevents_199_idx01;
  CREATE INDEX chartevents_199_idx01 ON chartevents_199 (itemid);
  DROP INDEX IF EXISTS chartevents_200_idx01;
  CREATE INDEX chartevents_200_idx01 ON chartevents_200 (itemid);
  DROP INDEX IF EXISTS chartevents_201_idx01;
  CREATE INDEX chartevents_201_idx01 ON chartevents_201 (itemid);
  DROP INDEX IF EXISTS chartevents_202_idx01;
  CREATE INDEX chartevents_202_idx01 ON chartevents_202 (itemid);
  DROP INDEX IF EXISTS chartevents_203_idx01;
  CREATE INDEX chartevents_203_idx01 ON chartevents_203 (itemid);
  DROP INDEX IF EXISTS chartevents_204_idx01;
  CREATE INDEX chartevents_204_idx01 ON chartevents_204 (itemid);
  DROP INDEX IF EXISTS chartevents_205_idx01;
  CREATE INDEX chartevents_205_idx01 ON chartevents_205 (itemid);
  DROP INDEX IF EXISTS chartevents_206_idx01;
  CREATE INDEX chartevents_206_idx01 ON chartevents_206 (itemid);
  DROP INDEX IF EXISTS chartevents_207_idx01;
  CREATE INDEX chartevents_207_idx01 ON chartevents_207 (itemid);
END IF;

END$$;
---------------
-- CPTEVENTS
---------------

DROP INDEX IF EXISTS CPTEVENTS_idx01;
CREATE INDEX CPTEVENTS_idx01
  ON CPTEVENTS (SUBJECT_ID);

DROP INDEX IF EXISTS CPTEVENTS_idx02;
CREATE INDEX CPTEVENTS_idx02
  ON CPTEVENTS (CPT_CD);

-----------
-- D_CPT
-----------

-- Table is 134 rows - doesn't need an index.

--------------------
-- D_ICD_DIAGNOSES
--------------------

DROP INDEX IF EXISTS D_ICD_DIAG_idx01;
CREATE INDEX D_ICD_DIAG_idx01
  ON D_ICD_DIAGNOSES (ICD9_CODE);

DROP INDEX IF EXISTS D_ICD_DIAG_idx02;
CREATE INDEX D_ICD_DIAG_idx02
  ON D_ICD_DIAGNOSES (LONG_TITLE);

--------------------
-- D_ICD_PROCEDURES
--------------------

DROP INDEX IF EXISTS D_ICD_PROC_idx01;
CREATE INDEX D_ICD_PROC_idx01
  ON D_ICD_PROCEDURES (ICD9_CODE);

DROP INDEX IF EXISTS D_ICD_PROC_idx02;
CREATE INDEX D_ICD_PROC_idx02
  ON D_ICD_PROCEDURES (LONG_TITLE);

-----------
-- D_ITEMS
-----------

DROP INDEX IF EXISTS D_ITEMS_idx01;
CREATE INDEX D_ITEMS_idx01
  ON D_ITEMS (ITEMID);

DROP INDEX IF EXISTS D_ITEMS_idx02;
CREATE INDEX D_ITEMS_idx02
  ON D_ITEMS (LABEL);

-- DROP INDEX IF EXISTS D_ITEMS_idx03;
-- CREATE INDEX D_ITEMS_idx03
--   ON D_ITEMS (CATEGORY);

---------------
-- D_LABITEMS
---------------

DROP INDEX IF EXISTS D_LABITEMS_idx01;
CREATE INDEX D_LABITEMS_idx01
  ON D_LABITEMS (ITEMID);

DROP INDEX IF EXISTS D_LABITEMS_idx02;
CREATE INDEX D_LABITEMS_idx02
  ON D_LABITEMS (LABEL);

DROP INDEX IF EXISTS D_LABITEMS_idx03;
CREATE INDEX D_LABITEMS_idx03
  ON D_LABITEMS (LOINC_CODE);

-------------------
-- DATETIMEEVENTS
-------------------

DROP INDEX IF EXISTS DATETIMEEVENTS_idx01;
CREATE INDEX DATETIMEEVENTS_idx01
  ON DATETIMEEVENTS (SUBJECT_ID);

DROP INDEX IF EXISTS DATETIMEEVENTS_idx02;
CREATE INDEX DATETIMEEVENTS_idx02
  ON DATETIMEEVENTS (ITEMID);

DROP INDEX IF EXISTS DATETIMEEVENTS_idx03;
CREATE INDEX DATETIMEEVENTS_idx03
  ON DATETIMEEVENTS (ICUSTAY_ID);

DROP INDEX IF EXISTS DATETIMEEVENTS_idx04;
CREATE INDEX DATETIMEEVENTS_idx04
  ON DATETIMEEVENTS (HADM_ID);

-- DROP INDEX IF EXISTS DATETIMEEVENTS_idx05;
-- CREATE INDEX DATETIMEEVENTS_idx05
--   ON DATETIMEEVENTS (VALUE);

------------------
-- DIAGNOSES_ICD
------------------

DROP INDEX IF EXISTS DIAGNOSES_ICD_idx01;
CREATE INDEX DIAGNOSES_ICD_idx01
  ON DIAGNOSES_ICD (SUBJECT_ID);

DROP INDEX IF EXISTS DIAGNOSES_ICD_idx02;
CREATE INDEX DIAGNOSES_ICD_idx02
  ON DIAGNOSES_ICD (ICD9_CODE);

DROP INDEX IF EXISTS DIAGNOSES_ICD_idx03;
CREATE INDEX DIAGNOSES_ICD_idx03
  ON DIAGNOSES_ICD (HADM_ID);

--------------
-- DRGCODES
--------------

DROP INDEX IF EXISTS DRGCODES_idx01;
CREATE INDEX DRGCODES_idx01
  ON DRGCODES (SUBJECT_ID);

DROP INDEX IF EXISTS DRGCODES_idx02;
CREATE INDEX DRGCODES_idx02
  ON DRGCODES (DRG_CODE);

DROP INDEX IF EXISTS DRGCODES_idx03;
CREATE INDEX DRGCODES_idx03
  ON DRGCODES (DESCRIPTION);

-- HADM_ID

------------------
-- ICUSTAYS
------------------

DROP INDEX IF EXISTS ICUSTAYS_idx01;
CREATE INDEX ICUSTAYS_idx01
  ON ICUSTAYS (SUBJECT_ID);

DROP INDEX IF EXISTS ICUSTAYS_idx02;
CREATE INDEX ICUSTAYS_idx02
  ON ICUSTAYS (ICUSTAY_ID);

-- DROP INDEX IF EXISTS ICUSTAYS_idx03;
-- CREATE INDEX ICUSTAYS_idx03
--   ON ICUSTAYS (LOS);

-- DROP INDEX IF EXISTS ICUSTAYS_idx04;
-- CREATE INDEX ICUSTAYS_idx04
--   ON ICUSTAYS (FIRST_CAREUNIT);

-- DROP INDEX IF EXISTS ICUSTAYS_idx05;
-- CREATE INDEX ICUSTAYS_idx05
--   ON ICUSTAYS (LAST_CAREUNIT);

DROP INDEX IF EXISTS ICUSTAYS_idx06;
CREATE INDEX ICUSTAYS_IDX06
  ON ICUSTAYS (HADM_ID);

-------------
-- INPUTEVENTS_CV
-------------

DROP INDEX IF EXISTS INPUTEVENTS_CV_idx01;
CREATE INDEX INPUTEVENTS_CV_idx01
  ON INPUTEVENTS_CV (SUBJECT_ID);

  DROP INDEX IF EXISTS INPUTEVENTS_CV_idx02;
  CREATE INDEX INPUTEVENTS_CV_idx02
    ON INPUTEVENTS_CV (HADM_ID);

DROP INDEX IF EXISTS INPUTEVENTS_CV_idx03;
CREATE INDEX INPUTEVENTS_CV_idx03
  ON INPUTEVENTS_CV (ICUSTAY_ID);

DROP INDEX IF EXISTS INPUTEVENTS_CV_idx04;
CREATE INDEX INPUTEVENTS_CV_idx04
  ON INPUTEVENTS_CV (CHARTTIME);

DROP INDEX IF EXISTS INPUTEVENTS_CV_idx05;
CREATE INDEX INPUTEVENTS_CV_idx05
  ON INPUTEVENTS_CV (ITEMID);

-- DROP INDEX IF EXISTS INPUTEVENTS_CV_idx06;
-- CREATE INDEX INPUTEVENTS_CV_idx06
--   ON INPUTEVENTS_CV (RATE);

-- DROP INDEX IF EXISTS INPUTEVENTS_CV_idx07;
-- CREATE INDEX INPUTEVENTS_CV_idx07
--   ON INPUTEVENTS_CV (AMOUNT);

-- DROP INDEX IF EXISTS INPUTEVENTS_CV_idx08;
-- CREATE INDEX INPUTEVENTS_CV_idx08
--   ON INPUTEVENTS_CV (CGID);

-- DROP INDEX IF EXISTS INPUTEVENTS_CV_idx09;
-- CREATE INDEX INPUTEVENTS_CV_idx09
--   ON INPUTEVENTS_CV (LINKORDERID, ORDERID);

-------------
-- INPUTEVENTS_MV
-------------

DROP INDEX IF EXISTS INPUTEVENTS_MV_idx01;
CREATE INDEX INPUTEVENTS_MV_idx01
  ON INPUTEVENTS_MV (SUBJECT_ID);

DROP INDEX IF EXISTS INPUTEVENTS_MV_idx02;
CREATE INDEX INPUTEVENTS_MV_idx02
  ON INPUTEVENTS_MV (HADM_ID);

DROP INDEX IF EXISTS INPUTEVENTS_MV_idx03;
CREATE INDEX INPUTEVENTS_MV_idx03
  ON INPUTEVENTS_MV (ICUSTAY_ID);

-- DROP INDEX IF EXISTS INPUTEVENTS_MV_idx04;
-- CREATE INDEX INPUTEVENTS_MV_idx04
--   ON INPUTEVENTS_MV (ENDTIME, STARTTIME);

DROP INDEX IF EXISTS INPUTEVENTS_MV_idx05;
CREATE INDEX INPUTEVENTS_MV_idx05
  ON INPUTEVENTS_MV (ITEMID);

-- DROP INDEX IF EXISTS INPUTEVENTS_MV_idx06;
-- CREATE INDEX INPUTEVENTS_MV_idx06
--   ON INPUTEVENTS_MV (RATE);

-- DROP INDEX IF EXISTS INPUTEVENTS_MV_idx07;
-- CREATE INDEX INPUTEVENTS_MV_idx07
--   ON INPUTEVENTS_MV (VOLUME);

-- DROP INDEX IF EXISTS INPUTEVENTS_MV_idx08;
-- CREATE INDEX INPUTEVENTS_MV_idx08
--   ON INPUTEVENTS_MV (CGID);

-- DROP INDEX IF EXISTS INPUTEVENTS_MV_idx09;
-- CREATE INDEX INPUTEVENTS_MV_idx09
--   ON INPUTEVENTS_MV (LINKORDERID, ORDERID);

-- DROP INDEX IF EXISTS INPUTEVENTS_MV_idx10;
-- CREATE INDEX INPUTEVENTS_MV_idx10
--   ON INPUTEVENTS_MV (ORDERCATEGORYDESCRIPTION,
--     ORDERCATEGORYNAME, SECONDARYORDERCATEGORYNAME);

-- DROP INDEX IF EXISTS INPUTEVENTS_MV_idx11;
-- CREATE INDEX INPUTEVENTS_MV_idx11
--   ON INPUTEVENTS_MV (ORDERCOMPONENTTYPEDESCRIPTION,
--     ORDERCATEGORYDESCRIPTION);


--------------
-- LABEVENTS
--------------

DROP INDEX IF EXISTS LABEVENTS_idx01;
CREATE INDEX LABEVENTS_idx01
  ON LABEVENTS (SUBJECT_ID);

DROP INDEX IF EXISTS LABEVENTS_idx02;
CREATE INDEX LABEVENTS_idx02
  ON LABEVENTS (HADM_ID);

DROP INDEX IF EXISTS LABEVENTS_idx03;
CREATE INDEX LABEVENTS_idx03
  ON LABEVENTS (ITEMID);

-- DROP INDEX IF EXISTS LABEVENTS_idx04;
-- CREATE INDEX LABEVENTS_idx04
--   ON LABEVENTS (VALUE, VALUENUM);

----------------------
-- MICROBIOLOGYEVENTS
----------------------

DROP INDEX IF EXISTS MICROBIOLOGYEVENTS_idx01;
CREATE INDEX MICROBIOLOGYEVENTS_idx01
  ON MICROBIOLOGYEVENTS (SUBJECT_ID);

DROP INDEX IF EXISTS MICROBIOLOGYEVENTS_idx02;
CREATE INDEX MICROBIOLOGYEVENTS_idx02
  ON MICROBIOLOGYEVENTS (HADM_ID);

-- DROP INDEX IF EXISTS MICROBIOLOGYEVENTS_idx03;
-- CREATE INDEX MICROBIOLOGYEVENTS_idx03
--   ON MICROBIOLOGYEVENTS (SPEC_ITEMID,
--     ORG_ITEMID, AB_ITEMID);

---------------
-- NOTEEVENTS
---------------

DROP INDEX IF EXISTS NOTEEVENTS_idx01;
CREATE INDEX NOTEEVENTS_idx01
  ON NOTEEVENTS (SUBJECT_ID);

DROP INDEX IF EXISTS NOTEEVENTS_idx02;
CREATE INDEX NOTEEVENTS_idx02
  ON NOTEEVENTS (HADM_ID);

-- DROP INDEX IF EXISTS NOTEEVENTS_idx03;
-- CREATE INDEX NOTEEVENTS_idx03
--   ON NOTEEVENTS (CGID);

-- DROP INDEX IF EXISTS NOTEEVENTS_idx04;
-- CREATE INDEX NOTEEVENTS_idx04
--   ON NOTEEVENTS (RECORD_ID);

DROP INDEX IF EXISTS NOTEEVENTS_idx05;
CREATE INDEX NOTEEVENTS_idx05
  ON NOTEEVENTS (CATEGORY);


---------------
-- OUTPUTEVENTS
---------------
DROP INDEX IF EXISTS OUTPUTEVENTS_idx01;
CREATE INDEX OUTPUTEVENTS_idx01
  ON OUTPUTEVENTS (SUBJECT_ID);


DROP INDEX IF EXISTS OUTPUTEVENTS_idx02;
CREATE INDEX OUTPUTEVENTS_idx02
  ON OUTPUTEVENTS (ITEMID);


DROP INDEX IF EXISTS OUTPUTEVENTS_idx03;
CREATE INDEX OUTPUTEVENTS_idx03
  ON OUTPUTEVENTS (ICUSTAY_ID);


DROP INDEX IF EXISTS OUTPUTEVENTS_idx04;
CREATE INDEX OUTPUTEVENTS_idx04
  ON OUTPUTEVENTS (HADM_ID);

-- Perhaps not useful to index on just value? Index just for popular subset?
-- DROP INDEX IF EXISTS OUTPUTEVENTS_idx05;
-- CREATE INDEX OUTPUTEVENTS_idx05
--   ON OUTPUTEVENTS (VALUE);


-------------
-- PATIENTS
-------------

-- Note that SUBJECT_ID is already indexed as it is unique

-- DROP INDEX IF EXISTS PATIENTS_idx01;
-- CREATE INDEX PATIENTS_idx01
--   ON PATIENTS (EXPIRE_FLAG);


------------------
-- PRESCRIPTIONS
------------------

DROP INDEX IF EXISTS PRESCRIPTIONS_idx01;
CREATE INDEX PRESCRIPTIONS_idx01
  ON PRESCRIPTIONS (SUBJECT_ID);

DROP INDEX IF EXISTS PRESCRIPTIONS_idx02;
CREATE INDEX PRESCRIPTIONS_idx02
  ON PRESCRIPTIONS (ICUSTAY_ID);

DROP INDEX IF EXISTS PRESCRIPTIONS_idx03;
CREATE INDEX PRESCRIPTIONS_idx03
  ON PRESCRIPTIONS (DRUG_TYPE);

DROP INDEX IF EXISTS PRESCRIPTIONS_idx04;
CREATE INDEX PRESCRIPTIONS_idx04
  ON PRESCRIPTIONS (DRUG);

DROP INDEX IF EXISTS PRESCRIPTIONS_idx05;
CREATE INDEX PRESCRIPTIONS_idx05
  ON PRESCRIPTIONS (HADM_ID);


---------------------
-- PROCEDUREEVENTS_MV
---------------------

DROP INDEX IF EXISTS PROCEDUREEVENTS_MV_idx01;
CREATE INDEX PROCEDUREEVENTS_MV_idx01
  ON PROCEDUREEVENTS_MV (SUBJECT_ID);

DROP INDEX IF EXISTS PROCEDUREEVENTS_MV_idx02;
CREATE INDEX PROCEDUREEVENTS_MV_idx02
  ON PROCEDUREEVENTS_MV (HADM_ID);

DROP INDEX IF EXISTS PROCEDUREEVENTS_MV_idx03;
CREATE INDEX PROCEDUREEVENTS_MV_idx03
  ON PROCEDUREEVENTS_MV (ICUSTAY_ID);

-- DROP INDEX IF EXISTS PROCEDUREEVENTS_MV_idx04;
-- CREATE INDEX PROCEDUREEVENTS_MV_idx04
--   ON PROCEDUREEVENTS_MV (ENDTIME, STARTTIME);

DROP INDEX IF EXISTS PROCEDUREEVENTS_MV_idx05;
CREATE INDEX PROCEDUREEVENTS_MV_idx05
  ON PROCEDUREEVENTS_MV (ITEMID);

-- DROP INDEX IF EXISTS PROCEDUREEVENTS_MV_idx06;
-- CREATE INDEX PROCEDUREEVENTS_MV_idx06
--   ON PROCEDUREEVENTS_MV (VALUE);

-- DROP INDEX IF EXISTS PROCEDUREEVENTS_MV_idx07;
-- CREATE INDEX PROCEDUREEVENTS_MV_idx07
--   ON PROCEDUREEVENTS_MV (CGID);

-- DROP INDEX IF EXISTS PROCEDUREEVENTS_MV_idx08;
-- CREATE INDEX PROCEDUREEVENTS_MV_idx08
--   ON PROCEDUREEVENTS_MV (LINKORDERID, ORDERID);

-- DROP INDEX IF EXISTS PROCEDUREEVENTS_MV_idx09;
-- CREATE INDEX PROCEDUREEVENTS_MV_idx09
--   ON PROCEDUREEVENTS_MV (ORDERCATEGORYDESCRIPTION,
--     ORDERCATEGORYNAME, SECONDARYORDERCATEGORYNAME);

-------------------
-- PROCEDURES_ICD
-------------------

DROP INDEX IF EXISTS PROCEDURES_ICD_idx01;
CREATE INDEX PROCEDURES_ICD_idx01
  ON PROCEDURES_ICD (SUBJECT_ID);

DROP INDEX IF EXISTS PROCEDURES_ICD_idx02;
CREATE INDEX PROCEDURES_ICD_idx02
  ON PROCEDURES_ICD (ICD9_CODE);

DROP INDEX IF EXISTS PROCEDURES_ICD_idx03;
CREATE INDEX PROCEDURES_ICD_idx03
  ON PROCEDURES_ICD (HADM_ID);


-------------
-- SERVICES
-------------

DROP INDEX IF EXISTS SERVICES_idx01;
CREATE INDEX SERVICES_idx01
  ON SERVICES (SUBJECT_ID);

DROP INDEX IF EXISTS SERVICES_idx02;
CREATE INDEX SERVICES_idx02
  ON SERVICES (HADM_ID);

-- DROP INDEX IF EXISTS SERVICES_idx03;
-- CREATE INDEX SERVICES_idx03
--   ON SERVICES (CURR_SERVICE, PREV_SERVICE);

-------------
-- TRANSFERS
-------------

DROP INDEX IF EXISTS TRANSFERS_idx01;
CREATE INDEX TRANSFERS_idx01
  ON TRANSFERS (SUBJECT_ID);

DROP INDEX IF EXISTS TRANSFERS_idx02;
CREATE INDEX TRANSFERS_idx02
  ON TRANSFERS (ICUSTAY_ID);

DROP INDEX IF EXISTS TRANSFERS_idx03;
CREATE INDEX TRANSFERS_idx03
  ON TRANSFERS (HADM_ID);

-- DROP INDEX IF EXISTS TRANSFERS_idx04;
-- CREATE INDEX TRANSFERS_idx04
--   ON TRANSFERS (INTIME, OUTTIME);

-- DROP INDEX IF EXISTS TRANSFERS_idx05;
-- CREATE INDEX TRANSFERS_idx05
--   ON TRANSFERS (LOS);
