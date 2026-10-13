#!/bin/bash
set -e

# Ponytail efficiency fix:
# If Moodle is already installed (config.php exists), skip the Bitnami re-installer
# which crashes because config.php already exists, and start Apache directly!
if [ -f "/bitnami/moodle/config.php" ] || [ -f "/opt/bitnami/moodle/config.php" ]; then
    echo "==> [Ponytail] Moodle already initialized with config.php."
    if [ -f "/bitnami/moodle/config.php" ] && [ ! -f "/opt/bitnami/moodle/config.php" ]; then
        ln -sf /bitnami/moodle/config.php /opt/bitnami/moodle/config.php
    fi
    if [ -f "/opt/bitnami/moodle/config.php" ] && [ ! -f "/bitnami/moodle/config.php" ]; then
        cp -a /opt/bitnami/moodle/config.php /bitnami/moodle/config.php 2>/dev/null || true
    fi
    echo "==> [Ponytail] Starting Apache web server directly..."
    exec /opt/bitnami/scripts/apache/run.sh
fi

echo "==> [Ponytail] Fresh install: running Bitnami setup..."
exec /opt/bitnami/scripts/moodle/entrypoint.sh /opt/bitnami/scripts/moodle/run.sh
