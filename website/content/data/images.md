+++
date = "2019-03-14T19:02:13-04:00"
title = "Images"
linktitle = "Images"
weight = 2
toc = false

[menu]
  [menu.main]
    parent = "Data"

+++

# Chest radiographs

Chest radiographs were sourced from the hospital picture archiving and communication system (PACS) in Digital Imaging and Communications in Medicine (DICOM) format.
DICOM is a common format which facilitates interoperability between medical imaging devices. Put simply, the DICOM format contains structured meta-data associated with one or more images, and the DICOM standard stipulates strict rules around the structure of this information.
The DICOM standard is updated regularly each year. MIMIC-CXR is built according to the [DICOM Standard version 2017e](http://dicom.nema.org/medical/dicom/2017e/).

<!--
If you have never worked with DICOM images before, we highly recommend you work through our [tutorial on working with DICOMs]() 


The PACS workstation used by clinicans to view images allows for dynamic adjustment of the mapping between pixel value and grey-level display (``windowing''), side-by-side comparison with previous imaging, overlaying of patient demographics, and overlaying of imaging technique. Reports are  transcribed during reading of an image series using a real-time computer voice recognition service.
-->