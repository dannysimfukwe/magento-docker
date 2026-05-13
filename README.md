# Magento Docker for 42helv

## Quick Start (Bitnami Image)

This template uses the **Bitnami Magento** image which comes pre-installed and configured.

### Prerequisites

1. **Elasticsearch** - Required for Magento 2.4+ catalog search

```bash
# Deploy Elasticsearch as system service (auto-restart on reboot)
docker run -d \
  --name elasticsearch \
  --network 42helv-net \
  -p 9200:9200 \
  -e "discovery.type=single-node" \
  -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
  --restart=always \
  bitnami/elasticsearch:7
```

### Configuration

The Bitnami image handles most configuration automatically via environment variables:

| Variable | Description | Default |
|---------|-------------|---------|
| `MAGENTO_HOST` | Your domain | - |
| `MAGENTO_USERNAME` | Admin username | admin |
| `MAGENTO_PASSWORD` | Admin password | - |
| `MARIADB_HOST` | Database container | - |
| `ELASTICSEARCH_HOST` | Search server | - |

### Deploy

The 42helv system automatically handles:
- Container networking
- Traefik routing
- SSL certificates
- Auto-restart on server reboot

## Troubleshooting

### 502 Bad Gateway
If you get 502 errors, check the container logs:
```bash
docker logs <container-name>
```

### Database Connection Issues
Ensure MariaDB is running and accessible:
```bash
docker exec magento ping mariadb
```

### First Run Setup
On first deployment, Magento may take 2-5 minutes to initialize. Check logs:
```bash
docker logs -f magento
```

## Access

After deployment:
- Frontend: `https://your-site.42helv.com`
- Admin: `https://your-site.42helv.com/admin`