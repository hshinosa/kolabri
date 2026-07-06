# Kolabri Production Deployment Guide

Panduan lengkap untuk deploy Kolabri ke VPS production environment.

## 📋 Prerequisites

### System Requirements
- **OS**: Ubuntu 20.04 LTS atau lebih baru (recommended)
- **RAM**: Minimal 4GB (8GB recommended)
- **Storage**: Minimal 20GB SSD
- **CPU**: 2 cores atau lebih
- **Domain**: Domain yang sudah diarahkan ke IP VPS

### Software Requirements
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version

# Log out and log back in to apply docker group changes
```

## 🚀 Initial Deployment

### 1. Clone Repository
```bash
cd /opt
git clone <your-repository-url> kolabri
cd kolabri
```

### 2. Configure Environment Files

#### AI Engine
```bash
cp Kolibri-ai-engine/.env.production.example Kolibri-ai-engine/.env.production
nano Kolibri-ai-engine/.env.production
```

**Important settings:**
- `OPENAI_API_KEY`: API key dari OpenAI atau compatible provider
- `OPENAI_BASE_URL`: Base URL untuk LLM API
- `OPENAI_MODEL`: Model yang akan digunakan (contoh: gpt-4o-mini)
- `HF_TOKEN`: HuggingFace token untuk embedding models

#### Core API
```bash
cp Kolibri-core-api/.env.production.example Kolibri-core-api/.env.production
nano Kolibri-core-api/.env.production
```

**Important settings:**
- `JWT_SECRET`: Generate random string minimal 32 karakter
- `CLIENT_URL`: Domain production (contoh: https://kolabri.com)
- `AI_ENGINE_SECRET`: Secret untuk internal API communication

#### Client App
```bash
cp Kolibri-client-app/.env.production.example Kolibri-client-app/.env.production
nano Kolibri-client-app/.env.production
```

**Important settings:**
- `APP_URL`: Domain production
- `APP_KEY`: Akan di-generate otomatis saat deploy
- `APP_DEBUG`: Harus `false` di production

### 3. Configure Root Environment
```bash
nano .env
```

Set strong passwords untuk:
```env
POSTGRES_PASSWORD=<strong-password-min-16-chars>
MONGO_USERNAME=admin
MONGO_PASSWORD=<strong-password-min-16-chars>
REDIS_PASSWORD=<strong-password-min-16-chars>
```

**Generate strong passwords:**
```bash
# Generate random password
openssl rand -base64 32
```

### 4. Run Deployment Script
```bash
./deploy.sh
```

Script akan:
1. Check prerequisites
2. Create necessary directories
3. Verify environment files
4. Build Docker images
5. Start all services
6. Run database migrations
7. Generate Laravel APP_KEY
8. Optimize Laravel for production

## 🔒 SSL Configuration (Recommended)

### Option 1: Let's Encrypt (Free)

```bash
# Install Certbot
sudo apt update
sudo apt install certbot

# Stop nginx temporarily
docker-compose -f docker-compose.production.yml stop nginx

# Get certificate
sudo certbot certonly --standalone -d your-domain.com -d www.your-domain.com

# Copy certificates to nginx ssl directory
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem nginx/ssl/
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem nginx/ssl/

# Update permissions
sudo chown -R $USER:$USER nginx/ssl/
sudo chmod 600 nginx/ssl/privkey.pem
```

Edit `nginx/conf.d/default.conf`:
```nginx
# Uncomment HTTPS server block
server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;

    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Copy all location blocks from HTTP server
}

# Update HTTP server to redirect to HTTPS
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

```bash
# Restart nginx
docker-compose -f docker-compose.production.yml restart nginx
```

### Option 2: Auto-renewal dengan Certbot

```bash
# Create renewal script
cat > /opt/kolabri/renew-ssl.sh << 'EOF'
#!/bin/bash
cd /opt/kolabri
docker-compose -f docker-compose.production.yml stop nginx
certbot renew
cp /etc/letsencrypt/live/your-domain.com/fullchain.pem nginx/ssl/
cp /etc/letsencrypt/live/your-domain.com/privkey.pem nginx/ssl/
chown -R $USER:$USER nginx/ssl/
chmod 600 nginx/ssl/privkey.pem
docker-compose -f docker-compose.production.yml start nginx
EOF

chmod +x /opt/kolabri/renew-ssl.sh

# Add to crontab (run twice daily)
crontab -e
# Add: 0 0,12 * * * /opt/kolabri/renew-ssl.sh
```

## 📊 Monitoring & Maintenance

### View Logs
```bash
# All services
docker-compose -f docker-compose.production.yml logs -f

# Specific service
docker-compose -f docker-compose.production.yml logs -f ai-engine
docker-compose -f docker-compose.production.yml logs -f core-api
docker-compose -f docker-compose.production.yml logs -f client-app
docker-compose -f docker-compose.production.yml logs -f nginx
```

### Check Service Status
```bash
docker-compose -f docker-compose.production.yml ps
```

