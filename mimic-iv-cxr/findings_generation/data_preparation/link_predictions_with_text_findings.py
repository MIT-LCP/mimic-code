-- ------------------------------------------------------------------
-- Title: Preprocessing abnormalities predictions to a format compatible with LLMs.
-- Description: After detecting the abnormalities in chest X-rays by inference on MIMIC-CXR images using a multi-class detection system, the predictions are pre-processed to a format compatible with LLMs. This pre-processing step includes:
        1. Linking the detected abnormalities in each chest X-ray with the corresponding "FINDINGS" text.
        2. Building the prompts by concatenating the list of detected abnormalities in chest X-rays and their corresponding probabilities into a text string, followed by a special “TL; DR” token. Then, creating the input sequence by appending the ground-truth Findings to the prompt.
    This script corresponds to the first step. 
-- ------------------------------------------------------------------


import json
import os
from tqdm import tqdm


def main():
    with open('../data/MIMIC_predictions.json', 'r') as f:
        data = json.load(f)

    with open('../data/mimic_findings.json', 'r') as f:
        mimic_findings = json.load(f)

    new_data = {}

    for index, elem in tqdm(enumerate(data)):
        elem_dict = {}
        elem_dict['labels'] = data[elem]['labels']
        elem_dict['probabilities'] = data[elem]['probabilities']
        findings_key = os.path.dirname(elem).replace('/', '\\') + '.txt'
        elem_dict['FINDINGS'] = mimic_findings['..\\data\\' + findings_key]['FINDINGS']
        elem_dict['IMPRESSION'] = mimic_findings['..\\data\\' + findings_key]['IMPRESSION']
        if elem_dict['FINDINGS'] != '':
            new_data[elem] = elem_dict

    with open("../data/mimic_cxr.json", "w") as outfile:
        json.dump(new_data, outfile)


if __name__ == '__main__':
    main()