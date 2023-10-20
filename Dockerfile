FROM rocker/r-ver:4.2.2

## Set a default user. Available via runtime flag `--user rserve`
## User should also have & own a home directory (for rstudio or linked volumes to work properly).
RUN useradd rserve \
	&& mkdir /home/rserve \
	&& chown rserve:rserve /home/rserve

RUN apt-get update && apt-get install -y \
	libglpk-dev \
	libxml2-dev

## install libs
### Rserve
RUN R -e "install.packages('Rserve', version='1.8-9', repos='http://rforge.net')"

### CRAN
RUN R -e "install.packages('bit64')"
RUN R -e "install.packages('data.table')"
RUN R -e "install.packages('dplyr')"
RUN R -e "install.packages('jsonlite')"
RUN R -e "install.packages('remotes')"
RUN R -e "install.packages('Rcpp')"
RUN R -e "install.packages('readr')"
RUN R -e "install.packages('digest')"

### Bioconductor
RUN R -e "install.packages('BiocManager')"
RUN R -e "BiocManager::install('SummarizedExperiment')"
RUN R -e "BiocManager::install('DESeq2')"
RUN R -e "BiocManager::install('Maaslin2')"

RUN R -e "print('hi ann3')"
RUN R -e "remotes::install_github('VEuPathDB/veupathUtils', 'v2.3.5')"
RUN R -e "remotes::install_github('VEuPathDB/plot.data','feature-229-add-network')"
RUN R -e "remotes::install_github('VEuPathDB/microbiomeComputations', 'update-tojson-correlationResult')"

## Rserve
RUN mkdir -p /opt/rserve
ENV RSERVE_HOME /opt/rserve

COPY etc/Rserv.conf /etc/Rserv.conf
RUN mkdir ${RSERVE_HOME}/lib
COPY lib/ ${RSERVE_HOME}/lib/

RUN mkdir ${RSERVE_HOME}/work

EXPOSE 6311

ENV DEBUG FALSE
CMD R -e "Rserve::Rserve(debug = "${DEBUG}", args=\"--vanilla\")"
