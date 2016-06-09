FROM kibana:4.5

# Install curl (also needed for import_dashboard,sh)
# Install ca-certificates (first install apt-utils)
# Clean up apt temporary files
RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y ca-certificates curl --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# install envPlate
RUN curl -sLo /usr/local/bin/ep https://github.com/kreuzwerker/envplate/releases/download/v0.0.8/ep-linux && chmod +x /usr/local/bin/ep

COPY content /
COPY kibana.yml /opt/kibana/config/kibana.yml
CMD ["/usr/local/bin/ep", "-v","/visualization/VisitorsExclDomestic.json","--","/opt/kibana/bin/kibana"]
