FROM bitnamilegacy/moodle:5.0.2-debian-12-r2

USER root

# Save clean copy of Moodle source so entrypoint can hydrate the persistent volume
RUN cp -a /opt/bitnami/moodle /opt/moodle-source

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
