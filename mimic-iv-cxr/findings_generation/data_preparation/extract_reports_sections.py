-- ------------------------------------------------------------------
-- Title: Extracting sections of the reports.
-- Description: Extracting the "FINDINGS" and "IMPRESSION" sections from the radiology reports in MIMIC-CXR dataset.
-- ------------------------------------------------------------------


import glob
import json
import tqdm


def extract_final_report(report_path, report_paths, labels):
    text = []
    is_final_report = False
    f = open(report_paths[report_path], "r")
    for line in f:
        if line.split() == ['FINAL', 'REPORT']:
            is_final_report = True
            continue
        if is_final_report:
            if line.split():
                text.append(line.split())

    final_reports = {'FINDINGS': '', 'IMPRESSION': ''}
    i = 0
    while i < len(text):
        tmp_result = []
        if text[i][0].replace(':', '').isupper() and ':' in text[i][0]:
            tmp_result = tmp_result + text[i]
            i = i + 1
            while i < len(text) and ':' not in text[i][0]:
                tmp_result = tmp_result + text[i]
                i = i + 1
        if tmp_result:
            if tmp_result[0].replace(':', '') in labels:
                final_reports[tmp_result[0].replace(':', '')] = ''.join(
                    [(tmp_result[idx] + ' ') for idx, word in enumerate(tmp_result) if idx > 0])
                final_reports[tmp_result[0].replace(':', '')] = final_reports[tmp_result[0].replace(':', '')][:-1]
        else:
            i = i + 1

    return final_reports


def main():
    reports_path = r"..\data\MIMIC\physionet.org\files\mimic-cxr\2.0.0\files"
    output_path = r"..\data\mimic_findings.json"

    # Get report paths
    paths = glob.glob(reports_path + '\**\**\*.txt', recursive=False)
    report_paths = {}
    for path in paths:
        report_paths[path] = path

    labels = ['FINDINGS', 'IMPRESSION']
    report_findings = {}
    for key, _ in tqdm.tqdm(report_paths.items()):
        report_findings[key.replace(reports_path + '\\', '')] = extract_final_report(key, report_paths, labels)

    with open(output_path, 'w') as f:
        json.dump(report_findings, f)


if __name__ == "__main__":
    main()
