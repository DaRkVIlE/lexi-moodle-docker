FROM bitnamilegacy/moodle:5.0.2-debian-12-r2

USER root

# Inspect the exact code that runs Moodle install script!
RUN grep -n -C 15 "Running Moodle install script" /opt/bitnami/scripts/libmoodle.sh

RUN mkdir -p /bitnami/apache/conf \
             /bitnami/apache/logs \
             /bitnami/apache/run \
             /bitnami/moodledata && \
    chown -R 1001:root /bitnami/apache /bitnami/moodledata && \
    chmod -R g+rwX /bitnami/apache /bitnami/moodledata

USER 1001
