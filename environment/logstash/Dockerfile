FROM logstash:2.3
EXPOSE 5043

COPY logstash-conf-* /etc/logstash/conf.d/

CMD ["logstash", "agent", "-f", "/etc/logstash/conf.d/"]