### Restart Services
```bash
# Restart all
docker-compose -f docker-compose.production.yml restart

# Restart specific service
docker-compose -f docker-compose.production.yml restart ai-engine
```

### Update Application
```bash
cd /opt/kolabri

# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose -f docker-compose.production.yml up -d --build

# Run migrations if needed
docker exec kolabri-core-api npx prisma migrate deploy
docker exec kolabri-client-app php artisan migrate --force
```

### Database Backup
```bash
# Backup PostgreSQL
docker exec kolabri-postgres pg_dump -U postgres kolabri-db > backup-$(date +%Y%m%d).sql

# Backup MongoDB
docker exec kolabri-mongodb mongodump --out /backup/mongo-$(date +%Y%m%d)

# Backup Redis (optional)
docker exec kolabri-redis redis-cli BGSAVE
docker cp kolabri-redis:/data/dump.rdb ./redis-backup-$(date +%Y%m%d).rdb
```

### Database Restore
```bash
# Restore PostgreSQL
cat backup.sql | docker exec -i kolabri-postgres psql -U postgres -d kolabri-db

# Restore MongoDB
docker cp ./mongo-backup kolabri-mongodb:/backup
docker exec kolabri-mongodb mongorestore /backup/mongo-backup
```

## 🔧 Troubleshooting

### Services Won't Start

**Check logs:**
```bash
docker-compose -f docker-compose.production.yml logs --tail=100
```

**Common issues:**

1. **Port already in use**
```bash
# Check what's using the port
sudo lsof -i :80
sudo lsof -i :443

# Stop conflicting services
sudo systemctl stop apache2 nginx
```

2. **Permission denied**
```bash
# Fix file permissions
sudo chown -R $USER:$USER .
chmod -R 755 .
```

3. **Database connection failed**
```bash
# Check if database is healthy
docker-compose -f docker-compose.production.yml ps postgres mongodb

# Restart database
docker-compose -f docker-compose.production.yml restart postgres mongodb
```

### 502 Bad Gateway

**Check if services are running:**
```bash
docker-compose -f docker-compose.production.yml ps
```

**Check nginx logs:**
```bash
docker logs kolabri-nginx
```

**Restart services:**
```bash
docker-compose -f docker-compose.production.yml restart
```

### Out of Memory

**Check resource usage:**
```bash
docker stats
```

**Increase swap space:**
```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

## 🔐 Security Best Practices

### 1. Firewall Configuration
```bash
# Enable UFW
sudo ufw enable

# Allow SSH, HTTP, HTTPS
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Check status
sudo ufw status
```

### 2. Regular Updates
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Update Docker images
docker-compose -f docker-compose.production.yml pull
docker-compose -f docker-compose.production.yml up -d
```

### 3. Backup Strategy
- Daily database backups (automated with cron)
- Weekly full system backup
- Store backups off-site (S3, external storage)
- Test restore procedure monthly

### 4. Monitoring
Consider using:
- **Uptime monitoring**: UptimeRobot, Pingdom
- **Error tracking**: Sentry
- **Log aggregation**: ELK Stack, Papertrail
- **Metrics**: Prometheus + Grafana

### 5. SSL Certificate Monitoring
```bash
# Check certificate expiry
echo | openssl s_client -servername your-domain.com -connect your-domain.com:443 2>/dev/null | openssl x509 -noout -dates
```

## 📈 Performance Optimization

### 1. Enable Gzip Compression
Already enabled in `nginx/nginx.conf`

### 2. Browser Caching
Add to `nginx/conf.d/default.conf`:
```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### 3. Database Optimization
```bash
# PostgreSQL
docker exec -it kolabri-postgres psql -U postgres -d kolabri-db
VACUUM ANALYZE;
\q

# MongoDB
docker exec -it kolabri-mongodb mongosh
use kolabri
db.stats()
```

## 🎯 Post-Deployment Checklist

- [ ] Verify all services are running (`docker-compose ps`)
- [ ] Test application functionality
- [ ] Configure SSL certificate
- [ ] Update domain DNS
- [ ] Set up automated backups
- [ ] Configure firewall (UFW)
- [ ] Set up monitoring
- [ ] Test backup restore procedure
- [ ] Document custom configurations
- [ ] Set up log rotation

## 📞 Support

Untuk bantuan lebih lanjut:
- Check logs: `docker-compose -f docker-compose.production.yml logs -f`
- Review documentation in `/docs` folder
- Check service health: `docker-compose -f docker-compose.production.yml ps`

## 🔄 Rollback Procedure

Jika deployment gagal:

```bash
# Stop current deployment
docker-compose -f docker-compose.production.yml down

# Restore from backup
cat backup-latest.sql | docker exec -i kolabri-postgres psql -U postgres -d kolabri-db

# Checkout previous stable version
git checkout <previous-tag>

# Rebuild and start
docker-compose -f docker-compose.production.yml up -d --build
```

---

**Last Updated**: 2024
**Version**: 1.0.0
