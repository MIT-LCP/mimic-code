-- ------------------------------------------------------------------
-- Title: Preprocessing abnormalities predictions to a format compatible with LLMs.
-- Description: After detecting the abnormalities in chest X-rays by inference on MIMIC-CXR images using a multi-class detection system, the predictions are pre-processed to a format compatible with LLMs. This pre-processing step includes:
        1. Linking the detected abnormalities in each chest X-ray with the corresponding "FINDINGS" text.
        2. Building the prompts by concatenating the list of detected abnormalities in chest X-rays and their corresponding probabilities into a text string, followed by a special “TL; DR” token. Then, creating the input sequence by appending the ground-truth Findings to the prompt.
    This script corresponds to the second step. 
-- ------------------------------------------------------------------


import json
import random
import regex as re

random.seed(4)


def split_data(data, train_ratio, test_ratio, val_ratio):
    random.shuffle(data)
    total_size = len(data)
    train_size = int(total_size * train_ratio)
    test_size = int(total_size * test_ratio)
    val_size = int(total_size * val_ratio)
    return data[:train_size], data[train_size:train_size + test_size], data[
                                                                       train_size + test_size:train_size + test_size + val_size]


def dump_dict_list_to_json(dict_list, file_path):
    with open(file_path, 'w') as json_file:
        json.dump(dict_list, json_file)
    json_file.close()


def clear_findings(findings):
    clean_findings = ''
    sentences = findings.split('.')[:-1]
    for sentence in sentences:
        s = sentence.lower()
        if re.search("no .*", s) or (re.search("ap.*view", s) and not re.search("demonstrate", s)) or \
                (re.search("ap.*views", s) and not re.search("demonstrate", s)) or \
                (re.search("view.*chest", s) and not re.search("demonstrate", s)) or \
                (re.search("view.*chest", s) and not re.search("demonstrate", s)) or \
                re.search("is normal", s) or re.search("are normal", s) or re.search("normal in size", s) or \
                re.search("is of normal", s) or re.search("top.*normal", s) or re.search("normal size", s) or \
                re.search("lung.*clear", s) or re.search("within normal limits", s) or re.search("clear .* without",
                                                                                                 s) or \
                re.search("contours appear.*stable", s) or re.search("unremarkable", s) or \
                re.search("followup", s) or re.search("follow-up", s) or re.search("chest radiograph.*provided", s) or \
                re.search("chest radiograph.*obtained", s) or \
                re.search("cannot be assessed", s) or re.search("lungs are well-expanded", s) or \
                re.search("wire", s) or re.search("clip", s) or re.search("catheter", s) or re.search("cathether", s) or \
                re.search("device", s) or re.search("pacemaker", s) or \
                re.search("tube", s) or re.search("prosthetic", s) or re.search("prosthesis", s) or re.search("picc",
                                                                                                              s) or \
                re.search("infusion port", s) or re.search("line", s) or re.search("portable.*chest.*obtained", s) or \
                re.search("portable.*chest.*submitted", s) or (
                re.search("portable.*chest", s) and not re.search("demonstrate", s)) or \
                re.search("intubated", s) or re.search("telephone", s) or re.search("icd", s) or \
                re.search("stable", s) or re.search("lung volume.*low", s) or re.search("intact", s) or re.search(
            "unchanged", s) or \
                re.search("interstitial", s) or re.search("aicd", s) or re.search("pacer", s) or \
                re.search("examination.*compared to", s) or re.search("heart size.*normal", s) or re.search("artifact",
                                                                                                            s) or \
                re.search("tortuos", s) or re.search("tortuous", s) or re.search(
            "cardiomediastinal silhouette.*enlarged", s) or \
                re.search("pulmonary vascular congestion", s) or re.search("copd", s) or \
                re.search("obliq", s) or re.search("referring physician", s) or re.search("low lung volume", s) or \
                re.search("lung volume.*decrease", s) or re.search("lung volume.*small", s) or \
                re.search("difficult to assess", s) or \
                re.search("bone", s) or re.search("port-a-cath", s) or re.search("not visualized", s) or \
                re.search("pulmonary edema", s) or re.search("cm.*carina", s) or re.search("rotated", s) or \
                re.search("kyphotic.*position", s) or re.search("pulmonary vascular engorgement", s) or \
                re.search("rotator cuff disease", s) or re.search("at the time of dictation and observation", s) or \
                re.search("patient is", s) or re.search("patient in.*position", s) or \
                re.search("ekg leads", s) or re.search("ecg leads", s) or re.search("compared to prior study dated",
                                                                                    s) or \
                re.search("ett", s) or re.search("stent", s) or re.search("normal chest radiograph", s) or \
                re.search("patient in.*department", s) or re.search("comparison is made to.*from", s) or \
                re.search("normal.*contour", s) or re.search("hardware", s) or re.search(
            "normal cardiomediastinal silhouette", s):
            continue
        elif (re.search("cardiomegaly", s) or (re.search("heart", s) and re.search("enlarged", s)) or (
                re.search("cardiac", s) \
                and (re.search("enlargement", s) or re.search("enlarged", s)))) and not re.search("no cardiomegaly", s):
            continue
        elif re.search("interstitial lung disease", s) or re.search("ILD", s):
            continue
        else:
            clean_findings = clean_findings + sentence.strip() + '. '

    return clean_findings.strip()


def main():
    with open('../data/mimic_cxr.json') as f:
        result = json.load(f)

    labels = {1: 'lesion', 2: 'consolidation', 4: 'atelectasis', 5: 'pleural effusion', 6: 'fibrosis',
              7: 'pneumothorax', 8: 'calcification', 9: 'fracture', 10: 'hilar enlargment', 11: 'scoliosis',
              12: 'eventration', 13: 'pneumoperitoneum', 14: 'hernia', 15: 'emphysema', 16: 'aorticdilatation',
              17: 'thickening', 18: 'tracheal deviation', 19: 'subcutaneous emphysema'}

    for key, value in result.items():
        text = ''
        labels_copy = labels.copy()
        new_dict = dict()
        for index, prob in enumerate(result[key]['probabilities']):
            label = int(result[key]['labels'][index])
            if float(prob) > 0.2:
                prob_text = prob[2:4]
            else:
                continue
            if label in labels_copy.keys():
                new_dict[label] = prob_text
                labels_copy.pop(label)
            else:
                continue
        for label, prob in labels.items():
            if label in new_dict.keys():
                text = text + ' ' + labels[label] + ' ' + new_dict[label]
            else:
                continue
        result[key]['proposition'] = text

    data_list = []
    for key, value in result.items():
        if len(result[key]['proposition']) > 3 and len(result[key]['FINDINGS']):
            clean_findings = clear_findings(result[key]['FINDINGS'])
            if clean_findings != '':
                data_list.append({'text': result[key]['proposition'] + ' TL;DR ' + clean_findings})
    random.shuffle(data_list)
    train_set, test_set, val_set = split_data(data_list, 0.7, 0.2, 0.1)
    dump_dict_list_to_json(train_set, '../data/train.json')
    dump_dict_list_to_json(test_set, '../data/test.json')
    dump_dict_list_to_json(val_set, '../data/valid.json')


if __name__ == '__main__':
    main()
