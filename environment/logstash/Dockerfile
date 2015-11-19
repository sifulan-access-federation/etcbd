FROM logstash:2.0
EXPOSE 5043

# update beats plugin from 0.9.2 to 0.9.6
RUN echo y | plugin update logstash-input-beats

COPY logstash-conf-* /etc/logstash/conf.d/

CMD ["logstash", "agent", "-f", "/etc/logstash/conf.d/"]
