FROM calypso_base:4.4.1

WORKDIR /app
COPY renv.lock.prod renv.lock

RUN R -e 'renv::restore()'

COPY calypso_*.tar.gz /app.tar.gz
RUN R -e 'remotes::install_local("/app.tar.gz", upgrade="never")' && \
    rm /app.tar.gz

EXPOSE 3838
CMD ["R", "-e", "options('shiny.port'=3838,shiny.host='0.0.0.0');library(calypso);calypso::run_app()"]

# to build: docker build -t calypso .
# to run: docker run -p 3838:3838 calypso
