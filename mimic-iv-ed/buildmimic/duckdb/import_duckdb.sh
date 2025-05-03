#!/bin/sh

# Copyright (c) 2023 MIT Laboratory for Computational Physiology
# Copyright (c) 2021 Thomas Ward <thomas@thomasward.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

yell () { echo "$0: $*" >&2; }
die () { yell "$*"; exit 111; }
try () { "$@" || die "Exiting. Failed to run: \"$*\""; }

usage () {
    die "
USAGE: ./import_duckdb.sh mimic_data_dir [output_db]
WHERE:
    mimic_data_dir        directory that contains csv.tar.gz or csv files
    output_db: optional   filename for duckdb file (default: mimic4_ed.db)\
"
}

# Print help if requested
echo "$0 $* " | grep -Eq " -h | --help " && usage

# rename CLI positional args to more friendly variable names
MIMIC_DIR=$1
# allow optional specification of duckdb name, otherwise default to mimic4_ed.db
OUTFILE=mimic4_ed.db
if [ -n "$2" ]; then
    OUTFILE=$2
fi


# basic error checking before running
if [ -z "$MIMIC_DIR" ]; then
    yell "Please specify a mimic data directory"
    die "Usage: ./import_duckdb.sh mimic_data_dir [output_db]"
elif [ ! -d "$MIMIC_DIR" ]; then
    yell "Specified directory \"$MIMIC_DIR\" does not exist."
    die "Usage: ./import_duckdb.sh mimic_data_dir [output_db]"
elif [ -n "$3" ]; then
    yell "import.sh takes a maximum of two arguments."
    die "Usage: ./import_duckdb.sh mimic_data_dir [output_db]"
elif [ -s "$OUTFILE" ]; then
  yell "File \"$OUTFILE\" already exists."
  read -p "Continue? (y/d/n) 'y' continues, 'd' deletes original file, 'n' stops: " yn
  case $yn in
      [Yy]* ) ;; # OK
      [Nn]* ) exit;;
      [Dd]* ) rm "$OUTFILE";;
      * ) die "Unrecognized input.";;
  esac
fi

# we will copy the postgresql create.sql file, and apply regex
# to fix the following issues:
# 1. Remove optional precision value from TIMESTAMP(NN) -> TIMESTAMP
#    duckdb does not support this.
export REGEX_TIMESTAMP='s/TIMESTAMP\([0-9]+\)/TIMESTAMP/g'
# 2. Remove NOT NULL constraint from mimiciv_hosp.microbiologyevents.spec_type_desc
#    as there is one (!) zero-length string which is treated as a NULL by the import.
export REGEX_SPEC_TYPE='s/spec_type_desc(.+)NOT NULL/spec_type_desc\1/g'
# 3. Remove NOT NULL constraint from mimiciv_hosp.prescriptions.drug
#    as there are zero-length strings which are treated as NULLs by the import.
export REGEX_DRUG='s/drug +(VARCHAR.+)NOT NULL/drug \1/g'

# use sed + above regex to create tables within db
sed -r -e "${REGEX_TIMESTAMP}" ../postgres/create.sql | \
  sed -r -e "${REGEX_SPEC_TYPE}" | \
  sed -r -e "${REGEX_DRUG}" | \
  duckdb "$OUTFILE"

# goal: get path from find, e.g., ./1.0/icu/d_items
# and return database table name for it, e.g., mimiciv_icu.d_items
make_table_name () {
    # strip leading directories (e.g., ./icu/hello.csv.gz -> hello.csv.gz)
    BASENAME=${1##*/}
    # strip suffix (e.g., hello.csv.gz -> hello; hello.csv -> hello)
    TABLE_NAME=${BASENAME%%.*}
    # strip basename (e.g., ./icu/hello.csv.gz -> ./icu)
    PATHNAME=${1%/*}
    # strip leading directories from PATHNAME (e.g. ./icu -> icu)
    DIRNAME=${PATHNAME##*/}
    TABLE_NAME="mimiciv_$DIRNAME.$TABLE_NAME"
}


# load data into database
find "$MIMIC_DIR" -type f -name '*.csv???' | sort | while IFS= read -r FILE; do
    make_table_name "$FILE"

    # skip directories which we do not expect in mimic-iv-ed
    # avoids syntax errors if mimic-iv in the same dir
    case $DIRNAME in
      (ed) ;; # OK
      (*) continue;
    esac
    echo "Loading $FILE .. \c"
    try duckdb "$OUTFILE" <<-EOSQL
		COPY $TABLE_NAME FROM '$FILE' (HEADER);
EOSQL
    echo "done!"
done && echo "Successfully finished loading data into $OUTFILE."
