FROM debian:jessie

# make debconf use non-interactive mode:
ENV DEBIAN_FRONTEND=noninteractive

# Add backports (as later requested by Icinga instructions)
# Install wget as dependency - pulls in openssl + ca-certificates
RUN echo 'deb http://http.debian.net/debian jessie-backports main' > /etc/apt/sources.list.d/backports.list && \
    apt-get update && apt-get -y install apt-utils && apt-get -y install wget

# install Icinga - release build for Jessie
    #add & trust Icinga repository & fetch package lists
RUN echo "deb http://packages.icinga.org/debian icinga-jessie main" > /etc/apt/sources.list.d/icinga.list && \
    wget -O - -q https://packages.icinga.org/icinga.key | apt-key add - && \
    apt-get update && \
    apt-get -y install --no-install-recommends icinga2 && \
    apt-get -y install --no-install-recommends monitoring-plugins

# temporary: install utils
RUN apt-get -y install --no-install-recommends strace lsof vim less file

# prepare Icinga environment
RUN mkdir /run/icinga2 && chown nagios.nagios /run/icinga2

CMD ["/usr/sbin/icinga2", "daemon"]

