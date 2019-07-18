# Study MIMIC-III data using AWS Athena

The MIMIC-III dataset is available in the AWS cloud through our [Open Data on AWS program](https://registry.opendata.aws/).  This allows researchers to use the MIMIC-III dataset without having to download it, make a copy of it, or pay to store it.  They can simply analyze MIMIC-III using AWS services like Amazon EC2, Amazon Athena, AWS Lambda, or Amazon EMR by pointing to its address in the AWS cloud. This makes it faster and less expensive to perform research studies.  In order to access the MIMIC-III data on AWS, you must first provide you AWS Account ID through the [PhysioNet website](https://physionet.org/works/MIMICIIIClinicalDatabase/).

Learn more about using the MIMIC-III dataset on AWS from this blog post:  

Found here is some useful code to help you understand how to access the MIMIC-III dataset on AWS.

### mimic-iii-athena.yaml

This is an [AWS CloudFormation Template](https://aws.amazon.com/cloudformation/) that will deploy a database in the [AWS Glue](https://aws.amazon.com/glue/) Data Catalog that contains all of the MIMIC-III tables.  It also deploys a Jupyter Notebook instance in [Amazon SageMaker](https://aws.amazon.com/sagemaker/) that contains the content of this [mimic-code](https://github.com/MIT-LCP/mimic-code/) GitHub repository and is set up to access the MIMIC-III data through AWS Glue.  This repository contains a version of the [Aline Study](https://github.com/JamesSWiggins/mimic-code/tree/master/notebooks/aline/awsathena) that is configured to run it's SQL queries against the MIMIC-III data in AWS using [AWS Athena](https://aws.amazon.com/athena/).

Use the below Launch Stack button to deploy this AWS CloudFormation template into your AWS account and look at the **Outputs** tab of the AWS CloudFormation console for links to your Juypter Notebooks instance.

[![cloudformation-launch-stack](cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=MIMIC&templateURL=https://aws-bigdata-blog.s3.amazonaws.com/artifacts/biomedical-informatics-studies/mimic-iii-athena.yaml)

### mimictoparquet_glue_job.py
