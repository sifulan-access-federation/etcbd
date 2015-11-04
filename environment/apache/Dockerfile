FROM httpd:2.4

# make debconf use non-interactive mode:
ENV DEBIAN_FRONTEND=noninteractive

# install openssl - needed for auto-creating certificates
# (and pull in dependencies needed for configuring packages)
RUN apt-get update && apt-get -y install apt-utils && apt-get -y install openssl ca-certificates

# override httpd-foreground with our version looking into /usr/local/apache2/conf/startup.d
COPY httpd-foreground /usr/local/bin/

RUN mkdir /usr/local/apache2/conf/startup.d
COPY make-selfsigned-certs-if-none-present.sh /usr/local/apache2/conf/startup.d/

COPY ./*-httpd.conf /usr/local/apache2/conf/extra/
RUN echo 'Include conf/extra/modules-httpd.conf' >> /usr/local/apache2/conf/httpd.conf && \
    echo 'Include conf/extra/djnro-httpd.conf' >> /usr/local/apache2/conf/httpd.conf && \
    echo 'Include conf/extra/djnro-ssl-httpd.conf' >> /usr/local/apache2/conf/httpd.conf
