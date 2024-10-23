# omopcat

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/SAFEHR-data/omopcat/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/SAFEHR-data/omopcat/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/SAFEHR-data/omopcat/graph/badge.svg?token=51UZPgLZMZ)](https://codecov.io/gh/SAFEHR-data/omopcat)
<!-- badges: end -->

The `omopcat` web app provides an interactive dashboard to display a catalogue of available OMOP data. It enables
users to interactively explore available OMOP concepts by showing useful summary statistics
and subsequently export a selection of concepts of interest.

## Overview

1. [Installation](#installation)
1. [Usage](#usage)
1. [Deployment](#deploying-with-docker)
1. [Developer instructions](https://github.com/SAFEHR-data/omopcat/wiki/)

## Installation

You can install the development version of omopcat from within R like so:

```r
install.packages("remotes")
usethis::create_github_token()
credentials::set_github_pat()
remotes::install_github("SAFEHR-data/omopcat")
```

You will need to copy the PAT from the web page that `usethis::create_github_token`
opens and paste it into the input that `credentials::set_github_pat` provides.

## Usage

Once the app is installed, you can run it locally with

```r
library(omopcat)
run_app()
```

By default, this will run the app in `dev` mode and use a small dummy data set to host the app 
([see the wiki for more details](https://github.com/SAFEHR-data/omopcat/wiki/Data)).

To run the app in production mode, set the `GOLEM_CONFIG_ACTIVE` environment variable to `production`.
From within R this can be done by

```r
library(omopcat)
Sys.setenv(GOLEM_CONFIG_ACTIVE = "production")
run_app()
```

or by setting it in a local [`.Renviron`](https://usethis.r-lib.org/reference/edit.html) file.

Note that running the app locally in production mode should only be done for testing purposes.
To run a truly productionised version, we provide a [containerised deployment](#deployment).

## Deploying with Docker

We provide a [Docker](https://www.docker.com/) container and [`docker-compose`](https://docs.docker.com/compose/)
configuration to run the app in a production environment.

A test version can be run with

```sh
docker compose -f deploy/docker-compose.test.yml up -d
```

which will use the [test data](./data/test_data).

To deploy a production version, using the data from `data/prod_data` (needs to be populated manually), run

```sh
docker compose -f deploy/docker-compose.yml up -d
```

By default, the app will be hosted at `http://localhost:3838`.

See the [deployment docs](./deploy/README.md) for more details.
