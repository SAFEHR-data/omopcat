# syntax=docker/dockerfile:1
# Stage 1: installing renv environment
FROM rocker/tidyverse:4.6.2@sha256:9241ac461c924334777dd3fb047c6e5e0fd1435a85acc171f1a32836861d0a69 AS base

WORKDIR /app

# bsdtar used as old kernel does not implement openat2
RUN apt-get update && \
    apt-get install -y --no-install-recommends libuv1 libarchive-tools curl && \
    ln -sf /usr/bin/bsdtar /usr/local/bin/tar && \
    rm -rf /var/lib/apt/lists/*
ENV R_INSTALL_TAR=/usr/bin/bsdtar
ENV TAR=/usr/bin/bsdtar

# Speed up building by setting make with multiple cores from env
ARG CORES
ENV MAKE="make -j${CORES}"

RUN mkdir -p renv
COPY app/renv.lock renv.lock
COPY app/.Rprofile .Rprofile
COPY app/renv/activate.R renv/activate.R
COPY app/renv/settings.json renv/settings.json

# change default location of cache to project folder
RUN mkdir renv/.cache
ENV RENV_PATHS_CACHE=renv/.cache

# Install renv and restore environment
# omopbundles is installed separately as renv is giving problems
# with GitHub packages
RUN install2.r --error --skipinstalled renv devtools remotes && \
    R -e 'renv::restore(exclude = "omopbundles")' && \
    rm -rf /tmp/downloaded_packages

# Authenticate with GitHub to avoid the unauthenticated API rate limit (60/hour per IP).
# The token is passed as a build secret (id: github_pat) so it is never stored in an image layer.
# It is optional: without it the install falls back to unauthenticated requests.
RUN --mount=type=secret,id=github_pat,required=false \
    if [ -s /run/secrets/github_pat ]; then export GITHUB_PAT="$(cat /run/secrets/read_omopbundles_pat)"; fi && \
    R -e 'remotes::install_github("SAFEHR-data/omop-bundles")'

# Stage 2: Installing omopcat
FROM rocker/shiny-verse:4.6.2@sha256:698a41041a522198a2ab9deff61a2c2b807c5058885ee0dcc7ac4f525512deb9

# bsdtar used as old kernel does not implement openat2
RUN apt-get update && \
    apt-get install -y --no-install-recommends libuv1 libarchive-tools && \
    rm -rf /var/lib/apt/lists/* 
ENV R_INSTALL_TAR=/usr/bin/bsdtar
ENV TAR=/usr/bin/bsdtar

WORKDIR /app
COPY --from=base /app .

# Install omopcat package
# Put package in a subdirectory to avoid overwriting renv files from previous stage
COPY app ./pkg
RUN R -e 'devtools::install("pkg", dependencies = FALSE)'

EXPOSE 3838
CMD ["R", "-e", "options('shiny.port'=3838, shiny.host='0.0.0.0'); omopcat::run_app()" ]
