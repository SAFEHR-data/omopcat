FROM rocker/tidyverse:4.4.1

WORKDIR /pkg
ADD preprocessing .

RUN install2.r --error --skipinstalled renv remotes && \
    R -e 'renv::restore()' && \
    rm -rf /tmp/downloaded_packages

RUN R -e 'remotes::install_local(path = ".", dependencies = TRUE)'

CMD ["R", "-e", "omopcat.preprocessing::preprocess()"]
