FROM docker.elastic.co/kibana/kibana-oss:6.3.0

# install envPlate
RUN curl -sLo /usr/share/kibana/bin/ep https://github.com/kreuzwerker/envplate/releases/download/v0.0.8/ep-linux && chmod +x /usr/share/kibana/bin/ep

COPY --chown=kibana:kibana content /
CMD ["/usr/share/kibana/bin/ep", "-v","/visualization/VisitorsExclDomestic.json","--","/usr/local/bin/kibana-docker"]
