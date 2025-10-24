# AnimalGuardian Deployment Guide

## Overview

This guide provides step-by-step instructions for deploying the AnimalGuardian system to production environments. The system consists of multiple components that need to be deployed and configured properly.

## Architecture

The AnimalGuardian system consists of:

1. **Django Backend API** - Core business logic and data management
2. **React Native Mobile App** - Farmer mobile application
3. **React Web Dashboard** - Veterinarian and admin dashboard
4. **USSD Service** - SMS/USSD integration for basic phones
5. **PostgreSQL Database** - Primary data storage
6. **Redis** - Caching and task queue
7. **Nginx** - Reverse proxy and static file serving

## Prerequisites

### System Requirements

- **Server**: Ubuntu 20.04 LTS or later (recommended)
- **RAM**: Minimum 4GB, recommended 8GB
- **Storage**: Minimum 50GB SSD
- **CPU**: Minimum 2 cores, recommended 4 cores

### Software Requirements

- Python 3.9+
- Node.js 16+
- PostgreSQL 13+
- Redis 6+
- Nginx
- Docker and Docker Compose (optional)

## Deployment Options

### Option 1: Docker Deployment (Recommended)

#### 1. Clone Repository

```bash
git clone https://github.com/your-org/animalguardian.git
cd animalguardian
```

#### 2. Configure Environment Variables

Create environment files for each service:

**Backend (.env)**
```bash
cp backend/.env.example backend/.env
```

Update the values in `backend/.env`:
```env
SECRET_KEY=your-production-secret-key
DEBUG=False
ALLOWED_HOSTS=your-domain.com,api.your-domain.com
DATABASE_URL=postgresql://username:password@db:5432/animalguardian
AFRICASTALKING_USERNAME=your-username
AFRICASTALKING_API_KEY=your-api-key
CELERY_BROKER_URL=redis://redis:6379
```

**USSD Service (.env)**
```bash
cp ussd-service/.env.example ussd-service/.env
```

**Web Dashboard (.env)**
```bash
cp web-dashboard/.env.example web-dashboard/.env
```

#### 3. Deploy with Docker Compose

```bash
# Build and start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f backend
```

#### 4. Run Initial Setup

```bash
# Create database migrations
docker-compose exec backend python manage.py makemigrations

# Apply migrations
docker-compose exec backend python manage.py migrate

# Create superuser
docker-compose exec backend python manage.py createsuperuser

# Collect static files
docker-compose exec backend python manage.py collectstatic --noinput

# Load initial data
docker-compose exec backend python manage.py loaddata initial_data.json
```

### Option 2: Manual Deployment

#### 1. Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y python3 python3-pip python3-venv nodejs npm postgresql postgresql-contrib redis-server nginx git

# Install Docker (optional)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

#### 2. Database Setup

```bash
# Create PostgreSQL database
sudo -u postgres psql
CREATE DATABASE animalguardian;
CREATE USER animalguardian WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE animalguardian TO animalguardian;
\q
```

#### 3. Backend Deployment

```bash
# Clone repository
git clone https://github.com/your-org/animalguardian.git
cd animalguardian/backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with production values

# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Collect static files
python manage.py collectstatic --noinput

# Start Django with Gunicorn
pip install gunicorn
gunicorn --bind 0.0.0.0:8000 animalguardian.wsgi:application
```

#### 4. Frontend Deployment

```bash
# Mobile App (React Native)
cd frontend
npm install
npm run build:android  # For Android APK
npm run build:ios      # For iOS (requires macOS)

# Web Dashboard
cd web-dashboard
npm install
npm run build

# Copy build files to web server
sudo cp -r build/* /var/www/html/
```

#### 5. USSD Service Deployment

```bash
cd ussd-service
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with production values

# Start with Gunicorn
pip install gunicorn
gunicorn --bind 0.0.0.0:5000 app:app
```

#### 6. Nginx Configuration

Create `/etc/nginx/sites-available/animalguardian`:

```nginx
server {
    listen 80;
    server_name your-domain.com api.your-domain.com;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com api.your-domain.com;

    # SSL Configuration
    ssl_certificate /path/to/your/certificate.crt;
    ssl_certificate_key /path/to/your/private.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Security Headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # API Backend
    location /api/ {
        proxy_pass http://127.0.0.1:8000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Admin Interface
    location /admin/ {
        proxy_pass http://127.0.0.1:8000/admin/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static Files
    location /static/ {
        alias /path/to/backend/staticfiles/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location /media/ {
        alias /path/to/backend/media/;
        expires 1y;
        add_header Cache-Control "public";
    }

    # Web Dashboard
    location / {
        root /var/www/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # USSD Service
    location /ussd/ {
        proxy_pass http://127.0.0.1:5000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/animalguardian /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### 7. SSL Certificate

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Obtain SSL certificate
sudo certbot --nginx -d your-domain.com -d api.your-domain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

#### 8. Process Management

Create systemd service files:

**Backend Service (`/etc/systemd/system/animalguardian-backend.service`)**:

```ini
[Unit]
Description=AnimalGuardian Django Backend
After=network.target

