FROM rocker/shiny-verse:4.4.1

WORKDIR /app
COPY deploy/renv.lock.prod renv.lock

# Install renv and restore environment
# omopbundles is installed separately as renv is giving problems
# with GitHub packages
RUN R -e 'remotes::install_github("SAFEHR-data/omop-bundles")'
RUN install2.r --error --skipinstalled renv && \
    R -e 'renv::restore(exclude = "omopbundles")'

COPY deploy/omopcat_*.tar.gz /app.tar.gz
RUN R -e 'remotes::install_local("/app.tar.gz", upgrade="never", dependencies = FALSE)' && \
    rm /app.tar.gz

ARG OMOPCAT_DATA_PATH

ADD scripts ./scripts
COPY deploy/.Renviron .Renviron
RUN R -e '' || exit 1

EXPOSE 3838
CMD ["R", "-e", \
    "options('shiny.port'=3838,shiny.host='0.0.0.0');" \
    "source('scripts/create_prod_data.R');" \
    "omopcat::run_app()" \
    ]

# to build: docker build -f deploy/Dockerfile --platform=linux/amd64 -t omopcat .
# to run: docker run -p 3838:3838 omopcat
