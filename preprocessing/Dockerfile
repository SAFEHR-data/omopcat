FROM rocker/tidyverse:4.4.1

WORKDIR /pkg
ADD preprocessing .

ENV PREPROCESS_OUT_PATH=${PREPROCESS_OUT_PATH}

## For testing only
ARG EUNOMIA_DATA_FOLDER=/etc/preprocessing/data-raw/test_db
RUN mkdir -p ${EUNOMIA_DATA_FOLDER}
ENV EUNOMIA_DATA_FOLDER=${EUNOMIA_DATA_FOLDER}

RUN R -e 'remotes::install_local(path = ".", dependencies = TRUE)'

CMD ["R", "-e", "omopcat.preprocessing::preprocess()"]
