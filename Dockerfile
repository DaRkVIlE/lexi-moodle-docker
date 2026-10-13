FROM bitnamilegacy/moodle:4.5.4-debian-12-r4

# Railway-compatibility fixes for Bitnami Moodle:
# 1. The entrypoint realpath-checks /bitnami/apache/conf — pre-create so it
#    exists even on a fresh volume mount (the volume overlays /bitnami/moodle,
#    NOT /bitnami/apache, so this dir is safe to bake in).
# 2. Ensure the moodledata directory exists for Moodle's file storage.
USER root

RUN mkdir -p /bitnami/apache/conf \
             /bitnami/apache/logs \
             /bitnami/apache/run \
             /bitnami/moodledata && \
    chown -R 1001:root /bitnami/apache /bitnami/moodledata && \
    chmod -R g+rwX /bitnami/apache /bitnami/moodledata

USER 1001
