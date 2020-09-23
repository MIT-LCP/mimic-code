# Notebooks for the paper: *Blood Glucose Management in the Intensive Care Unit: Curation Process and Insights from a Data-driven Approach*

Authors: [Aldo Robles Arévalo](mailto:aldo.arevalo@tecnico.ulisboa.pt); Jason Maley; Lawrence Baker; Susana M. da Silva Vieira; João M. da Costa Sousa; Stan Finkelstein; Roselyn Mateo-Collado; Jesse D. Raffa; Leo A. Celi; Francis DeMichele.

## Structure

### Folder: Notebooks
* JUPYTER notebooks (Python 3)
  * Interactive notebook - Part I **1.0-ara-data-curation-I.ipynb**: This notebook contains the curation and pre-processing process to extract glucose readings and insulin inputs from the Medical Information Mart for Intensive Care (MIMIC). 
  * Interactive notebook - Part II **2.0-ara-pairing-II.ipynb**: This notebook contains the pairing of preceding glucose readings with a regular insulin input and analysis.
* MATLAB Live Script
  * **Glucose_Analysis.mlx**: Contains a deeper statiscally analysis on the glucose readings (compatible with R2020a version). Complementary to *1.0-ara-data-curation-I.ipynb*.
  * **Pairing.mlx**: Contains the results related with the pairing of a preceding glucose reading and a insulin event (compatible with R2020a version). Complementary to *2.0-ara-pairing-II.ipynb*.
  * **Glucose_Analysis.html** & **Pairing.html**: Contain the same information as the scripts mentioned above, but readable only in a web browser.
  
### Folder: Functions
Contains MATLAB functions to run the Live Scripts. Make sure to place these functions in the same working folder where the Live Scripts were saved.
To run them you will need to transform the 
