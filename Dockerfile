FROM rocker/r-ver:4.0.3

## Set a default user. Available via runtime flag `--user rserve`
## User should also have & own a home directory (for rstudio or linked volumes to work properly).
RUN useradd rserve \
	&& mkdir /home/rserve \
	&& chown rserve:rserve /home/rserve

## install libs
RUN R -e "install.packages('Rserve', version='1.8-7', repos='http://rforge.net')"
RUN R -e "install.packages('data.table', version='1.13.6')"
RUN R -e "install.packages('jsonlite', version='1.7.3')"
RUN R -e "install.packages('remotes', version='2.2.0')"
RUN R -e "remotes::install_github('VEuPathDB/plot.data','v0.1.0')"


## Rserve
RUN mkdir -p /opt/rserve
ENV RSERVE_HOME /opt/rserve

COPY etc/Rserv.conf /etc/Rserv.conf
RUN mkdir ${RSERVE_HOME}/lib
COPY lib/functions.R ${RSERVE_HOME}/lib
COPY lib/preload.R ${RSERVE_HOME}/lib

RUN mkdir ${RSERVE_HOME}/work

EXPOSE 6311

CMD R -e "Rserve::Rserve(args=\"--vanilla\")"
