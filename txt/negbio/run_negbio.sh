#!/usr/bin/env bash
# output to a log file rather than stdout
#!/bin/sh

# exec >> negbio_log_file
# exec 2>&1

BASE_FOLDER=$1
NEGBIO_PATH=$2

if [ -z "$BASE_FOLDER" ]
then
    echo "You must call this script as: ./run_negbio.sh FOLDER_WITH_DATA_CSVS NEGBIO_GIT_PATH"
    exit 1
else
    echo "Source of data: $BASE_FOLDER"
fi

if [ -z "$NEGBIO_PATH" ]
then
    echo "You must call this script as: ./run_negbio.sh FOLDER_WITH_DATA_CSVS NEGBIO_GIT_PATH"
    exit 1
else
    echo "Location of NegBio (MIMIC-CXR branch): $NEGBIO_PATH"
fi

export PYTHONPATH=$NEGBIO_PATH:$PYTHONPATH
sleep 2

# get a list of mimic cxr files
# BASE_FOLDER should have:
#  mimic_cxr_001.csv
#  mimic_cxr_002.csv
# .. etc
for fn in `ls $BASE_FOLDER`;
do
  echo "Looping through files with mimic_cxr_###.csv pattern."
  # validate it's a mimic_cxr sections file
  if [[ $fn =~ ^mimic_cxr_[0-9]+.csv$ ]];
  then
    export INPUT_FILE=${BASE_FOLDER}/$fn
    # remove extension from filename
    # sets the folder location to stem of original filename
    # all intermediate files will be saved in this folder
    export OUTPUT_DIR=${INPUT_FILE::-4}

    echo $OUTPUT_DIR - running NegBio..
    python $NEGBIO_PATH/negbio/negbio_csv2bioc.py --output $OUTPUT_DIR/report $INPUT_FILE
    python $NEGBIO_PATH/negbio/negbio_pipeline.py section_split --pattern $NEGBIO_PATH/patterns/section_titles_cxr8.txt --output $OUTPUT_DIR/sections $OUTPUT_DIR/report/* --workers=6
    python $NEGBIO_PATH/negbio/negbio_pipeline.py ssplit --output $OUTPUT_DIR/ssplit $OUTPUT_DIR/sections/* --workers=6
    python $NEGBIO_PATH/negbio/negbio_pipeline.py parse --output $OUTPUT_DIR/parse $OUTPUT_DIR/ssplit/* --workers=6
    python $NEGBIO_PATH/negbio/negbio_pipeline.py ptb2ud --output $OUTPUT_DIR/ud $OUTPUT_DIR/parse/* --workers=6
    python $NEGBIO_PATH/negbio/negbio_pipeline.py dner_regex --phrases_file $NEGBIO_PATH/patterns/chexpert_phrases.yml --output $OUTPUT_DIR/dner $OUTPUT_DIR/ud/* --suffix=.chexpert-regex.xml --workers=6 --overwrite
    python $NEGBIO_PATH/negbio/negbio_pipeline.py neg2 --output $OUTPUT_DIR/neg --pre-negation-uncertainty-patterns $NEGBIO_PATH/patterns/chexpert_pre_negation_uncertainty.yml --neg-patterns $NEGBIO_PATH/patterns/neg_patterns2.yml --post-negation-uncertainty-patterns $NEGBIO_PATH/patterns/post_negation_uncertainty.yml --neg-regex-patterns $NEGBIO_PATH/patterns/neg_regex_patterns.yml --uncertainty-regex-patterns $NEGBIO_PATH/patterns/uncertainty_regex_patterns.yml $OUTPUT_DIR/dner/* --workers=6

    # ultimate filename we save the labels to
    export OUTPUT_LABELS=$OUTPUT_DIR/${fn::-4}_labels.csv
    python $NEGBIO_PATH/negbio/ext/chexpert_collect_labels.py --phrases_file $NEGBIO_PATH/patterns/chexpert_phrases.yml --output $OUTPUT_LABELS $OUTPUT_DIR/neg/*
  fi
done
echo "Done looping through files."
