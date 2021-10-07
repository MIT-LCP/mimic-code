# MIMIC Code Repository [![Build Status](https://travis-ci.org/MIT-LCP/mimic-code.svg?branch=main)](https://travis-ci.org/MIT-LCP/mimic-code) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.821872.svg)](https://doi.org/10.5281/zenodo.821872)

This is a repository of code shared by the research community. The repository is intended to be a central hub for sharing, refining, and reusing code used for analysis of the [MIMIC critical care database](https://mimic.mit.edu). To find out more about MIMIC, please see: https://mimic.mit.edu. Source code for the website is in the [mimic-website GitHub repository](https://github.com/MIT-LCP/mimic-website/).

You can read more about the code repository in the following open access paper: [The MIMIC Code Repository: enabling reproducibility in critical care research](https://doi.org/10.1093/jamia/ocx084).

## Cloud access

The MIMIC database is now available on two major cloud platforms: Google Cloud Platform (GCP) and Amazon Web Services (AWS). To access the data on the cloud, simply add the relevant cloud identifier to your PhysioNet profile. Further instructions are available on [the MIMIC website](https://mimic.mit.edu/iv/access/cloud/).

### Launch MIMIC-III in AWS

MIMIC-III is available on AWS (and MIMIC-IV will be available in the future). Use the below Launch Stack button to deploy access to the MIMIC-III dataset into your AWS account.  This will give you real-time access to the MIMIC-III data in your AWS account without having to download a copy of the MIMIC-III dataset.  It will also deploy a Jupyter Notebook with access to the content of this GitHub repository in your AWS account.    Prior to launching this, please login to the [MIMIC PhysioNet website](https://mimic.mit.edu/), [input your AWS account number](https://physionet.org/settings/cloud/), and [request access to the MIMIC-III Clinical Database on AWS](https://physionet.org/projects/mimiciii/1.4/request_access/2).  

To start this deployment, click the Launch Stack button.  On the first screen, the template link has already been specified, so just click next.  On the second screen, provide a Stack name (letters and numbers) and click next, on the third screen, just click next.  On the forth screen, at the bottom, there is a box that says **I acknowledge that AWS CloudFormation might create IAM resources.**.  Check that box, and then click **Create**.  Once the Stack has complete deploying, look at the **Outputs** tab of the AWS CloudFormation console for links to your Juypter Notebooks instance.

[![cloudformation-launch-stack](buildmimic/aws-athena/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=MIMIC&templateURL=https://aws-bigdata-blog.s3.amazonaws.com/artifacts/biomedical-informatics-studies/mimic-iii-athena.yaml)

## Other useful tools

* [Bloatectomy](https://github.com/MIT-LCP/bloatectomy) ([paper](https://github.com/MIT-LCP/bloatectomy/blob/master/paper/paper.md)) - A python based package for removing duplicate text in clinical notes
* [Medication categories](https://github.com/mghassem/medicationCategories) - Python script for extracting medications from free-text notes
* [MIMIC Extract](https://github.com/MLforHealth/MIMIC_Extract) ([paper](https://doi.org/10.1145/3368555.3384469)) - A python based package for transforming MIMIC-III data into a machine learning friendly format
* [FIDDLE](https://github.com/MLD3/FIDDLE) ([paper](https://doi.org/10.1093/jamia/ocaa139)) - A python based package for a FlexIble Data-Driven pipeLinE (FIDDLE), transforming structured EHR data into a machine learning friendly format

## Acknowledgement

If you use code or concepts available in this repository, we would be grateful if you would add a citation as described on the website: [MIMIC-III citation](http://mimic.mit.edu//iii/about/acknowledgments/#mimic-iii-citation) , [MIMIC-IV citation](http://mimic.mit.edu/iv/overview/acknowledgments/#mimic-iv-citation)

If including a hyperlink to the code, we recommend you use the DOI from Zenodo rather than a GitHub URL: https://doi.org/10.5281/zenodo.821872

## Contributing

Our team has worked hard to create and share the MIMIC dataset. We encourage you to share the code that you use for data processing and analysis. Sharing code helps to make studies reproducible and promotes collaborative research. To contribute, please:

* Fork the repository using the following link: https://github.com/MIT-LCP/mimic-code/fork. For a background on GitHub forks, see: https://help.github.com/articles/fork-a-repo/
* Commit your changes to the forked repository.
* Submit a pull request to the [MIMIC code repository](https://github.com/MIT-LCP/mimic-code), using the method described at: https://help.github.com/articles/using-pull-requests/

We encourage users to share concepts they have extracted by writing code which generates a materialized view. These materialized views can then be used by researchers around the world to speed up data extraction. For example, ventilation durations can be acquired by creating the ventdurations view in [concepts/durations/ventilation_durations.sql](https://github.com/MIT-LCP/mimic-code/tree/new_consol/mimic-iii/concepts/durations/ventilation_durations.sql).

### License

By committing your code to the [MIMIC Code Repository](https://github.com/mit-lcp/mimic-code) you agree to release the code under the [MIT License attached to the repository](https://github.com/mit-lcp/mimic-code/blob/main/LICENSE).

### Coding style

Please refer to the [style guide](https://github.com/MIT-LCP/mimic-code/blob/main/styleguide.md) for guidelines on formatting your code for the repository.
