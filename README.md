# MIMIC Code Repository [![Build Status](https://travis-ci.org/MIT-LCP/mimic-code.svg?branch=master)](https://travis-ci.org/MIT-LCP/mimic-code) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.821872.svg)](https://doi.org/10.5281/zenodo.821872)[![Join the chat at https://gitter.im/MIT-LCP/mimic-code](https://badges.gitter.im/MIT-LCP/mimic-code.svg)](https://gitter.im/MIT-LCP/mimic-code?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This is a repository of code shared by the research community. The repository is intended to be a central hub for sharing, refining, and reusing code used for analysis of the [MIMIC critical care database](https://mimic.physionet.org). To find out more about MIMIC, please see: https://mimic.physionet.org

You can read more about the code repository in the following open access paper: [The MIMIC Code Repository: enabling reproducibility in critical care research](https://doi.org/10.1093/jamia/ocx084).

If you use code or concepts available in this repository, we would be grateful if you would cite the above paper as follows:

> Johnson, Alistair EW, David J. Stone, Leo A. Celi, and Tom J. Pollard. "The MIMIC Code Repository: enabling reproducibility in critical care research." Journal of the American Medical Informatics Association (2017): ocx084.

You can also directly cite the repository using the above DOI from Zenodo.

## How to contribute

Our team has worked hard to create and share the MIMIC dataset. We encourage you to share the code that you use for data processing and analysis. Sharing code helps to make studies reproducible and promotes collaborative research. To contribute, please:

- Fork the repository using the following link: https://github.com/MIT-LCP/mimic-code/fork. For a background on GitHub forks, see: https://help.github.com/articles/fork-a-repo/
- Commit your changes to the forked repository.
- Submit a pull request to the [MIMIC code repository](https://github.com/MIT-LCP/mimic-code), using the method described at: https://help.github.com/articles/using-pull-requests/

We encourage users to share concepts they have extracted by writing code which generates a materialized view. These materialized views can then be used by researchers around the world to speed up data extraction. For example, ventilation durations can be acquired by creating the ventdurations view in [concepts/durations/ventilation-durations.sql](https://github.com/MIT-LCP/mimic-code/blob/master/concepts/durations/ventilation-durations.sql).

## License

By committing your code to the [MIMIC Code Repository](https://github.com/mit-lcp/mimic-code) you agree to release the code under the [MIT License attached to the repository](https://github.com/mit-lcp/mimic-code/blob/master/LICENSE).

## Coding style

Please refer to the [style guide](https://github.com/MIT-LCP/mimic-code/blob/master/styleguide.md) for guidelines on formatting your code for the repository.

## Building MIMIC

A Makefile build system has been created to facilitate the building of the MIMIC database, and optionally contributed views from the community. Please refer to the [Makefile guide](https://github.com/MIT-LCP/mimic-code/blob/master/Makefile.md) for more details.
