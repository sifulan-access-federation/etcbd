FROM httpd:2.4

# make debconf use non-interactive mode:
ENV DEBIAN_FRONTEND=noninteractive

# Install openssl - needed for auto-creating certificates
# (and pull in dependencies needed for configuring packages)
# Install locales needed to run localedef later
# Clean up apt temporary files
RUN apt-get update && \
    apt-get -y install apt-utils && \
    apt-get -y install openssl ca-certificates && \
    apt-get -y install --no-install-recommends locales && \
    # temporary: install utils
    apt-get -y install --no-install-recommends lsof vim less file && \
    rm -rf /var/lib/apt/lists/*

# temporary: install utils
RUN apt-get -y install --no-install-recommends lsof vim less file

# override httpd-foreground with our version looking into /usr/local/apache2/conf/startup.d
COPY httpd-foreground /usr/local/bin/

COPY envwrap.sh /

RUN mkdir /usr/local/apache2/conf/startup.d
COPY make-selfsigned-certs-if-none-present.sh localedef.sh create-htauth-file.sh /usr/local/apache2/conf/startup.d/

COPY ./*-httpd.conf /usr/local/apache2/conf/extra/
RUN echo 'Include conf/extra/modules-httpd.conf' >> /usr/local/apache2/conf/httpd.conf && \
    echo 'Include conf/extra/apache-global-httpd.conf' >> /usr/local/apache2/conf/httpd.conf && \
    echo 'Include conf/extra/nonssl-httpd.conf' >> /usr/local/apache2/conf/httpd.conf && \
    echo 'Include conf/extra/ssl-httpd.conf' >> /usr/local/apache2/conf/httpd.conf

# override CMD to wrap httpd-foreground
CMD ["/envwrap.sh", "httpd-foreground"]
