# 🚀 Quick Start - Deploy Kolabri ke VPS

Panduan cepat untuk deploy Kolibri dalam 5 menit (setelah konfigurasi awal).

## ⚡ Quick Deploy (5 Menit)

### 1. Setup VPS (One-time)
```bash
# Install Docker & Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
logout  # Login kembali untuk apply docker group
```

### 2. Clone & Configure
```bash
cd /opt
git clone <your-repo-url> kolabri
cd kolabri

# Generate passwords
echo "POSTGRES_PASSWORD=$(openssl rand -base64 32)" >> .env
echo "MONGO_PASSWORD=$(openssl rand -base64 32)" >> .env
echo "REDIS_PASSWORD=$(openssl rand -base64 32)" >> .env
echo "MONGO_USERNAME=admin" >> .env

# Copy environment templates
cp Kolabri-ai-engine/.env.production.example Kolabri-ai-engine/.env.production
cp Kolabri-core-api/.env.production.example Kolabri-core-api/.env.production
cp Kolabri-client-app/.env.production.example Kolabri-client-app/.env.production
```

### 3. Edit Critical Config
```bash
# Edit AI Engine config
nano Kolabri-ai-engine/.env.production
# Set: OPENAI_API_KEY, OPENAI_BASE_URL, OPENAI_MODEL

# Edit Core API config
nano Kolabri-core-api/.env.production
# Set: JWT_SECRET (random 32+ chars), CLIENT_URL (your domain)

# Edit Client App config
nano Kolabri-client-app/.env.production
# Set: APP_URL (your domain)
```

### 4. Deploy
```bash
./deploy.sh
```

### 5. Update Nginx Domain
```bash
nano nginx/conf.d/default.conf
# Ganti: your-domain.com dengan domain kamu
docker compose -f docker-compose.production.yml restart nginx
```

**Selesai!** Buka http://your-domain.com

---

## 🔐 Setup SSL (Opsional tapi Recommended)

```bash
# Stop nginx
docker compose -f docker-compose.production.yml stop nginx

# Get SSL certificate
sudo apt install certbot -y
sudo certbot certonly --standalone -d your-domain.com

# Copy certificates
sudo mkdir -p nginx/ssl
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem nginx/ssl/
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem nginx/ssl/
sudo chown -R $USER:$USER nginx/ssl/
sudo chmod 600 nginx/ssl/privkey.pem

# Edit nginx config untuk enable HTTPS
nano nginx/conf.d/default.conf
# Uncomment HTTPS server block

# Restart nginx
docker compose -f docker-compose.production.yml start nginx
```

---

## 📝 Common Commands

```bash
# View logs
docker compose -f docker-compose.production.yml logs -f

# Restart all services
docker compose -f docker-compose.production.yml restart

# Stop all services
docker compose -f docker-compose.production.yml down

# Start all services
docker compose -f docker-compose.production.yml up -d

# Rebuild after code changes
docker compose -f docker-compose.production.yml up -d --build

# Check service status
docker compose -f docker-compose.production.yml ps

# Shell into container
docker exec -it kolabri-client-app bash
docker exec -it kolabri-core-api sh
docker exec -it kolabri-ai-engine bash
```

---

## 🗄️ Database Operations

```bash
# Backup database
docker exec kolabri-postgres pg_dump -U postgres kolabri-db > backup-$(date +%Y%m%d).sql

# Restore database
cat backup.sql | docker exec -i kolabri-postgres psql -U postgres -d kolabri-db

# Run migrations manually
docker exec kolabri-core-api npx prisma migrate deploy
docker exec kolabri-client-app php artisan migrate --force
```

---

## 🔧 Troubleshooting

### Service won't start
```bash
# Check logs
docker compose -f docker-compose.production.yml logs <service-name>

# Restart specific service
docker compose -f docker-compose.production.yml restart <service-name>
```

### 502 Bad Gateway
```bash
# Check if backend services are running
docker compose -f docker-compose.production.yml ps

# Restart all
docker compose -f docker-compose.production.yml restart
```

### Port already in use
```bash
# Find what's using port 80/443
sudo lsof -i :80
sudo lsof -i :443

# Stop conflicting services
sudo systemctl stop apache2 nginx
```

---

## 📊 Monitoring

```bash
# Real-time resource usage
docker stats

# Check disk usage
docker system df

# Clean up unused resources
docker system prune -f
```

---

## 🔄 Update Application

```bash
cd /opt/kolabri

# Pull latest code
git pull origin main

# Rebuild and restart
docker compose -f docker-compose.production.yml up -d --build

# Run migrations if needed
docker exec kolabri-core-api npx prisma migrate deploy
docker exec kolabri-client-app php artisan migrate --force
```

---

## 📚 Full Documentation

Untuk panduan lengkap termasuk:
- SSL auto-renewal
- Backup strategies
- Performance optimization
- Security best practices
- Monitoring setup

Lihat: **[DEPLOYMENT.md](DEPLOYMENT.md)**

---

**Happy deploying! 🎉**
