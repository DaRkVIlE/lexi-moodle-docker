FROM bitnamilegacy/moodle:5.0.2-debian-12-r2

USER root

# Save clean copy of Moodle source so entrypoint can hydrate the persistent volume
RUN cp -a /opt/bitnami/moodle /opt/moodle-source

# Ensure user 1001 exists in /etc/passwd so runuser/su can switch users
RUN id -u 1001 >/dev/null 2>&1 || useradd -u 1001 -g 0 -m -s /bin/bash moodleuser

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
