FROM debian:stretch

# make debconf use non-interactive mode:
ENV DEBIAN_FRONTEND=noninteractive

# Install wget as dependency - pulls in openssl + ca-certificates
# Install also curl - used by some install commands
# Install also gnupg - needed later to add Icinga repo key
# Install also python - needed for some python scripts (at least the one to send email notifications)
# Install locales needed to run localedef later
RUN apt-get update && apt-get -y install apt-utils && apt-get -y install wget curl gnupg python && \
    apt-get -y install --no-install-recommends locales && \
    # remove the package lists - we will be anyway refetching in the next step
    rm -rf /var/lib/apt/lists/*

# install Icinga - release build for Stretch
    #add & trust Icinga repository & fetch package lists
    # install icinga itself
    # and monitoring plugins (formerly nagios plugins)
    # and ido-psql + psql client
RUN echo "deb http://packages.icinga.com/debian icinga-stretch main" > /etc/apt/sources.list.d/icinga.list && \
    wget --no-check-certificate -O - -q https://packages.icinga.com/icinga.key | apt-key add - && \
    apt-get update && \
    apt-get -y install --no-install-recommends icinga2 && \
    apt-get -y install --no-install-recommends monitoring-plugins && \
    apt-get -y install --no-install-recommends icinga2-ido-pgsql postgresql-client
    # keep the package files here - we are anyway reusing them in a number of subsequent run commands

# temporary: install utils
RUN apt-get -y install --no-install-recommends lsof vim less file

# Install rad_eap_test and eapol_test
#  * First install prerequisites: bzip2, dnsutils
#  *   and also freeradius-utils used by check_radius.pl for status checking
#  * Download and extract rad_eap_test
#  * Install compile requirements for wpa_supplicant to build eapol_test
#  * Configure and build eapol_test
#  * Install rad_eap_test and eapol_test into /usr/local/bin
#  * Clean up: remove compile dependencies
#  * Clean up: remove build directories
ENV RAD_EAP_TEST_VERSION=0.26 WPA_SUPPLICANT_VERSION=2.6
RUN apt-get install -y --no-install-recommends dnsutils bzip2 \
        freeradius-utils && \
#    wget --quiet -O - http://www.eduroam.cz/rad_eap_test/rad_eap_test-${RAD_EAP_TEST_VERSION}.tar.bz2 | \
#        tar xjf - --strip-components=1 -C /usr/local/bin/ rad_eap_test-${RAD_EAP_TEST_VERSION}/rad_eap_test && \
    apt-get install -y --no-install-recommends make gcc libc-dev libssl-dev && \
    ( cd /tmp && \
      wget --quiet -O - http://w1.fi/releases/wpa_supplicant-${WPA_SUPPLICANT_VERSION}.tar.gz | tar xzf - && \
      cd wpa_supplicant-${WPA_SUPPLICANT_VERSION}/wpa_supplicant/ && \
      { grep '^[^#].*EAP' defconfig ; echo 'CONFIG_EAPOL_TEST=y' ; } > .config && \
      make eapol_test && \
      cp eapol_test /usr/local/bin/ \
    ) && \
    apt-get remove -y make gcc libc6-dev libssl-dev && \
    apt-get autoremove -y && \
    rm -rf /tmp/wpa_supplicant-${WPA_SUPPLICANT_VERSION}

# install envPlate
RUN curl -sLo /usr/local/bin/ep https://github.com/kreuzwerker/envplate/releases/download/v0.0.8/ep-linux && chmod +x /usr/local/bin/ep

# copy configuration files in
#   etc/icinga2/features-available/ido-pgsql.conf, command.conf
#       TODO??: accept custom DB connection parameters in ido-pgsql.conf
COPY content /

# prepare Icinga environment
  # /run/icinga2 must exist and be writable by nagios - the daemon stores the pid here
  # fix permissions on ido-pgsql.conf copied above
  # enable ido-pgsql and command modules
RUN mkdir /run/icinga2 && chown nagios.nagios /run/icinga2 && \
    #chown nagios.nagios /etc/icinga2/features-available/ido-pgsql.conf && \
    icinga2 feature enable ido-pgsql && \
    icinga2 feature enable command && \
    # Make ping set-uid to work under non-root nagios user account
    chmod u+s /bin/ping && \
    # fix location of eapol_test in rad_eap_test - only available after copying in content/
    sed --in-place -e 's/^EAPOL_PROG.*$/EAPOL_PROG=eapol_test/' /usr/local/bin/rad_eap_test

VOLUME ["/var/run/icinga2", "/var/lib/icinga2", "/var/log/icinga2", "/etc/icinga2/externalconf"]

CMD ["/startup.sh", "/run-icinga.sh", "/usr/sbin/icinga2", "daemon", "-d"]

