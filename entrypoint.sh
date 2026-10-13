#!/bin/bash
set -e

echo "==> [Ponytail] Fixing volume ownership and permissions..."
mkdir -p /bitnami/moodle /bitnami/moodledata /bitnami/apache/conf /bitnami/apache/logs /bitnami/apache/run
chown -R 1001:root /bitnami /opt/bitnami 2>/dev/null || true
chmod -R 775 /bitnami /opt/bitnami 2>/dev/null || true
chmod 777 /bitnami/moodledata 2>/dev/null || true

# If webservice or core files are missing in volume, hydrate from /opt/moodle-source
if [ -d "/opt/moodle-source" ]; then
    echo "==> [Ponytail] Hydrating Moodle core files into volume..."
    cp -rn /opt/moodle-source/* /bitnami/moodle/ 2>/dev/null || true
fi

# Ensure /opt/bitnami/moodle points to /bitnami/moodle
if [ ! -L "/opt/bitnami/moodle" ]; then
    rm -rf /opt/bitnami/moodle
    ln -sf /bitnami/moodle /opt/bitnami/moodle
fi

# Generate config.php if missing
if [ ! -f "/bitnami/moodle/config.php" ]; then
    echo "==> [Ponytail] Generating clean production config.php..."
    DB_HOST="${MOODLE_DATABASE_HOST:-mysql.railway.internal}"
    DB_USER="${MOODLE_DATABASE_USER:-root}"
    DB_PASS="${MOODLE_DATABASE_PASSWORD:-YLUKVkxVWkPDoikUTTKYNIjlEURScvrR}"
    DB_NAME="${MOODLE_DATABASE_NAME:-railway}"
    DB_PORT="${MOODLE_DATABASE_PORT_NUMBER:-3306}"
    SITE_URL="${MOODLE_SITE_URL:-https://moodle-production-412a.up.railway.app}"

    cat << EOF > /bitnami/moodle/config.php
<?php
unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();

\$CFG->dbtype    = 'mysqli';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = '${DB_HOST}';
\$CFG->dbname    = '${DB_NAME}';
\$CFG->dbuser    = '${DB_USER}';
\$CFG->dbpass    = '${DB_PASS}';
\$CFG->prefix    = 'mdl_';
\$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => ${DB_PORT},
  'dbsocket' => '',
  'dbcollation' => 'utf8mb4_unicode_ci',
);

\$CFG->wwwroot   = '${SITE_URL}';
\$CFG->dataroot  = '/bitnami/moodledata';
\$CFG->admin     = 'admin';

\$CFG->directorypermissions = 0777;
\$CFG->sslproxy  = true;
\$CFG->reverseproxy = false;
\$CFG->enablewebservices = 1;
\$CFG->webserviceprotocols = 'rest';

require_once(__DIR__ . '/lib/setup.php');
EOF
fi

chmod 664 /bitnami/moodle/config.php 2>/dev/null || true
chown 1001:root /bitnami/moodle/config.php 2>/dev/null || true

echo "==> [Ponytail] Verified Moodle config:"
grep -E "(reverseproxy|sslproxy|wwwroot|enablewebservices|dbhost)" /bitnami/moodle/config.php 2>/dev/null || true

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
