FROM bitnamilegacy/moodle:5.0.2-debian-12-r2

USER root

RUN mkdir -p /bitnami/apache/conf \
             /bitnami/apache/logs \
             /bitnami/apache/run \
             /bitnami/moodledata && \
    chown -R 1001:root /bitnami/apache /bitnami/moodledata && \
    chmod -R g+rwX /bitnami/apache /bitnami/moodledata

# Trace every bash command in entrypoint and setup to see exact failure
RUN sed -i '2i set -x' /opt/bitnami/scripts/moodle/entrypoint.sh && \
    sed -i '2i set -x' /opt/bitnami/scripts/moodle/setup.sh

USER 1001
