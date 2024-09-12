# calypso

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/SAFEHR-data/omop-data-catalogue/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/SAFEHR-data/omop-data-catalogue/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of calypso is to provide a summary of OMOP data and display it in a public data catalogue

## Overview

1. [Installation](#installation)
1. [Deployment](./deploy/README.md)
1. [Developer instructions](https://github.com/SAFEHR-data/omop-data-catalogue/wiki/)


## Installation

You can install the development version of calypso from within R like so:

```r
install.packages("remotes")
usethis::create_github_token()
credentials::set_github_pat()
remotes::install_github("SAFEHR-data/omop-data-catalogue")
```

You will need to copy the PAT from the web page that `usethis::create_github_token`
opens and paste it into the input that `credentials::set_github_pat` provides.

## Deployment

See the [deployment docs](./deploy/README.md).
