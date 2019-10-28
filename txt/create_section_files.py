# This script extracts the conclusion section from MIMIC-CXR reports
# It outputs them into individual files with at most 10,000 reports.
import sys
import os
import argparse
import csv
from pathlib import Path

from tqdm import tqdm

# local folder import
import section_parser as sp

parser = argparse.ArgumentParser()
parser.add_argument('--reports_path',
                    required=True,
                    help=('Path to file with radiology reports,'
                          ' e.g. /data/mimic-cxr/files'))
parser.add_argument('--output_path',
                    required=True,
                    help='Path to output CSV files.')
parser.add_argument('--no_split', action='store_true',
                    help='Do not output batched CSV files.')


def list_rindex(l, s):
    """Helper function: *last* matching element in a list"""
    return len(l) - l[-1::-1].index(s) - 1


def main(args):
    args = parser.parse_args(args)

    reports_path = Path(args.reports_path)
    output_path = Path(args.output_path)

    if not output_path.exists():
        output_path.mkdir()

    # not all reports can be automatically sectioned
    # we load in some dictionaries which have manually determined sections
    custom_section_names, custom_indices = sp.custom_mimic_cxr_rules()

    # get all higher up folders (p00, p01, etc)
    p_grp_folders = os.listdir(reports_path)
    p_grp_folders = [p for p in p_grp_folders
                     if p.startswith('p') and len(p) == 3]
    p_grp_folders.sort()

    # patient_studies will hold the text for use in NLP labeling
    patient_studies = []

    # study_sections will have an element for each study
    # this element will be a list, each element having text for a specific section
    study_sections = []
    for p_grp in p_grp_folders:
        # get patient folders, usually around ~6k per group folder
        cxr_path = reports_path / p_grp
        p_folders = os.listdir(cxr_path)
        p_folders = [p for p in p_folders if p.startswith('p')]
        p_folders.sort()

        # For each patient in this grouping folder
        print(p_grp)
        for p in tqdm(p_folders):
            patient_path = cxr_path / p

            # get the filename for all their free-text reports
            studies = os.listdir(patient_path)
            studies = [s for s in studies
                       if s.endswith('.txt') and s.startswith('s')]

            for s in studies:
                # load in the free-text report
                with open(patient_path / s, 'r') as fp:
                    text = ''.join(fp.readlines())

                # get study string name without the txt extension
                s_stem = s[0:-4]

                # custom rules for some poorly formatted reports
                if s_stem in custom_indices:
                    idx = custom_indices[s_stem]
                    patient_studies.append([s_stem, text[idx[0]:idx[1]]])
                    continue

                # split text into sections
                sections, section_names, section_idx = sp.section_text(
                    text
                )

                # check to see if this has mis-named sections
                # e.g. sometimes the impression is in the comparison section
                if s_stem in custom_section_names:
                    sn = custom_section_names[s_stem]
                    idx = list_rindex(section_names, sn)
                    patient_studies.append([s_stem, sections[idx].strip()])
                    continue

                # grab the *last* section with the given title
                # prioritizes impression > findings, etc.

                # "last_paragraph" is text up to the end of the report
                # many reports are simple, and have a single section
                # header followed by a few paragraphs
                # these paragraphs are grouped into section "last_paragraph"

                # note also comparison seems unusual but if no other sections
                # exist the radiologist has usually written the report
                # in the comparison section
                idx = -1
                for sn in ('impression', 'findings',
                           'last_paragraph', 'comparison'):
                    if sn in section_names:
                        idx = list_rindex(section_names, sn)
                        break

                if idx == -1:
                    # we didn't find any sections we can use :(
                    patient_studies.append([s_stem, ''])
                    print(f'no impression/findings: {patient_path / s}')
                else:
                    # store the text of the conclusion section
                    patient_studies.append([s_stem, sections[idx].strip()])

                study_sectioned = [s_stem]
                for sn in ('impression', 'findings',
                           'last_paragraph', 'comparison'):
                    if sn in section_names:
                        idx = list_rindex(section_names, sn)
                        study_sectioned.append(sections[idx].strip())
                    else:
                        study_sectioned.append(None)
                study_sections.append(study_sectioned)
    # write distinct files to facilitate modular processing
    if len(patient_studies) > 0:
        # write out a single CSV with the sections
        with open(output_path / 'mimic_cxr_sectioned.csv', 'w') as fp:
            csvwriter = csv.writer(fp)
            # write header
            csvwriter.writerow(['study', 'impression', 'findings',
                                'last_paragraph', 'comparison'])
            for row in study_sections:
                csvwriter.writerow(row)

        if args.no_split:
            # write all the reports out to a single file
            with open(output_path / f'mimic_cxr_sections.csv', 'w') as fp:
                csvwriter = csv.writer(fp)
                for row in patient_studies:
                    csvwriter.writerow(row)
        else:
            # write ~22 files with ~10k reports each
            n = 0
            jmp = 10000

            while n < len(patient_studies):
                n_fn = n // jmp
                with open(output_path / f'mimic_cxr_{n_fn:02d}.csv', 'w') as fp:
                    csvwriter = csv.writer(fp)
                    for row in patient_studies[n:n+jmp]:
                        csvwriter.writerow(row)
                n += jmp


if __name__ == '__main__':
    main(sys.argv[1:])
