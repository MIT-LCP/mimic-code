# Reproducing the indwelling arterial catheter study (aline study) on AWS

This folder contains code for reproducing a study on indwelling arterial catheters:

> Hsu DJ, Feng M, Kothari R, Zhou H, Chen KP, Celi LA. The association between indwelling arterial catheters and mortality in hemodynamically stable patients with respiratory failure: a propensity score analysis. CHEST Journal. 2015 Dec 1;148(6):1470-6.

The study showed, in the MIMIC-II database, that after adjustment for various confounders, indwelling arterial catheters were not associated with a mortality benefit.

The code here reproduces this study in the MIMIC-III database. This involved many technical changes due to schema differences and data differences between MIMIC-II and MIMIC-III. As MIMIC-III covers four additional years, the cohort extracted here is larger than that reported in the study.

# Requirements

This version of the aline study has been modified to work with the MIMIC-III dataset in the AWS OpenData program and query it using AWS Athena instead of PostgreSQL.
You can learn more about the details of this modification and see a performance and cost comparison in this blog post:

# Running the study

The study can be reproduced by:

1. Use the below Launch Stack button to deploy access to the MIMIC-III dataset into your AWS account.  This will give you real-time access to the MIMIC-III data in your AWS account without having to download a copy of the MIMIC-III dataset.  It will also deploy a Jupyter Notebook with access to the content of this GitHub repository in your AWS account.    Prior to launching this, please login to the [MIMIC PhysioNet website](https://mimic.physionet.org/), [input your AWS account number](https://physionet.org/settings/cloud/), and [request access to the MIMIC-III Clinical Database on AWS](https://physionet.org/projects/mimiciii/1.4/request_access/2).    

To start this deployment, click the Launch Stack button.  On the first screen, the template link has already been specified, so just click next.  On the second screen, provide a Stack name (letters and numbers) and click next, on the third screen, just click next.  On the forth screen, at the bottom, there is a box that says **I acknowledge that AWS CloudFormation might create IAM resources.**.  Check that box, and then click **Create**.  Once the Stack has complete deploying, look at the **Outputs** tab of the AWS CloudFormation console for links to your Juypter Notebooks instance.

[![cloudformation-launch-stack](../../buildmimic/aws-athena/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=MIMIC&templateURL=https://aws-bigdata-blog.s3.amazonaws.com/artifacts/biomedical-informatics-studies/mimic-iii-athena.yaml)

2. Running the `aline-awsathena.ipynb` file - this notebook generates the data (using the SQL files in this directory) and saves a single dataframe to CSV

3. Running the `aline_propensity_score.ipynb` file - this notebook uses R and the above CSV to create a propensity score and calculate the mortality difference between matched pairs

# Slight modifications

There are a few minor differences between our reproduction and the original study.

* the original study subselected variables using a genetic algorithm, whereas we simply use the final set of variables they report
* we did not include PO2 and PCO2 in the propensity score
* we removed patients based on hospital service, not ICU service
