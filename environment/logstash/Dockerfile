FROM logstash:2.0
COPY logstash-conf-* /etc/logstash/conf.d/
EXPOSE 5043

CMD ["logstash", "agent", "-f", "/etc/logstash/conf.d/"]
