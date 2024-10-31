FROM rocker/tidyverse:4.4.1

WORKDIR /pkg
ADD preprocessing .

ENV OMOPCAT_DATA_PATH=${OMOPCAT_DATA_PATH}

RUN R -e 'remotes::install_local(path = ".", dependencies = TRUE)'

CMD ["R", "-e", "omopcat.preprocessing::preprocess()"]
