FROM debian:jessie

# make debconf use non-interactive mode:
ENV DEBIAN_FRONTEND=noninteractive

# Add backports (as later requested by Icinga instructions)
# Install wget as dependency - pulls in openssl + ca-certificates
RUN echo 'deb http://http.debian.net/debian jessie-backports main' > /etc/apt/sources.list.d/backports.list && \
    apt-get update && apt-get -y install apt-utils && apt-get -y install wget

# install Icingaweb - release build for Jessie
# This will pull in Apache as a dependency
# Therefore, we are building from Jessie, not from httpd:2.4
    #add & trust Icinga repository & fetch packages
RUN echo "deb http://packages.icinga.org/debian icinga-jessie main" > /etc/apt/sources.list.d/icinga.list && \
    wget -O - -q https://packages.icinga.org/icinga.key | apt-key add - && \
    apt-get update && \
    apt-get -y install --no-install-recommends icingaweb2

# temporary: install utils
RUN apt-get -y install --no-install-recommends strace lsof vim less file


# tweak apache2ctl to run httpd in the foreground as pid 1
ENV APACHE_ARGUMENTS="-DFOREGROUND" APACHE_HTTPD="exec apache2"

CMD ["apache2ctl", "start"]

