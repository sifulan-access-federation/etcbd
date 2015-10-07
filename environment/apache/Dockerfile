FROM httpd:2.4
COPY ./*-httpd.conf /usr/local/apache2/conf/extra/
RUN echo 'Include conf/extra/modules-httpd.conf' >> /usr/local/apache2/conf/httpd.conf && \
    echo 'Include conf/extra/djnro-httpd.conf' >> /usr/local/apache2/conf/httpd.conf
