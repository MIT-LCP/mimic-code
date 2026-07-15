
# ECG Signal Processing with MIMIC-IV

This project demonstrates how to process and analyze electrocardiogram (ECG) recordings from the MIMIC-IV ECG database using Python.
The notebook loads a 12-lead ECG record with the WFDB library, preprocesses the signal using NeuroKit2, detects R-peaks, and extracts cleaned ECG waveforms for further analysis. The processed signals can be used as the foundation for heart rate and heart rate variability (HRV) analysis.

## Features

- Load ECG recordings directly from the MIMIC-IV ECG database
- Process raw ECG signals using NeuroKit2
- Detect R-peaks and cardiac waveform features
- Prepare data for HR, HRV, and rhythm classification
