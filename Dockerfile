FROM bitnamilegacy/moodle:5.0.2-debian-12-r2

USER root

# Inspect moodle_initialize definition
RUN grep -n -A 40 "moodle_initialize()" /opt/bitnami/scripts/libmoodle.sh && false
