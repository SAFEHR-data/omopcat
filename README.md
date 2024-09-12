# calypso

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/SAFEHR-data/omop-data-catalogue/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/SAFEHR-data/omop-data-catalogue/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The `calypso` web app provides an interactive dashboard to display a catalogue of available OMOP data. It enables
users to interactively explore available OMOP concepts by showing useful summary statistics
and subsequently export a selection of concepts of interest.

## Overview

1. [Installation](#installation)
1. [Usage](#usage)
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

## Usage

Once the app is installed, you can run it locally with

```r
library(calypso)
run_app()
```

By default, this will run the app in `dev` mode and use a small dummy data set to host the app 
([see the wiki for more details](https://github.com/SAFEHR-data/omop-data-catalogue/wiki/Data)).

To run the app in production mode, set the `GOLEM_CONFIG_ACTIVE` environment variable to `production`.
From within R this can be done by

```r
library(calypso)
Sys.setenv(GOLEM_CONFIG_ACTIVE = "production")
run_app()
```

or by setting it in a local [`.Renviron`](https://usethis.r-lib.org/reference/edit.html) file.

Note that running the app locally in production mode should only be done for teting purposes.
To run a truly productionised version, we provide a [containerised deployment](#deployment).

## Deployment

See the [deployment docs](./deploy/README.md).
