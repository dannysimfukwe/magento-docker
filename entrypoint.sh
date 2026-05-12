#!/bin/bash
set -e

echo "=== Magento Custom Entrypoint ==="

# Download Magento files if not present
if [ ! -d "/var/www/html/bin" ] || [ ! -f "/var/www/html/composer.json" ]; then
    echo "Downloading Magento files..."
    /usr/local/bin/docker-php-entrypoint setup
    sleep 10
fi

# Check if Magento is installed
if [ -f "/var/www/html/app/etc/env.php" ]; then
    echo "Magento already installed"
else
    echo "Installing Magento..."

    # Create env.php manually if DB env vars are provided
    if [ -n "$MAGENTO_DB_HOST" ]; then
        mkdir -p /var/www/html/app/etc

        # Generate encryption key
        CRYPT_KEY=$(head -c 32 /dev/urandom | base64 | tr -d '\n')

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

        # Run Magento setup:install if base URL is provided
        if [ -n "$MAGENTO_BASE_URL" ]; then
            cd /var/www/html
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
                2>&1 || echo "Setup completed or already configured"
        fi
    fi
fi

echo "=== Starting nginx and PHP-FPM ==="

# Start nginx in background
nginx &

# Start PHP-FPM (this will keep the container running)
exec /usr/local/bin/docker-php-entrypoint "$@"