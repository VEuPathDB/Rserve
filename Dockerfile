FROM rocker/r-ver:4.0.3

## Set a default user. Available via runtime flag `--user rserve`
## User should also have & own a home directory (for rstudio or linked volumes to work properly).
RUN useradd rserve \
	&& mkdir /home/rserve \
	&& chown rserve:rserve /home/rserve

## install libs
RUN R -e "install.packages('Rserve', version='1.8-7', repos='http://rforge.net')"
RUN R -e "install.packages('data.table')"
RUN R -e "install.packages('bit64')"
RUN R -e "install.packages('jsonlite')"
RUN R -e "install.packages('remotes')"
RUN R -e "remotes::install_github('VEuPathDB/plot.data','v0.3.3')"


## Rserve
RUN mkdir -p /opt/rserve
ENV RSERVE_HOME /opt/rserve

COPY etc/Rserv.conf /etc/Rserv.conf
RUN mkdir ${RSERVE_HOME}/lib
COPY lib/functions.R ${RSERVE_HOME}/lib
COPY lib/preload.R ${RSERVE_HOME}/lib

RUN mkdir ${RSERVE_HOME}/work

EXPOSE 6311

ENV DEBUG FALSE
CMD R -e "Rserve::Rserve(debug = "${DEBUG}", args=\"--vanilla\")"
