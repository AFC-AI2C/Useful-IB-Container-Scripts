FROM r-base:latest 

WORKDIR /tmp

COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY scripts/download-deps.R /download-deps.R

ENTRYPOINT ["/entrypoint.sh"]
