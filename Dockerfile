FROM bitnamilegacy/moodle:5.0.2-debian-12-r2

USER root

RUN mkdir -p /bitnami/apache/conf \
             /bitnami/apache/logs \
             /bitnami/apache/run \
             /bitnami/moodledata && \
    chown -R 1001:root /bitnami/apache /bitnami/moodledata && \
    chmod -R g+rwX /bitnami/apache /bitnami/moodledata

USER 1001
