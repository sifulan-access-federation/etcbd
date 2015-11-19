FROM debian:jessie

ENV FILEBEAT_VERSION=1.0.0-rc2

# make debconf use non-interactive mode:
ENV DEBIAN_FRONTEND=noninteractive

# install curl & ca-certificates (first install apt-utils)
RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y ca-certificates curl --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L -O https://download.elastic.co/beats/filebeat/filebeat_${FILEBEAT_VERSION}_amd64.deb && \
    dpkg -i filebeat_${FILEBEAT_VERSION}_amd64.deb

COPY filebeat.yml /etc/filebeat/filebeat.yml

CMD ["filebeat", "-e", "-v", "-c", "/etc/filebeat/filebeat.yml"]

