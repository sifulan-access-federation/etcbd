FROM debian:stretch

# make debconf use non-interactive mode:
ENV DEBIAN_FRONTEND=noninteractive

# Install wget as dependency - pulls in openssl + ca-certificates
# Install also curl - used by some install commands
# Install locales needed to run localedef later
RUN apt-get update && apt-get -y install apt-utils && apt-get -y install wget curl && \
    apt-get -y install --no-install-recommends locales && \
    # remove the package lists - we will be anyway refetching in the next step
    rm -rf /var/lib/apt/lists/*

# install Icingaweb - release build for Stretch
# This will pull in Apache as a dependency
# Therefore, we are building from Stretch, not from httpd:2.4
    #add & trust Icinga repository & fetch packages
    # install incingaweb2 and the monitoring module communicating with icinga
    # install PHP modules (DB, Intl)
RUN echo "deb http://packages.icinga.org/debian icinga-stretch main" > /etc/apt/sources.list.d/icinga.list && \
    wget -O - -q https://packages.icinga.org/icinga.key | apt-key add - && \
    apt-get update && \
    apt-get -y install --no-install-recommends icingaweb2 icingaweb2-module-monitoring && \
    apt-get -y install --no-install-recommends php5-pgsql php5-imagick php5-intl && \
    # temporary: install utils
    apt-get -y install --no-install-recommends lsof vim less file && \
    # remove the package lists
    rm -rf /var/lib/apt/lists/*

# Enable SSL in Apache
RUN a2enmod ssl && a2ensite default-ssl

# install envPlate
RUN curl -sLo /usr/local/bin/ep https://github.com/kreuzwerker/envplate/releases/download/v0.0.8/ep-linux && chmod +x /usr/local/bin/ep

# copy in icingaweb2 configuration - pointing to separate icinga and postgres containers
# also copy in startup.sh + etc/startup.d files
COPY content /

# tweak Apache configuration for Icinga
#  make PHP timezone configurable at container deploy time via envPlate
#  ... and stop envPlate from complaining about sample variable use in php.ini
#  fix permissions on files just copied in
#  create logs directory with the right permission
#  enable additional Apache configuration
RUN sed -i -e "s:;date.timezone =:date.timezone = '\${TZ}':" /etc/php5/apache2/php.ini && \
    sed -i -e 's:\${foo}:<dollar>{foo}:' /etc/php5/apache2/php.ini && \
    chgrp -R icingaweb2 /etc/icingaweb2 && \
    chmod -R g+rwxs /etc/icingaweb2 && \
    #chmod -R a+r /etc/icingaweb2 && \
    mkdir /var/log/icingaweb2 && chgrp icingaweb2 /var/log/icingaweb2 && chmod g+rwxs /var/log/icingaweb2 && \
    a2enconf globaldefs

# tweak apache2ctl to run httpd in the foreground as pid 1
ENV APACHE_ARGUMENTS="-DFOREGROUND" APACHE_HTTPD="exec apache2"

EXPOSE 80 443

VOLUME ["/var/log/apache2", "/var/log/icingaweb2", "/etc/apache2/certs"]

CMD ["/startup.sh", "apache2ctl", "start"]

