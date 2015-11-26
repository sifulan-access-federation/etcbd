FROM debian:jessie

# make debconf use non-interactive mode:
ENV DEBIAN_FRONTEND=noninteractive

# Add backports (as later requested by Icinga instructions)
# Install wget as dependency - pulls in openssl + ca-certificates
RUN echo 'deb http://http.debian.net/debian jessie-backports main' > /etc/apt/sources.list.d/backports.list && \
    apt-get update && apt-get -y install apt-utils && apt-get -y install wget

# install Icinga - release build for Jessie
    #add & trust Icinga repository & fetch package lists
    # install icinga itself
    # and monitoring plugins (formerly nagios plugins)
    # and ido-psql + psql client
RUN echo "deb http://packages.icinga.org/debian icinga-jessie main" > /etc/apt/sources.list.d/icinga.list && \
    wget -O - -q https://packages.icinga.org/icinga.key | apt-key add - && \
    apt-get update && \
    apt-get -y install --no-install-recommends icinga2 && \
    apt-get -y install --no-install-recommends monitoring-plugins && \
    apt-get -y install --no-install-recommends icinga2-ido-pgsql postgresql-client


# temporary: install utils
RUN apt-get -y install --no-install-recommends strace lsof vim less file

# copy configuration customized for our DB connection
# TODO: parameterize this
COPY content/ido-pgsql.conf content/command.conf /etc/icinga2/features-available/

# prepare Icinga environment
  # /run/icinga2 must exist and be writable by nagios - the daemon stores the pid here
  # fix permissions on ido-pgsql.conf copied above
  # enable ido-pgsql and command modules
RUN mkdir /run/icinga2 && chown nagios.nagios /run/icinga2 && \
    #chown nagios.nagios /etc/icinga2/features-available/ido-pgsql.conf && \
    icinga2 feature enable ido-pgsql && \
    icinga2 feature enable command

CMD ["/usr/sbin/icinga2", "daemon"]

