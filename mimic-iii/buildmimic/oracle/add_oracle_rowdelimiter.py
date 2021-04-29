from __future__ import print_function

import sys
import getopt
import os.path

import csv

# This function takes a CSV file and appends a string to the end of each row
# This facilitates using the CSV with programs which can't handle newlines in fields
# For example, Oracle's SQLLDR requires a unique string at the end of each row to indicate the row delimiter.

# FUNCTION ASSUMPTIONS:
#   1) file is in proper CSV format, where "proper" is defined as:
#       comma delimited
#       if a string contains a comma, it is double quoted
#       if a string contains a newline, it is double quoted
#       double quotes occurring within a string are escaped by another double quote
#   2) file does *not* have a header row

def main(argv):
    """
    Run `Remove newlines` from a CSV file.

    Arguments
    ----------
    -h: print help
    -i: str
        Absolute path to a valid CSV file.
    -d: str
        Delimiter (','). For delimiters with special characters, quote the delimiter in apostrophes.
    """
    # parse input arguments
    fn_in=''
    delimiter=''
    fn_sql=''

    output_type = 'oracle'
    newline_char = '\n'
    oracle_newrow = '><><?~`;;`'

     # 'oracle' - delete newlines, replace with spaces.
    try:
        opts, args = getopt.getopt(argv,"hi:d:c:o",["ifile=","delimiter=","ctl="])
    except getopt.GetoptError:
        print('remove_newlines.py -i <input_file> -d <delimiter> -r <row_delimiter>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('remove_newlines.py -i <input_file> -d <delimiter> -r <row_delimiter>')
            sys.exit()
        elif opt in ("-i", "--ifile"):
            fn_in = arg
        elif opt in ("-d", "--delimiter"):
            delimiter = arg
        elif opt in ("-r", "--row-delimiter"):
            oracle_newrow = arg

    # input argument checking
    if os.path.isfile(fn_in) == 1:
        print('Using input file {}'.format(fn_in))
    else:
        print('Cannot find input file {}'.format(fn_in))
        sys.exit(2)

    fn_out=fn_in.strip('.csv')+'_output.csv'
    print('\n'+'~'*40)
    print('Input filename = {}'.format(fn_in))
    print('Delimiter = {}'.format(delimiter))
    print('New row character(s) = {}'.format(oracle_newrow))
    print('Output filename = {}'.format(fn_out))
    print('Please note all output fields will be double quoted.')
    print('~'*40+'\n')
    #raw_input('Press any key to continue.')

    with open(fn_in , 'rb') as input_file:
        reader = csv.reader(input_file, delimiter=',',
                            doublequote=True,
                            quoting=csv.QUOTE_MINIMAL)
        # QUOTE_NONNUMERIC doesn't work because it tries to convert dates are floats
        # consequently, all fields are output quoted
        # not a big deal for oracle, which has optionally enclosed by double quotes parameter

        with open(fn_out,'wb') as fout:
            out = csv.writer(fout, doublequote=True, quoting=csv.QUOTE_NONNUMERIC,
                            lineterminator=oracle_newrow + '\r\n')
            for row in reader:
                out.writerow(row)
                if reader.line_num % 100000 == 0:
                    print('Finished {} million lines.'.format(reader.line_num / 1000000))

    # Summarise output
    print('\n'+'~'*40)
    print('Merging complete\n')
    print('Number of rows processed: {}'.format(reader.line_num))
    print('New file created: {}'.format(fout.name))
    print('~'*40)

if __name__ == "__main__":
    main(sys.argv[1:])
