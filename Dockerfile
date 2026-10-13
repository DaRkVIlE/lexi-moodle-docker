FROM bitnamilegacy/moodle:5.0.2-debian-12-r2

USER root

# Inspect is_app_initialized definition
RUN grep -n -A 20 "is_app_initialized()" /opt/bitnami/scripts/lib*.sh && false
