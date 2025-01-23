# Stage 1: installing renv environment
FROM rocker/tidyverse:4.4.2 AS base

WORKDIR /pkg

# Speed up building by setting make with multiple cores from env
ARG CORES
ENV MAKE="make -j${CORES}"

RUN mkdir -p renv
COPY preprocessing/renv.lock renv.lock
COPY preprocessing/.Rprofile .Rprofile
COPY preprocessing/renv/activate.R renv/activate.R
COPY preprocessing/renv/settings.json renv/settings.json

# change default location of cache to project folder
RUN mkdir renv/.cache
ENV RENV_PATHS_CACHE renv/.cache

RUN install2.r --error --skipinstalled renv && \
    R -e 'renv::restore()' && \
    rm -rf /tmp/downloaded_packages

# Stage 2: Installing omopcat.preprocessing
FROM rocker/tidyverse:4.4.2

WORKDIR /pkg
COPY --from=base /pkg .

# Install omopcat.preprocessing package
# Put package in a subdirectory to avoid overwriting renv files from previous stage
COPY preprocessing ./preprocessing
RUN R -e 'devtools::install("preprocessing", dependencies = FALSE)'

CMD ["R", "-e", "omopcat.preprocessing::preprocess()"]
