#!/bin/bash
set -e

echo "==> [Ponytail] Fixing volume ownership and permissions..."
chown -R 1001:root /bitnami /opt/bitnami 2>/dev/null || true
chmod -R 775 /bitnami /opt/bitnami 2>/dev/null || true

# If webservice or core files are missing in volume, hydrate from /opt/moodle-source
if [ -d "/opt/moodle-source" ]; then
    echo "==> [Ponytail] Hydrating missing Moodle core files into volume..."
    cp -rn /opt/moodle-source/* /bitnami/moodle/ 2>/dev/null || true
    chown -R 1001:root /bitnami /opt/bitnami 2>/dev/null || true
fi

# Ensure /opt/bitnami/moodle points to /bitnami/moodle
if [ ! -L "/opt/bitnami/moodle" ] && [ -d "/bitnami/moodle" ]; then
    rm -rf /opt/bitnami/moodle
    ln -sf /bitnami/moodle /opt/bitnami/moodle
fi

# Sanitize config.php
for cfg in "/bitnami/moodle/config.php" "/opt/bitnami/moodle/config.php"; do
    if [ -f "$cfg" ]; then
        chmod 664 "$cfg" 2>/dev/null || true
        sed -i "s/\$CFG->reverseproxy[[:space:]]*=[[:space:]]*true;/\$CFG->reverseproxy = false;/g" "$cfg" 2>/dev/null || true
        sed -i "s/\$CFG->reverseproxy[[:space:]]*=[[:space:]]*1;/\$CFG->reverseproxy = false;/g" "$cfg" 2>/dev/null || true
        if ! grep -q "sslproxy" "$cfg"; then
            sed -i "/\$CFG->wwwroot/a \$CFG->sslproxy = true;" "$cfg" 2>/dev/null || true
        fi
        if ! grep -q "enablewebservices" "$cfg"; then
            sed -i "/\$CFG->wwwroot/a \$CFG->enablewebservices = 1;\n\$CFG->webserviceprotocols = 'rest';" "$cfg" 2>/dev/null || true
        fi
    fi
done

echo "==> [Ponytail] Verified Moodle config:"
grep -E "(reverseproxy|sslproxy|wwwroot|enablewebservices)" /bitnami/moodle/config.php 2>/dev/null || true

# Ensure Apache SSL certs exist
mkdir -p /opt/bitnami/apache/conf/bitnami/certs
if [ ! -f "/opt/bitnami/apache/conf/bitnami/certs/tls.crt" ]; then
    echo "==> [Ponytail] Generating self-signed certs for Apache..."
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
        -keyout /opt/bitnami/apache/conf/bitnami/certs/tls.key \
        -out /opt/bitnami/apache/conf/bitnami/certs/tls.crt \
        -subj "/CN=localhost" 2>/dev/null || true
    cp -a /opt/bitnami/apache/conf/bitnami/certs/tls.crt /opt/bitnami/apache/conf/bitnami/certs/server.crt 2>/dev/null || true
    cp -a /opt/bitnami/apache/conf/bitnami/certs/tls.key /opt/bitnami/apache/conf/bitnami/certs/server.key 2>/dev/null || true
fi
chown -R 1001:root /opt/bitnami/apache/conf/bitnami/certs 2>/dev/null || true

echo "==> [Ponytail] Starting Apache as user 1001..."
if command -v runuser >/dev/null 2>&1; then
    exec runuser -u moodleuser -- /opt/bitnami/scripts/apache/run.sh
elif command -v gosu >/dev/null 2>&1; then
    exec gosu 1001 /opt/bitnami/scripts/apache/run.sh
else
    exec su -s /bin/bash moodleuser -c "/opt/bitnami/scripts/apache/run.sh"
fi