[Service]
Type=exec
User=www-data
Group=www-data
WorkingDirectory=/path/to/animalguardian/backend
Environment=PATH=/path/to/animalguardian/backend/venv/bin
ExecStart=/path/to/animalguardian/backend/venv/bin/gunicorn --bind 127.0.0.1:8000 animalguardian.wsgi:application
Restart=always

[Install]
WantedBy=multi-user.target
```

**USSD Service (`/etc/systemd/system/animalguardian-ussd.service`)**:

```ini
[Unit]
Description=AnimalGuardian USSD Service
After=network.target

[Service]
Type=exec
User=www-data
Group=www-data
WorkingDirectory=/path/to/animalguardian/ussd-service
Environment=PATH=/path/to/animalguardian/ussd-service/venv/bin
ExecStart=/path/to/animalguardian/ussd-service/venv/bin/gunicorn --bind 127.0.0.1:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable and start services:

```bash
sudo systemctl daemon-reload
sudo systemctl enable animalguardian-backend
sudo systemctl enable animalguardian-ussd
sudo systemctl start animalguardian-backend
sudo systemctl start animalguardian-ussd
```

## Monitoring and Maintenance

### Log Management

```bash
# View application logs
sudo journalctl -u animalguardian-backend -f
sudo journalctl -u animalguardian-ussd -f

# View Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Database Maintenance

```bash
# Backup database
pg_dump -h localhost -U animalguardian animalguardian > backup_$(date +%Y%m%d).sql

# Restore database
psql -h localhost -U animalguardian animalguardian < backup_20240115.sql
```

### Updates and Deployments

```bash
# Pull latest changes
git pull origin main

# Update dependencies
pip install -r requirements.txt
npm install

# Run migrations
python manage.py migrate

# Collect static files
python manage.py collectstatic --noinput

# Restart services
sudo systemctl restart animalguardian-backend
sudo systemctl restart animalguardian-ussd
```

## Performance Optimization

### Database Optimization

```sql
-- Create indexes for better performance
CREATE INDEX idx_case_reports_status ON case_reports(status);
CREATE INDEX idx_case_reports_reported_at ON case_reports(reported_at);
CREATE INDEX idx_livestock_owner ON livestock(owner_id);
CREATE INDEX idx_notifications_recipient ON notifications(recipient_id);
```

### Caching

```python
# Add Redis caching to Django settings
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        }
    }
}
```

### CDN Configuration

Configure CloudFlare or AWS CloudFront for static file delivery:

1. Upload static files to CDN
2. Update Django settings with CDN URLs
3. Configure cache headers for optimal performance

## Security Considerations

### Firewall Configuration

```bash
# Configure UFW firewall
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

### Database Security

```bash
# Secure PostgreSQL
sudo nano /etc/postgresql/13/main/postgresql.conf
# Set: listen_addresses = 'localhost'

sudo nano /etc/postgresql/13/main/pg_hba.conf
# Ensure only local connections are allowed
```

### Application Security

- Use strong passwords for all accounts
- Enable two-factor authentication where possible
- Regular security updates
- Monitor access logs
- Implement rate limiting
- Use HTTPS everywhere

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   ```bash
   # Check PostgreSQL status
   sudo systemctl status postgresql
   
   # Test connection
   psql -h localhost -U animalguardian -d animalguardian
   ```

2. **Static Files Not Loading**
   ```bash
   # Check Nginx configuration
   sudo nginx -t
   
   # Check file permissions
   sudo chown -R www-data:www-data /path/to/staticfiles/
   ```

3. **USSD Service Not Responding**
   ```bash
   # Check service status
   sudo systemctl status animalguardian-ussd
   
   # Check logs
   sudo journalctl -u animalguardian-ussd -f
   ```

### Health Checks

Create health check endpoints:

```bash
# Backend health check
curl https://api.your-domain.com/health/

# USSD service health check
curl https://your-domain.com/ussd/health
```

## Support

For deployment support:
- **Email**: devops@animalguardian.rw
- **Documentation**: https://docs.animalguardian.rw
- **Issue Tracker**: https://github.com/your-org/animalguardian/issues
