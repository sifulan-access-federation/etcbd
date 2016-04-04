FROM debian:jessie

ENV FILEBEAT_VERSION=1.2.0

# make debconf use non-interactive mode:
ENV DEBIAN_FRONTEND=noninteractive

# install curl & ca-certificates (first install apt-utils)
RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y ca-certificates curl --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# install envPlate
RUN curl -sLo /usr/local/bin/ep https://github.com/kreuzwerker/envplate/releases/download/v0.0.8/ep-linux && chmod +x /usr/local/bin/ep

RUN curl -sLO https://download.elastic.co/beats/filebeat/filebeat_${FILEBEAT_VERSION}_amd64.deb && \
    dpkg -i filebeat_${FILEBEAT_VERSION}_amd64.deb && \
    rm -f filebeat_${FILEBEAT_VERSION}_amd64.deb

COPY filebeat.yml /etc/filebeat/filebeat.yml

VOLUME /var/lib/filebeat

CMD ["/usr/local/bin/ep", "-v", "/etc/filebeat/filebeat.yml", "--", "/usr/bin/filebeat", "-e", "-v", "-c", "/etc/filebeat/filebeat.yml"]

