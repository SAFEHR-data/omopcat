FROM rocker/shiny-verse:4.4.1

WORKDIR /app
COPY app/renv.lock ./renv.lock

# Speed up building by setting make with multiple cores from env
ARG CORES
ENV MAKE="make -j${CORES}"

# Install renv and restore environment
# omopbundles is installed separately as renv is giving problems
# with GitHub packages
RUN install2.r --error --skipinstalled renv remotes && \
    R -e 'renv::restore(exclude = "omopbundles")' && \
    rm -rf /tmp/downloaded_packages
RUN R -e 'remotes::install_github("SAFEHR-data/omop-bundles")'

# Install the app
ADD app .
RUN R -e 'devtools::install(".", dependencies = TRUE)'

EXPOSE 3838
CMD ["R", "-e", "options('shiny.port'=3838, shiny.host='0.0.0.0'); omopcat::run_app()" ]
