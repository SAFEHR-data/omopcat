# calypso

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/UCLH-Foundry/omop-data-catalogue/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/UCLH-Foundry/omop-data-catalogue/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of calypso is to provide a summary of OMOP data and display it in a public data catalogue

## Installation

You can install the development version of calypso from within R like so:

```r
# install.packages("pak")
pak::pak("UCLH-Foundry/calypso")
```

## Development

### Set up

Make sure you have a [recent version of R](https://cloud.r-project.org/) (>= 4.0.0) installed.
Though not required, [RStudio](https://www.rstudio.com/products/rstudio/download/) is recommended as an IDE,
as it has good support for R package development and Shiny.

1. Clone this repository

    - Either with `git clone git@github.com:UCLH-Foundry/omop-data-catalogue.git`
    - Or by creating [a new project in RStudio from version control](https://docs.posit.co/ide/user/ide/guide/tools/version-control.html#creating-a-new-project-based-on-a-remote-git-or-subversion-repository)

2. Install [`{renv}`](https://rstudio.github.io/renv/index.html) and restore the project library by running the following from an R console in the project directory:

    ```r
    install.packages("renv")
    renv::restore()
    ```
