# Machine Learning Analysis on patient mortality by Jeff Chow

## General Project Description

This folder has code that runs a logistic regression and creates a decision tree that predicts patient mortality from data from CHARTEVENTS. 

## How to use

#### Step 1: Using the CHARTEVENTS table from the MIMIC database, create a table for each unit of measurement that contains two columns, one with the HADM_ID and one with the VALUENUM corresponding to that unit of measurement. 

#### Step 2: Average the values for each table where the HADM_ID is the same. 

#### Step 3: Full join all of the tables together by id to create a table that contains a column for each unit and a column for the HADM_ID

#### Step 4: Most columns contain too many empty cells. Keep the top 10 most-filled columns (not including the expire column). 

#### Step 5: Run dec_tree.R to create a decision tree. Run log_reg.R to perform logistic regression. 

## Results 

### Accuracy with logistic regression is 89.47%. Accuracy with the decision tree is 89.54%. 

## Conclusions

### Decision tree was slightly better at predicting mortality per hospital stay. Both models performed with high accuracy (~90%). 

## Future Work

### Test whether logistic regression performs better on patients that are similar to each other by performing logistic regression on N most similar patients with similarity defined as the cosine of the angle of two patient vectors. 
