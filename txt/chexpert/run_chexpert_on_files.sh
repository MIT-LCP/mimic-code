#!/bin/sh
# simple script to call chexpert labeler on many files

REPORT_PATH=$1
CHEXPERT_PATH=$2

if [ -z "$REPORT_PATH" ]
then
    echo "You must call this script as: ./run_chexpert_on_files.sh FOLDER_WITH_DATA_CSVS CHEXPERT_GIT_PATH"
    exit 1
else
    echo "Source of data: $REPORT_PATH"
fi

if [ -z "$CHEXPERT_PATH" ]
then
    echo "You must call this script as: ./run_chexpert_on_files.sh FOLDER_WITH_DATA_CSVS CHEXPERT_GIT_PATH"
    exit 1
else
    echo "Location of CheXpert code: $CHEXPERT_PATH"
fi
sleep 2

# loop through each .csv file in the section folder
for fn in `ls $REPORT_PATH`; do
    echo `date`: $fn
    fn_stem=`echo $fn | cut -d. -f 1`
    # run chexpert - must be run from chexpert folder
    python $CHEXPERT_PATH/label.py  --verbose --reports_path $REPORT_PATH/$fn --output_path ${fn_stem}_labeled.csv --mention_phrases_dir $CHEXPERT_PATH/phrases/mention --unmention_phrases_dir $CHEXPERT_PATH/phrases/unmention --pre_negation_uncertainty_path $CHEXPERT_PATH/patterns/pre_negation_uncertainty.txt --negation_path $CHEXPERT_PATH/patterns/negation.txt --post_negation_uncertainty_path $CHEXPERT_PATH/patterns/post_negation_uncertainty.txt
    echo `date`: done!
    echo ''
done