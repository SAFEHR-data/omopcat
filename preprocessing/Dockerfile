FROM rocker/tidyverse:4.4.1

WORKDIR /pkg
ADD preprocessing .

RUN R -e 'remotes::install_local(path = ".", dependencies = TRUE)'

CMD ["R", "-e", "omopcat.preprocessing::preprocess()"]
