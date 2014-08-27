FROM cbarraford/r3x:3.1.1
ENV REFRESHED_AT 2014-08-26

MAINTAINER Brian Claywell <bclaywel@fhcrc.org>

# Set debconf to noninteractive mode.
# https://github.com/phusion/baseimage-docker/issues/58#issuecomment-47995343
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install requirements.
RUN apt-get update -q && \
    apt-get install -y -q --no-install-recommends \
    gdebi-core \
    libopenblas-base

WORKDIR /root

# Install shiny-server.
RUN wget http://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.2.1.362-amd64.deb
RUN gdebi -n shiny-server-1.2.1.362-amd64.deb && \
    rm shiny-server-1.2.1.362-amd64.deb

# Confine shiny-server to the shiny user's home directory.
WORKDIR /home/shiny
ENV HOME /home/shiny

# Configure the shiny user's R environment.
ADD Rprofile /home/shiny/.Rprofile

USER shiny
RUN mkdir -p log srv R/library

# Install R dependencies.
RUN R -e "install.packages(c('shiny', 'devtools'), repos='http://cran.rstudio.com/')"
RUN R -e "devtools::install_github('rstudio/rmarkdown')"

# Switch back to root for the rest of the configuration.
USER root

ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint
ADD shiny-server.conf /etc/shiny-server/shiny-server.conf

# Set debconf back to normal.
RUN echo 'debconf debconf/frontend select Dialog' | debconf-set-selections

# Configure exports.
ENV DOCKER_EXPORT /home/shiny/log /home/shiny/srv /home/shiny/R
VOLUME /export

EXPOSE 3838

# Set the entrypoint, which performs some common configuration steps
# before yielding to CMD.
ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]

CMD ["/usr/bin/sudo", "-u", "shiny", "/usr/bin/shiny-server"]
