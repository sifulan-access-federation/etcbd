FROM logstash:2.3
EXPOSE 5043

# install envPlate
RUN curl -sLo /usr/local/bin/ep https://github.com/kreuzwerker/envplate/releases/download/v0.0.8/ep-linux && chmod +x /usr/local/bin/ep

COPY logstash-conf-* /etc/logstash/conf.d/

CMD ["/usr/local/bin/ep", "-v", "/etc/logstash/conf.d/logstash-conf-20-grok-filter.conf", "--", "/opt/logstash/bin/logstash", "agent", "-f", "/etc/logstash/conf.d/"]
