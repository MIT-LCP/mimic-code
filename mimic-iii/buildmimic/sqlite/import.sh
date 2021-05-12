#!/bin/sh

# Copyright (c) 2021 Thomas Ward <thomas@thomasward.com>
# 
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

OUTFILE=mimic3.db

if [ -s "$OUTFILE" ]; then
    echo "File \"$OUTFILE\" already exists." >&2
    exit 111
fi

for FILE in *; do
    # skip loop if glob didn't match an actual file
    [ -f "$FILE" ] || continue
    # trim off extension and lowercase file stem (e.g., HELLO.csv -> hello)
    TABLE_NAME=$(echo "${FILE%%.*}" | tr "[:upper:]" "[:lower:]")
    case "$FILE" in
        *csv)
            IMPORT_CMD=".import $FILE $TABLE_NAME"
        ;;
        # need to decompress csv before load
        *csv.gz)
            IMPORT_CMD=".import \"|gzip -dc $FILE\" $TABLE_NAME"
        ;;
        # not a data file so skip
        *)
            continue
        ;;
    esac
    echo "Loading $FILE."
    sqlite3 $OUTFILE <<EOF
.headers on
.mode csv
$IMPORT_CMD
EOF
    echo "Finished loading $FILE."
done

echo "Finished loading data into $OUTFILE."
