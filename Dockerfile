FROM rocker/r-ver:4.3.2

## Set a default user. Available via runtime flag `--user rserve`
## User should also have & own a home directory (for rstudio or linked volumes to work properly).
RUN useradd rserve \
	&& mkdir /home/rserve \
	&& chown rserve:rserve /home/rserve

RUN apt-get update && apt-get install -y \
	libglpk-dev \
	libxml2-dev \
	git

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
RUN R -e "install.packages('Hmisc')"

RUN R -e "remotes::install_github('VEuPathDB/plot.data', 'v5.6.2', dependencies=TRUE, upgrade_dependencies=FALSE)"

# microbiomeDB/microbiomeComputations@v5.1.6.2 installs Maaslin2 and `VEuPathDB/veupathUtils`
# which in turn installs SpiecEasi@v1.0.7 and more (see below)
#
# Note that microbiomeDB/microbiomeComputations@v5.1.7 is a whole new ball game and installs mbioUtils.
# mbioUtils shares too many functions with veupathUtils to import both - unless everything is fully qualified e.g. mbioUtils::some_function()
#
# plot.data also installs veupathUtils as a dependency which in turn installs
# - SummarizedExperiment
# - DESeq2
# - zdk123/SpiecEasi@v1.0.7
RUN R -e "remotes::install_github('microbiomeDB/microbiomeComputations', 'v5.1.6.2', dependencies=TRUE, upgrade_dependencies=FALSE)"

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
