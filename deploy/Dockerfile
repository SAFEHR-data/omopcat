FROM rocker/shiny-verse:4.4.1

WORKDIR /app
COPY deploy/renv.lock.prod renv.lock

# Install renv and restore environment
RUN install2.r --error --skipinstalled renv && \
    R -e 'renv::restore()'

COPY deploy/omopcat_*.tar.gz /app.tar.gz
RUN R -e 'remotes::install_local("/app.tar.gz", upgrade="never")' && \
    rm /app.tar.gz

ARG OMOPCAT_DATA_PATH

# Run pre-processing script when input data is missing
ADD scripts ./scripts
COPY deploy/.Renviron .Renviron
RUN if [ ! -f "${OMOPCAT_DATA_PATH}/omopcat_concepts.parquet" ]; then \
    Rscript scripts/create_prod_data.R || exit 1; \
    fi;

EXPOSE 3838
CMD ["R", "-e", "options('shiny.port'=3838,shiny.host='0.0.0.0');omopcat::run_app()"]

# to build: docker build -f deploy/Dockerfile --platform=linux/amd64 -t omopcat .
# to run: docker run -p 3838:3838 omopcat
