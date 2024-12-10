# Stage 1: installing renv environment
FROM rocker/shiny-verse:4.4.1 AS base

WORKDIR /app

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
FROM rocker/shiny-verse:4.4.1

WORKDIR /app
COPY --from=base /app .

# Install omopcat package
# Put package in a subdirectory to avoid overwriting renv files from previous stage
COPY app ./pkg
RUN R -e 'devtools::install("pkg", dependencies = FALSE)'

EXPOSE 3838
CMD ["R", "-e", "options('shiny.port'=3838, shiny.host='0.0.0.0'); omopcat::run_app()" ]
