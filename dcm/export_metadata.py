# This script sxtracts meta-data from DICOMs and place it into two files:
# (1) for sequence data, output it as a json
# (2) for tabular data, output it as a CSV (readable by pandas)
# Note that the function does *not* output values if they are longer than 100 characters.
# This avoids outputting look up tables.

import os
import argparse
import sys
import gzip
from pathlib import Path

import json
import pandas as pd
from tqdm import tqdm
import pydicom

parser = argparse.ArgumentParser(description='Extract meta-data from DICOMs')

parser.add_argument('--data', '-d',
                    default='./files',
                    help='path to DICOM format images')
parser.add_argument('--out', '-o', default='dicom-metadata.csv.gz',
                    help=('name out dataframe output, '
                          '(default: dicom-metadata.csv.gz), '
                          'note: this is a compressed format.'))
parser.add_argument('--json', '-j', default=None,
                    help=('name of the output json file, '
                          '(default: <output-stem>.json)'))
parser.add_argument('--number', '-n', type=int, default=None,
                    help=('limit the number of DICOMs to process '
                          ' (default: None).'))


def recurse(ds):
    """
    Recurses through sequences and adds them to a dictionary

    Does not save elements longer than 100 elements, but
    notes their existence in the final dictionary.
    """

    tmp_dict = dict()
    for elem in ds:
        if elem.VR == 'SQ':
            # do not include look up tables
            if 'LUT' not in elem.name:
                [recurse(item) for item in elem]
        else:
            e = elem.tag.group << 16 | elem.tag.element

            # Save element value to a dictionary
            # *unless* it is huge - these are usually images
            if hasattr(elem.value, '__len__'):
                if elem.value.__len__() > 100:
                    tmp_dict[e] = None
                else:
                    if type(elem.value) is pydicom.multival.MultiValue:
                        tmp_dict[e] = list(elem.value)
                    else:
                        tmp_dict[e] = elem.value
            else:
                if type(elem.value) is pydicom.multival.MultiValue:
                    tmp_dict[e] = list(elem.value)
                else:
                    tmp_dict[e] = elem.value
    return tmp_dict


if __name__ == "__main__":
    args = parser.parse_args()

    base_path = Path(args.data)
    out_filename = args.out
    if args.json is not None:
        json_filename = args.json
    else:
        json_filename = out_filename
        if json_filename.endswith('.gz'):
            json_filename = json_filename[0:-3]
        if json_filename.endswith('.csv'):
            json_filename = json_filename[0:-4]
        json_filename += '.json'

    # get list of all dicoms under the given path
    files = list()
    for h in os.listdir(base_path):
        for pt in os.listdir(base_path / h):
            for st in os.listdir(base_path / f'{h}{os.sep}{pt}'):
                dcm_path = f'{base_path}{os.sep}{h}{os.sep}{pt}{os.sep}{st}'
                dcms = os.listdir(dcm_path)

                files.extend([f'{dcm_path}{os.sep}{d}' for d in dcms])
    files.sort()

    N = len(files)
    print(f'Found {N} files.')
    if args.number is not None:
        if args.number < N:
            # limit number of dicoms
            print(f'Limiting parsing to {args.number} of {N} DICOMs.')
            N = args.number

    if N == 0:
        print('No files to process. Exiting.')
        sys.exit()

    dicom_tabular_data = list()
    with open(json_filename, 'w') as fp:
        # initialize the array in the json file
        fp.write('[\n')

        for i in tqdm(range(N)):
            if i > 0:
                fp.write(',\n')
            dicom_full_path = files[i]

            # dicom filename is the last name in filepath
            fn = dicom_full_path.split('/')[-1].split('.')[0]

            # prepare the json output as a dictionary with this dicom fn as key
            fp.write('{')
            fp.write(f'"{fn}": ')

            # load info from dicom
            with open(dicom_full_path, 'rb') as dcm_fp:
                plan = pydicom.dcmread(dcm_fp, stop_before_pixels=True)

            field_dict = dict()
            dicom_json = dict()

            # go through each element
            for elem in plan:
                # index the dictionary using a long value of group, element
                e = (elem.tag.group << 16) | elem.tag.element

                # sequence data goes into JSON
                if elem.VR == 'SQ':
                    # store number of items in the structured/flat data
                    field_dict[e] = elem.value.__len__()

                    # make a dict for the sequence, which will go into json
                    # don't store look up tables because
                    # they're huge and not human readable
                    if 'LUT' not in elem.name:
                        dicom_json[e] = [recurse(item) for item in elem]
                else:
                    # three "real" data-types: number, string, or list of things
                    field_dict[e] = elem.value

            field_dict['dicom'] = fn
            dicom_tabular_data.append(field_dict)

            # convert dictionary to json
            js = json.dumps(dicom_json)

            # write to json file
            fp.write(js)
            # finish the dicom dictionary
            fp.write('}')

        # end of array in json file
        fp.write('\n]')

    # combine list of dictionary into a dataframe
    df = pd.DataFrame(dicom_tabular_data)
    # make the dicom filename the index
    df.set_index('dicom', inplace=True)

    # write to file
    if out_filename.endswith('.gz'):
        df.to_csv(out_filename, sep=',', compression='gzip')
    else:
        df.to_csv(out_filename, sep=',')
