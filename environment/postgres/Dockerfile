FROM postgres:9.4
RUN localedef -i en_NZ -c -f UTF-8 -A /usr/share/locale/locale.alias en_NZ.UTF-8
ENV LANG en_NZ.utf8
COPY content /

# Override entrypoint
ENTRYPOINT ["/envwrap.sh", "/docker-entrypoint.sh"]

# Reiterate the command - gets dropped when overriding ENTRYPOINT
CMD ["postgres"]
