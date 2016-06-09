FROM kibana:4.5

# Install curl (also needed for import_dashboard,sh)
# Install ca-certificates (first install apt-utils)
# Clean up apt temporary files
RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y ca-certificates curl --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

COPY content /
COPY kibana.yml /opt/kibana/config/kibana.yml
CMD ["kibana"]
