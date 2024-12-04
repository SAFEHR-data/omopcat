FROM rocker/tidyverse:4.4.1

WORKDIR /pkg
COPY preprocessing/renv.lock ./renv.lock

# Speed up building by setting make with multiple cores from env
ARG CORES
ENV MAKE="make -j${CORES}"

RUN install2.r --error --skipinstalled renv remotes && \
    R -e 'renv::restore()' && \
    rm -rf /tmp/downloaded_packages

ADD preprocessing .

RUN R -e 'remotes::install_local(path = ".", dependencies = TRUE)'

CMD ["R", "-e", "omopcat.preprocessing::preprocess()"]
