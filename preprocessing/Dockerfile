# Stage 1: installing renv environment
FROM rocker/tidyverse:4.6.2@sha256:9241ac461c924334777dd3fb047c6e5e0fd1435a85acc171f1a32836861d0a69 AS base

WORKDIR /pkg

RUN apt-get update && \
    apt-get install -y --no-install-recommends libuv1 && \
    rm -rf /var/lib/apt/lists/*

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
ENV RENV_PATHS_CACHE=renv/.cache
ENV R_INSTALL_TAR=internal

RUN install2.r --error --skipinstalled renv && \
    R -e 'renv::restore()' && \
    rm -rf /tmp/downloaded_packages

# Stage 2: Installing omopcat.preprocessing
FROM rocker/tidyverse:4.6.2@sha256:9241ac461c924334777dd3fb047c6e5e0fd1435a85acc171f1a32836861d0a69

RUN apt-get update && \
    apt-get install -y --no-install-recommends libuv1 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /pkg
COPY --from=base /pkg .

# Install omopcat.preprocessing package
# Put package in a subdirectory to avoid overwriting renv files from previous stage
COPY preprocessing ./preprocessing
RUN R -e 'devtools::install("preprocessing", dependencies = FALSE)'

CMD ["R", "-e", "omopcat.preprocessing::preprocess()"]
