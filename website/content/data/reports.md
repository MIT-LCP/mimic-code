+++
date = "2019-03-14T19:02:13-04:00"
title = "Reports"
linktitle = "Reports"
weight = 3
toc = false

[menu]
  [menu.main]
    parent = "Data"

+++

# Radiology reports

During routine care, radiologists will review chest radiographs and document their interpretation electronically.
When reviewing a radiograph, radiologists have access to: (1) brief text written by another clinician summarizing the underlying medical condition, (2) the reason for examination, and (3) prior imaging studies performed.

Reports in MIMIC-CXR are semi-structured, and have linebreaks to ensure individual lines are no longer than 79 characters.
As reports are templated, structure is seeded in the reports, but radiologists are free to modify it as they will before saving.
Most reports will contain a ``FINDINGS'' and ``IMPRESSION''. The findings section details the radiologists assessment of the image, while the impression section acts as a summary of the most pertinent findings.

Reports sometimes have addendums at the top. Addenums are added after the radiology report has already been written, and are intended to clarify language as necessary. Addendums are delimited from the original report by underscores which span an entire line.

Radiology reports have been de-identified to protect patient privacy. All patient information has been replaced with three underscores (`___`). Provider information has also been removed.

The following is an example radiology report from MIMIC-CXR:

```
                                 FINAL REPORT
 EXAMINATION:  CHEST (PA AND LAT)
 
 INDICATION:  ___ year old woman with ?pleural effusion  // ?pleural effusion
 
 TECHNIQUE:  Chest PA and lateral
 
 COMPARISON:  ___
 
 FINDINGS: 
 
 Cardiac size cannot be evaluated.  Large left pleural effusion is new.  Small
 right effusion is new.  The upper lungs are clear.  Right lower lobe opacities
 are better seen in prior CT.  There is no pneumothorax.  There are mild
 degenerative changes in the thoracic spine
 
 IMPRESSION: 
 
 Large left pleural effusion
```
