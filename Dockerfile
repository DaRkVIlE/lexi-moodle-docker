FROM bitnamilegacy/moodle:5.0.2-debian-12-r2

USER root

# Inspect moodle_install definition
RUN grep -n -A 35 "moodle_install()" /opt/bitnami/scripts/libmoodle.sh && false
