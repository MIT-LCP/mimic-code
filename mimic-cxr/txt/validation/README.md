# Validation of CheXpert/NegBio

This folder provides the code used to validate the performance of CheXpert and NegBio.
The code compares CheXpert/NegBio outputs to a gold standard corpus annotated by two board certified radiologists.

## Prepare validation file

Symlink to the other repository storing the text.

```bash
ln -s /db/rr-labeled/mimic_cxr_labeled_mpl.csv mimic_cxr_validation_reports.csv
```

## Run CheXpert

```bash
conda activate chexpert-mimic-cxr
export CHEXPERT_PATH=/home/alistairewj/git/chexpert-labeler

python $CHEXPERT_PATH/label.py --verbose --reports_path mimic_cxr_validation_reports.csv --output_path mimic_cxr_validation_chexpert_labeled.csv --mention_phrases_dir $CHEXPERT_PATH/phrases/mention --unmention_phrases_dir $CHEXPERT_PATH/phrases/unmention --pre_negation_uncertainty_path $CHEXPERT_PATH/patterns/pre_negation_uncertainty.txt --negation_path $CHEXPERT_PATH/patterns/negation.txt --post_negation_uncertainty_path $CHEXPERT_PATH/patterns/post_negation_uncertainty.txt
```

## Run NegBio

```bash
conda activate negbio-mimic-cxr

# need to add NegBio repository location to python path
export NEGBIO_PATH=/home/alistairewj/git/negbio-mimic-cxr
export PYTHONPATH=$NEGBIO_PATH:$PYTHONPATH

# source CSV
export INPUT_FILE=mimic_cxr_validation_reports.csv

# intermediate results are saved to a folder
export OUTPUT_DIR=mimic_cxr_validation_reports
# ultimate filename we save the labels to
export OUTPUT_LABELS=mimic_cxr_validation_negbio_labeled.csv

python $NEGBIO_PATH/negbio/negbio_csv2bioc.py --output $OUTPUT_DIR/report $INPUT_FILE
python $NEGBIO_PATH/negbio/negbio_pipeline.py section_split --pattern $NEGBIO_PATH/patterns/section_titles_cxr8.txt --output $OUTPUT_DIR/sections $OUTPUT_DIR/report/* --workers=6
python $NEGBIO_PATH/negbio/negbio_pipeline.py ssplit --output $OUTPUT_DIR/ssplit $OUTPUT_DIR/sections/* --workers=6
python $NEGBIO_PATH/negbio/negbio_pipeline.py parse --output $OUTPUT_DIR/parse $OUTPUT_DIR/ssplit/* --workers=6
python $NEGBIO_PATH/negbio/negbio_pipeline.py ptb2ud --output $OUTPUT_DIR/ud $OUTPUT_DIR/parse/* --workers=6
python $NEGBIO_PATH/negbio/negbio_pipeline.py dner_regex --phrases_file $NEGBIO_PATH/patterns/chexpert_phrases.yml --output $OUTPUT_DIR/dner $OUTPUT_DIR/ud/* --suffix=.chexpert-regex.xml --workers=6 --overwrite
python $NEGBIO_PATH/negbio/negbio_pipeline.py neg2 --output $OUTPUT_DIR/neg --pre-negation-uncertainty-patterns $NEGBIO_PATH/patterns/chexpert_pre_negation_uncertainty.yml --neg-patterns $NEGBIO_PATH/patterns/neg_patterns2.yml --post-negation-uncertainty-patterns $NEGBIO_PATH/patterns/post_negation_uncertainty.yml --neg-regex-patterns $NEGBIO_PATH/patterns/neg_regex_patterns.yml --uncertainty-regex-patterns $NEGBIO_PATH/patterns/uncertainty_regex_patterns.yml $OUTPUT_DIR/dner/* --workers=6

# aggregate labels and output final CSV
python $NEGBIO_PATH/negbio/ext/chexpert_collect_labels.py --phrases_file $NEGBIO_PATH/patterns/chexpert_phrases.yml --output $OUTPUT_LABELS $OUTPUT_DIR/neg/*
```

## Compare

See [compare_negbio_and_chexpert.ipynb](compare_negbio_and_chexpert.ipynb).