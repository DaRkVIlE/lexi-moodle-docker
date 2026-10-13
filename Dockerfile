FROM bitnamilegacy/moodle:5.0.2-debian-12-r2

USER root

RUN mkdir -p /bitnami/apache/conf \
             /bitnami/apache/logs \
             /bitnami/apache/run \
             /bitnami/moodledata \
             /bitnami/moodle && \
    chown -R 1001:root /bitnami && \
    chmod -R 777 /bitnami

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER 1001

ENTRYPOINT ["/entrypoint.sh"]
