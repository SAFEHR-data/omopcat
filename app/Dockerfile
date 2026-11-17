# Stage 1: installing renv environment
FROM rocker/tidyverse:4.6.2@sha256:9241ac461c924334777dd3fb047c6e5e0fd1435a85acc171f1a32836861d0a69 AS base

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends libuv1 && \
    rm -rf /var/lib/apt/lists/*

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
ENV RENV_PATHS_CACHE renv/.cache

# Install renv and restore environment
# omopbundles is installed separately as renv is giving problems
# with GitHub packages
RUN install2.r --error --skipinstalled renv devtools remotes && \
    R -e 'renv::restore(exclude = "omopbundles")' && \
    rm -rf /tmp/downloaded_packages
RUN R -e 'remotes::install_github("SAFEHR-data/omop-bundles")'

# Stage 2: Installing omopcat
FROM rocker/shiny-verse:4.6.2@sha256:698a41041a522198a2ab9deff61a2c2b807c5058885ee0dcc7ac4f525512deb9

RUN apt-get update && \
    apt-get install -y --no-install-recommends libuv1 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=base /app .

# Install omopcat package
# Put package in a subdirectory to avoid overwriting renv files from previous stage
COPY app ./pkg
RUN R -e 'devtools::install("pkg", dependencies = FALSE)'

EXPOSE 3838
CMD ["R", "-e", "options('shiny.port'=3838, shiny.host='0.0.0.0'); omopcat::run_app()" ]
