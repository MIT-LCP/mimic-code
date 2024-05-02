# Generation of Radiology Findings in Chest X-Ray by Leveraging Collaborative Knowledge

<p align="justify">
This repository contains the code utilized for preparing the data used in the paper "Generation of Radiology Findings in Chest X-Ray by Leveraging Collaborative Knowledge". The paper was presented and published during the Tenth International Conference on Information Technology and Quantitative Management (ITQM 2023). The concepts and information presented in this paper are based on research results that are not commercially available. Future commercial availability cannot be guaranteed. 
</p>

The paper is available at this [link](https://www.sciencedirect.com/science/article/pii/S1877050923008529).

<p align="justify">The proposed methodology for generating radiology reports follows a two-step approach:</p>


1. <p align="justify">Abnormalities detection and classification in chest X-rays (the code is not available since the model was trained on a private dataset).</p>
2. <p align="justify">Radiology Findings generation through LLM prompt-tuning (the data pre-processing code is available in this repository since the LLM was trained on the publicly availabele MIMIC-CXR dataset).</p>



## Data pre-processing

1. <p align="justify">Extracting the "FINDINGS" and "IMPRESSION" sections from the radiology reports in MIMIC-CXR dataset.</p>


&emsp;&emsp;``!python data_preparation/extract_reports_sections.py``


2. <p align="justify">After detecting the abnormalities in chest X-rays by inference on MIMIC-CXR images using the multi-class detection system, the predictions are pre-processed to a format compatible with LLMs. This pre-processing step includes:</p>

* Linking the detected abnormalities in each chest X-ray with the corresponding "FINDINGS" text.
    <br><br>
    **Observation:** Inference predictions are stored in ``data/MIMIC_predictions.json`` as a dictionary, where each key is the path to a DICOM image in MIMIC-CXR dataset (e.g., ``p10/p10000032/s50414267/02aa804e-bde0afdd-112c0b34-7bc16630-4e384014.dcm``), and the values are dictionaries containing the following key-value pairs:
  * bbxs - a list comprising sublists of length 4, each containing coordinates for the detected abnormalities in chest X-ray images, represented as bounding boxes within the image; 
  * labels - a list containing abnormality indexes, each falling within the range [0, 19];
  * probabilities - a list of probabilities associated with each predicted bounding-box;
  * img_height - the height of the image;
  * img_width - the width of the image.

&emsp;&emsp;``!python data_preparation/link_predictions_with_text_findings.py``

* Building the prompts by concatenating the list of detected abnormalities in chest X-rays and their corresponding probabilities into a text string, followed by a special “TL; DR” token. Then, creating the input sequence by appending the ground-truth Findings to the prompt.
    <br><br>
    **Observation:** In case of absent abnormalities (probability zero), they are excluded form the detection list. Additionally, when devices are identified within the input image, the 'Device' class is also omitted from the list of abnormalities.

&emsp;&emsp;``!python data_preparation/format_data.py``
