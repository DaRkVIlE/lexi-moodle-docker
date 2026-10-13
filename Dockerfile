FROM bitnamilegacy/moodle:5.0.2-debian-12-r2

USER root

# Intentionally fail so BuildKit prints the output of grep to build logs!
RUN grep -n -C 20 "Running Moodle install script" /opt/bitnami/scripts/libmoodle.sh && false
