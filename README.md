# Magento Docker for 42helv

## Requirements

- OpenSearch (required for Magento 2.4+)

## OpenSearch Setup

Run OpenSearch as a persistent service on your server:

```bash
# Create and start OpenSearch container
docker run -d \
  --name opensearch \
  --network 42helv-net \
  -p 9200:9200 \
  -p 9600:9600 \
  -e "discovery.type=single-node" \
  -e "OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m" \
  --restart=always \
  opensearchproject/opensearch:2.0.0
```

## Environment Configuration

Update your Magento container's `app/etc/env.php` to use OpenSearch:

```php
<?php
return [
    'db' => [
        'connection' => [
            'default' => [
                'host' => 'site_39',  // Your database container
                'dbname' => 'mysql_l3cx',
                'username' => 'admin',
                'password' => 'your_password',
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
        'key' => 'your_encryption_key'
    ],
    'session' => [
        'save' => 'files'
    ],
    'install' => [
        'date' => 'Mon, 12 May 2026 00:00:00 +0000'
    ],
    'backend' => [
        'frontName' => 'admin'
    ],
    'queue' => [
        'consumers_wait_for_messages' => 0
    ],
    'system' => [
        'default' => [
            'catalog' => [
                'search' => [
                    'engine' => 'opensearch',
                    'opensearch_server' => 'opensearch',
                    'opensearch_port' => '9200'
                ]
            ]
        ]
    ]
];
```

## PHP-FPM Socket Permission Fix

If you encounter 502 Bad Gateway with permission errors, fix the PHP-FPM socket:

```bash
docker exec <magento-container> chmod 666 /run/php-fpm.sock
```

## Magento Setup Commands

After installation, run:

```bash
# Enable all modules
docker exec <magento-container> bin/magento module:enable --all

# Run setup upgrade
docker exec <magento-container> bin/magento setup:upgrade

# Compile DI
docker exec <magento-container> bin/magento setup:di:compile

# Clear cache
docker exec <magento-container> bin/magento cache:flush
```