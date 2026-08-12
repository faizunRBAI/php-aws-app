# php-aws-app

A PHP 8.2 / Laravel 11 web application deployed on AWS EC2 via a fully automated CI/CD pipeline.

---

## Architecture

```
Internet User
     │  HTTP :80
     ▼
  EC2 (Ubuntu 22.04)
  ┌──────────────────────────────┐
  │  nginx (reverse proxy :80)  │
  │    └── PHP-FPM 8.2          │
  │         └── Laravel 11      │
  └──────────────────────────────┘
```

The full architecture diagram lives in [`.udap/architecture.d2`](.udap/architecture.d2).

---

## Local Development

### Prerequisites

- PHP 8.2+
- Composer
- (optional) Laravel Sail / Docker

```bash
# 1. Clone the repo
git clone https://github.com/<your-org>/php-aws-app.git
cd php-aws-app

# 2. Install PHP dependencies
composer install

# 3. Copy and configure environment
cp .env.example .env
php artisan key:generate

# 4. Start the dev server
php artisan serve
# → http://localhost:8000
```

---

## Deployment Pipeline

| Stage | What it does |
|-------|-------------|
| **lint** | Installs PHP & Composer, runs `php -l` syntax check on all source files |
| **test** | Installs dependencies, generates APP_KEY, runs `php artisan test` |
| **provision** | Runs `terraform apply` — EC2 instance, Security Group, Elastic IP, Key Pair |
| **configure** | Runs Ansible — installs PHP 8.2, PHP-FPM, nginx, Composer; deploys app code; writes `.env` |
| **verify** | Polls `http://<instance_ip>/` with retries until the app responds |

Triggered on every push to `main`. Destroy is available via the manual workflow dispatch.

---

## Configuration

All secrets are managed via GitHub repository secrets. The following variables are used:

| Name | Where | Description |
|------|-------|-------------|
| `APP_KEY` | GitHub Secret | Laravel encryption key (32-char base64) |
| `AWS_ACCESS_KEY_ID` | Platform Secret | AWS credentials |
| `AWS_SECRET_ACCESS_KEY` | Platform Secret | AWS credentials |
| `SSH_PUBLIC_KEY` | Platform Secret | EC2 key pair public key |
| `SSH_PRIVATE_KEY` | Platform Secret | Used by Ansible to configure the instance |
| `SSH_USER` | Platform Secret | OS login user (`ubuntu` for Ubuntu 22.04) |
| `PROJECT_NAME` | Platform Secret | Resource prefix and Terraform state key |
| `TF_STATE_BUCKET` | Platform Secret | S3 bucket for Terraform remote state |

---

## Operations

### Logs

```bash
# Application logs (Laravel)
sudo tail -f /var/www/php-aws-app/storage/logs/laravel.log

# Nginx access/error logs
sudo tail -f /var/log/nginx/php-aws-app.access.log
sudo tail -f /var/log/nginx/php-aws-app.error.log
```

### Restart services

```bash
sudo systemctl restart php8.2-fpm
sudo systemctl restart nginx
```

### Clear Laravel caches

```bash
cd /var/www/php-aws-app
sudo -u www-data php artisan optimize:clear
sudo -u www-data php artisan optimize
```

### Destroy infrastructure

Trigger the **destroy** workflow from the GitHub Actions tab → workflow_dispatch.

---

## Cost Estimate

| Resource | Monthly cost (us-east-1) |
|----------|--------------------------|
| EC2 t3.micro | ~$8–10 |
| Elastic IP (associated) | Free |
| S3 state bucket | < $0.01 |

> Costs are estimates. Check the AWS Pricing Calculator for exact figures.
