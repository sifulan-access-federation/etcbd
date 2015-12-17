FROM debian:jessie

# make debconf use non-interactive mode:
ENV DEBIAN_FRONTEND=noninteractive

# Add backports (as later requested by Icinga instructions)
# Install wget as dependency - pulls in openssl + ca-certificates
# Install also curl - used by some install commands
# Install locales needed to run localedef later
RUN echo 'deb http://http.debian.net/debian jessie-backports main' > /etc/apt/sources.list.d/backports.list && \
    apt-get update && apt-get -y install apt-utils && apt-get -y install wget curl && \
    apt-get -y install --no-install-recommends locales

# install Icingaweb - release build for Jessie
# This will pull in Apache as a dependency
# Therefore, we are building from Jessie, not from httpd:2.4
    #add & trust Icinga repository & fetch packages
    # install incingaweb2 and the monitoring module communicating with icinga
    # install PHP modules (DB, Intl)
RUN echo "deb http://packages.icinga.org/debian icinga-jessie main" > /etc/apt/sources.list.d/icinga.list && \
    wget -O - -q https://packages.icinga.org/icinga.key | apt-key add - && \
    apt-get update && \
    apt-get -y install --no-install-recommends icingaweb2 icingaweb2-module-monitoring && \
    apt-get -y install --no-install-recommends php5-pgsql php5-imagick php5-intl

# temporary: install utils
RUN apt-get -y install --no-install-recommends strace lsof vim less file

# Enable SSL in Apache
# Temporary workaround: install make-ssl-certs
RUN a2enmod ssl && \
    a2ensite default-ssl && \
    apt-get install -y ssl-cert

# install envPlate
RUN curl -sLo /usr/local/bin/ep https://github.com/kreuzwerker/envplate/releases/download/v0.0.8/ep-linux && chmod +x /usr/local/bin/ep

# copy in icingaweb2 configuration - pointing to separate icinga and postgres containers
# also copy in startup.sh + etc/startup.d files
COPY content /

# tweak Apache configuration for Icinga
#  TODO: make the timezone configurable at container deploy time
#  fix permissions on files just copied in
#  create logs directory with the right permission
#  enable additional Apache configuration
RUN sed -i -e "s:;date.timezone =:date.timezone = 'Pacific/Auckland':" /etc/php5/apache2/php.ini && \
    chgrp -R icingaweb2 /etc/icingaweb2 && \
    chmod -R g+rwxs /etc/icingaweb2 && \
    #chmod -R a+r /etc/icingaweb2 && \
    mkdir /var/log/icingaweb2 && chgrp icingaweb2 /var/log/icingaweb2 && chmod g+rwxs /var/log/icingaweb2 && \
    a2enconf globaldefs

# tweak apache2ctl to run httpd in the foreground as pid 1
ENV APACHE_ARGUMENTS="-DFOREGROUND" APACHE_HTTPD="exec apache2"

EXPOSE 80 443

VOLUME ["/var/log/apache2", "/var/log/icingaweb2"]

CMD ["/startup.sh", "apache2ctl", "start"]

