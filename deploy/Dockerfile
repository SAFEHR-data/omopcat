FROM rocker/shiny-verse:4.4.1

WORKDIR /app
COPY renv.lock.prod renv.lock

# Install renv and restore environment
RUN install2.r --error --skipinstalled renv && \
    R -e 'renv::restore()'

COPY omopcat_*.tar.gz /app.tar.gz
RUN R -e 'remotes::install_local("/app.tar.gz", upgrade="never")' && \
    rm /app.tar.gz

EXPOSE 3838
CMD ["R", "-e", "options('shiny.port'=3838,shiny.host='0.0.0.0');library(omopcat);omopcat::run_app()"]

# to build: docker build -t omopcat .
# to run: docker run -p 3838:3838 omopcat
