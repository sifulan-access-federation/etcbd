FROM docker.elastic.co/logstash/logstash-oss:6.3.1
EXPOSE 5043

# install envPlate
RUN curl -sLo /usr/share/logstash/bin/ep https://github.com/kreuzwerker/envplate/releases/download/v0.0.8/ep-linux && chmod +x /usr/share/logstash/bin/ep

COPY --chown=logstash:logstash logstash-conf-* /etc/logstash/conf.d/

CMD ["/usr/share/logstash/bin/ep", "-v", "/etc/logstash/conf.d/logstash-conf-20-grok-filter.conf", "/etc/logstash/conf.d/logstash-conf-30-elasticsearch-output.conf", "--", "/usr/share/logstash/bin/logstash", "-f", "/etc/logstash/conf.d/"]
