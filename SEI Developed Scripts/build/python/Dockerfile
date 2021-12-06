ARG VERSION
FROM python:$VERSION

ENV PACKAGE=pip

WORKDIR /tmp

COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
