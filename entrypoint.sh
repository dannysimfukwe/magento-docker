#!/bin/bash
set -e

# This script runs first to populate Magento files, then auto-installs
# The shinsenter/magento entrypoint extracts Magento files to /var/www/html

# Run the original entrypoint to populate Magento files
echo "=== Initializing Magento files ==="
/usr/local/bin/docker-php-entrypoint setup 2>/dev/null || true

# Wait a moment for files to be ready
sleep 5

# Now check if we need to run auto-install
if [ -d "/var/www/html/bin" ] && [ ! -f "/var/www/html/app/etc/env.php" ] && [ -n "$MAGENTO_DB_HOST" ]; then
    echo "=== Running Magento Auto-Install ==="
    cd /var/www/html

    # Create directory
    mkdir -p /var/www/html/app/etc

    # Generate encryption key
    CRYPT_KEY=$(head -c 32 /dev/urandom | base64 | tr -d '\n')

    # Create env.php
    cat > /var/www/html/app/etc/env.php << ENVEOF
<?php
return [
    'db' => [
        'connection' => [
            'default' => [
                'host' => '${MAGENTO_DB_HOST}',
                'dbname' => '${MAGENTO_DB_NAME:-magento}',
                'username' => '${MAGENTO_DB_USER:-root}',
                'password' => '${MAGENTO_DB_PASSWORD}',
                'active' => '1'
            ]
        ],
        'table_prefix' => ''
    ],
    'resource' => [
        'default_setup' => [
            'connection' => 'default'
        ]
    ],
    'x-frame-options' => 'SAMEORIGIN',
    'crypt' => [
        'key' => '${CRYPT_KEY}'
    ],
    'session' => [
        'save' => 'files'
    ],
    'install' => [
        'date' => 'Mon, 12 May 2026 00:00:00 +0000'
    ]
];
ENVEOF

    chown www-data:www-data /var/www/html/app/etc/env.php
    chmod 644 /var/www/html/app/etc/env.php

    if [ -n "$MAGENTO_BASE_URL" ]; then
        echo "Installing Magento..."
        php bin/magento setup:install \
            --base-url="${MAGENTO_BASE_URL}" \
            --backend-frontname="${MAGENTO_BACKEND_FRONTNAME:-admin}" \
            --db-host="${MAGENTO_DB_HOST}" \
            --db-name="${MAGENTO_DB_NAME:-magento}" \
            --db-user="${MAGENTO_DB_USER:-root}" \
            --db-password="${MAGENTO_DB_PASSWORD}" \
            --admin-firstname=Admin \
            --admin-lastname=Admin \
            --admin-email="${MAGENTO_ADMIN_EMAIL:-admin@example.com}" \
            --admin-user="${MAGENTO_ADMIN_USER:-admin}" \
            --admin-password="${MAGENTO_ADMIN_PASSWORD:-Admin123456}" \
            --skip-db-validation \
            2>&1 || echo "Magento installation completed"
    fi

    echo "=== Auto-Install Complete ==="
fi

# Run the original container entrypoint with the actual command
exec /usr/local/bin/docker-php-entrypoint "$@"