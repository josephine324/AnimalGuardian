# 🐄 AnimalGuardian - Digital Livestock Support System

A comprehensive digital platform designed to enhance veterinary service delivery, disease surveillance, and farmer knowledge for smallholder farmers in Nyagatare District, Rwanda.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Installation & Setup](#installation--setup)
- [Running the Application](#running-the-application)
- [API Documentation](#api-documentation)
- [System Status & Functionality](#system-status--functionality)
- [Test Results & System Status](#test-results--system-status)
- [PowerShell Management Scripts](#powershell-management-scripts)
- [Complete API Documentation](#complete-api-documentation)
- [Complete Deployment Guide](#complete-deployment-guide)
- [Railway Deployment Guide (Backend & USSD Service)](#-railway-deployment-guide-backend--ussd-service)
- [Flutter Mobile App Details](#flutter-mobile-app-details)
- [Feature Completion Status](#feature-completion-status)
- [Troubleshooting](#troubleshooting)
- [Development Guide](#development-guide)
- [Contributing](#contributing)
- [License](#license)

---

## 🌟 Overview

AnimalGuardian is a multi-platform digital livestock health management system that addresses critical challenges faced by smallholder farmers in Rwanda. The system provides:

- **Real-time disease reporting** with multimedia support
- **Expert veterinary consultation** via mobile and web platforms
- **Preventive health management** with automated reminders
- **Disease surveillance** and outbreak alerts
- **Multi-language support** (Kinyarwanda, English, French)

### 🎯 Target Users

- **Smallholder Farmers** - Primary beneficiaries in Nyagatare District
- **Veterinarians** - Professional service providers
- **Agricultural Extension Officers** - Support staff
- **Government Agencies** - Policy makers and monitoring bodies

---

## ✨ Features

### 📱 Mobile Application (Flutter)

- **Case Reporting**: Report animal health issues with photos/videos
- **Veterinary Consultation**: Chat with certified veterinarians  
- **Health Records**: Track vaccination and treatment history
- **Livestock Management**: Add and manage livestock inventory
- **Weather Integration**: Get weather-based health alerts
- **Agricultural Features**: Crop farming, market prices, community support
- **Cross-platform**: Single codebase for iOS and Android
- **Native Performance**: 60 FPS animations, fast startup times
- **Offline Support**: Local data storage with sync capability
- **Multi-language**: English, Kinyarwanda, French

### 💻 Web Dashboard (React.js)

- **Admin Panel**: Comprehensive management interface
- **Case Management**: Review and respond to farmer reports
- **Analytics Dashboard**: Disease trends and statistics
- **Veterinarian Management**: Assign cases and track responses
- **Notification Center**: System-wide alerts and reminders

### 🔧 Backend Services (Django)

- **RESTful API**: Secure data management
- **Authentication**: JWT-based user authentication
- **File Management**: Secure media upload and storage
- **Notification System**: SMS, email, and push notifications
- **Database Management**: PostgreSQL with optimized queries

### 📞 USSD/SMS Service

- **Basic Phone Support**: Access via USSD codes
- **SMS Alerts**: Critical health notifications
- **Multi-language**: Support for local languages

---

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Mobile App    │    │  Web Dashboard  │    │   USSD/SMS      │
│    (Flutter)    │    │   (React.js)    │    │   Service       │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────┬───────────┴──────────┬───────────┘
                     │                      │
                ┌────▼────────────────────────▼────┐
                │         Backend API             │
                │        (Django REST)            │
                │                                 │
                │  ┌─────────┐  ┌─────────────┐   │
                │  │Database │  │   Services  │   │
                │  │PostgreSQL│ │  (SMS, etc) │   │
                │  └─────────┘  └─────────────┘   │
                └─────────────────────────────────┘
```

---

## 🛠️ Technology Stack

### Frontend
- **Flutter** - Cross-platform mobile development (iOS & Android)
- **Dart** - Programming language
- **Riverpod** - State management
- **GoRouter** - Navigation and routing
- **Material Design 3** - UI components
- **React.js** - Web dashboard interface
- **TypeScript** - Programming language
- **Tailwind CSS** - Utility-first styling

### Backend
- **Python 3.11+** - Core programming language
- **Django 5.1+** - Web framework
- **Django REST Framework** - API development
- **PostgreSQL** - Primary database
- **SQLite** - Development database
- **Redis** - Caching and task queue
- **JWT** - Authentication tokens

### Services & APIs
- **Africa's Talking API** - USSD and SMS services
- **Docker** - Containerization
- **Nginx** - Reverse proxy and web server

---

## 📁 Project Structure

```
AnimalGuardian/
├── frontend/                  # Flutter Mobile App
│   ├── lib/
│   │   ├── core/             # App configuration & shared logic
│   │   ├── features/          # Feature-based modules
│   │   ├── shared/           # Shared UI components
│   │   └── main.dart         # App entry point
│   ├── android/              # Android-specific configuration
│   ├── ios/                  # iOS-specific configuration
│   └── pubspec.yaml          # Flutter dependencies
├── backend/                  # Django REST API
│   ├── animalguardian/       # Django project settings
│   ├── accounts/             # User management
│   ├── livestock/            # Livestock models & views
│   ├── cases/                # Case reporting system
│   ├── notifications/        # Notification system
│   └── manage.py            # Django management
├── web-dashboard/           # React.js Admin Panel
│   ├── src/
│   │   ├── pages/           # Dashboard pages
│   │   ├── components/      # UI components
│   │   └── hooks/           # Custom hooks
│   └── package.json         # Node dependencies
├── ussd-service/            # USSD/SMS Gateway
│   ├── app.py              # Flask USSD handler
│   └── requirements.txt     # Python dependencies
├── docs/                    # Documentation
└── scripts/                 # Setup & deployment scripts
```

---

## 📋 Prerequisites

Before running the AnimalGuardian system, ensure you have the following installed:

### Core Requirements (All Platforms)
- **Node.js** (v18 or higher) - [Download here](https://nodejs.org/)
  - Verify: `node --version` (should show v18+)
- **Python** (3.11, 3.12, or 3.13) - [Download here](https://www.python.org/downloads/)
  - Verify: `python --version` (should show 3.11+)
- **Git** - [Download here](https://git-scm.com/downloads)
  - Verify: `git --version`
- **SQLite** (included with Python)

### Mobile Development (Android) - Required for Mobile App
- **Flutter SDK** (>=3.10.0) - [Download here](https://flutter.dev/docs/get-started/install)
  - Verify: `flutter --version` and `flutter doctor`
- **Android Studio** - [Download here](https://developer.android.com/studio)
- **Android SDK** (API level 21 or higher)
- **Java Development Kit (JDK)** (v11 or higher) - [Download here](https://adoptium.net/)
  - Verify: `java --version` (should show 11+)

### Mobile Development (iOS) - Optional, macOS only
- **Xcode** (v14 or higher) - Available on Mac App Store
- **CocoaPods** - `sudo gem install cocoapods`
  - Verify: `pod --version`

### Optional Services
- **PostgreSQL** (v13 or higher) - [Download here](https://www.postgresql.org/download/) - For production use
- **Redis** - For background tasks and caching
- **Africa's Talking Account** - For USSD/SMS functionality
  - Sign up at [africastalking.com](https://africastalking.com)

### Quick Verification

Run these commands to verify all prerequisites:

```bash
# Verify all installed tools
python --version    # Should be 3.11+
node --version      # Should be v18+
git --version       # Any recent version
flutter --version   # Should be >=3.10.0
java --version      # Should be 11+ (for Android)
```

---

## 🚀 Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/josephine324/AnimalGuardian.git
cd AnimalGuardian
```

### 2. Backend Setup (Django API)

**Using requirements-simple.txt (recommended for Python 3.13):**
```bash
cd backend
python -m venv venv
# Windows PowerShell:
.\venv\Scripts\Activate.ps1
# Windows CMD:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies (use simple requirements for Python 3.13+)
pip install -r requirements-simple.txt

# Run database migrations
python manage.py migrate

# Create admin user (optional, follow prompts)
python manage.py createsuperuser

# Start development server
python manage.py runserver
```

**Backend available at:** `http://localhost:8000`
**Admin Panel:** `http://localhost:8000/admin`

**Note:** If you encounter issues with `Pillow` on Python 3.13+, use `requirements-simple.txt` instead.

### 3. Mobile App Setup (Flutter)

```bash
cd frontend
flutter pub get
flutter run
```

**For Android Emulator:**
- API base URL: `http://10.0.2.2:8000/api` (configured in `app_constants.dart`)
- For iOS Simulator: `http://localhost:8000/api`
- For Physical Device: `http://YOUR_COMPUTER_IP:8000/api`

### 4. Web Dashboard Setup (React.js)

```bash
cd web-dashboard
npm install
npm start
```

**Web Dashboard available at:** `http://localhost:3000`

**Default Web Dashboard Admin Login**
- Email: `admin@animalguardian.rw`
- Password: `admin123`

### 5. USSD Service Setup (Optional)

For USSD/SMS functionality via Africa's Talking:

```bash
cd ussd-service

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows PowerShell:
.\venv\Scripts\Activate.ps1
# Windows CMD:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies (simple version for local development)
pip install -r requirements-simple.txt

# Create .env file (if not exists)
if (!(Test-Path .env)) {
    @"
AFRICASTALKING_USERNAME=<africastalking_username>
AFRICASTALKING_API_KEY=<africastalking_api_key>
BACKEND_API_URL=http://localhost:8000/api
"@ | Out-File -FilePath .env -Encoding utf8
}

# Run USSD service
python app.py
```

**USSD Service available at:** `http://localhost:5000`
**Health Check:** `http://localhost:5000/health`

**Configuration:**
- Create `.env` file with:
  ```env
  AFRICASTALKING_USERNAME=<africastalking_username>
  AFRICASTALKING_API_KEY=<africastalking_api_key>
  BACKEND_API_URL=http://localhost:8000/api
  ```

**Note:** For production with PostgreSQL, use `requirements.txt` instead of `requirements-simple.txt`.

---

## 🚀 Running the Application

### Step-by-Step Startup

**1. Start Backend Server (Required)**

Open a terminal and run:
```bash
cd backend
.\venv\Scripts\Activate.ps1  # Windows PowerShell
# or: venv\Scripts\activate  # Windows CMD
# or: source venv/bin/activate  # macOS/Linux
python manage.py runserver
```

✅ Backend will be available at: `http://localhost:8000`

**2. Start Mobile App (Optional)**

Open a **new terminal** and run:
```bash
cd frontend
flutter run
# Or specify device: flutter run -d emulator-5554
```

✅ App will launch on connected device/emulator

**3. Start Web Dashboard (Optional)**

Open a **new terminal** and run:
```bash
cd web-dashboard
npm start
```

✅ Dashboard will be available at: `http://localhost:3000`

**4. Start USSD Service (Optional)**

Open a **new terminal** and run:
```bash
cd ussd-service
.\venv\Scripts\Activate.ps1  # Windows PowerShell
# or: venv\Scripts\activate  # Windows CMD
# or: source venv/bin/activate  # macOS/Linux
python app.py
```

✅ USSD service will be available at: `http://localhost:5000`
✅ Health check: `http://localhost:5000/health`

**5. Verify All Services Are Running**

Open a **new terminal** and run:

```powershell
# PowerShell Verification
Write-Host "Checking services..." -ForegroundColor Yellow

# Backend
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/admin/" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
    Write-Host "✓ Backend: RUNNING" -ForegroundColor Green
} catch {
    Write-Host "✗ Backend: NOT RUNNING" -ForegroundColor Red
}

# Web Dashboard
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
    Write-Host "✓ Web Dashboard: RUNNING" -ForegroundColor Green
} catch {
    Write-Host "✗ Web Dashboard: NOT RUNNING" -ForegroundColor Red
}

# USSD Service
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5000/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
    Write-Host "✓ USSD Service: RUNNING" -ForegroundColor Green
} catch {
    Write-Host "○ USSD Service: NOT RUNNING (optional)" -ForegroundColor Yellow
}
```

**Expected URLs:**
- Backend: http://localhost:8000
- Admin Panel: http://localhost:8000/admin
- API Docs: http://localhost:8000/api/docs
- Web Dashboard: http://localhost:3000
- USSD Service: http://localhost:5000
- USSD Health: http://localhost:5000/health

### Quick Start (Windows PowerShell)

**Verify All Services:**
```powershell
.\TEST_SERVICES.ps1
```

**Use Management Script:**
```powershell
.\manage_animalguardian.ps1
```

**Available Management Functions:**
- Start Backend Server
- Run Flutter Mobile App
- Build and Deploy
- Check System Status
- Install/Update Dependencies
- Database Management

---

## 📚 API Documentation

### Base URL

- **Development**: `http://localhost:8000/api`
- **Android Emulator**: `http://10.0.2.2:8000/api`
- **Production**: `https://api.animalguardian.rw/api`

### Authentication

The API uses JWT (JSON Web Token) authentication. Include the token in the Authorization header:

```
Authorization: Bearer <jwt-token>
```

### Authentication Endpoints

- `POST /api/auth/register/` - User registration
- `POST /api/auth/login/` - User login
- `POST /api/auth/verify-otp/` - OTP verification
- `POST /api/auth/refresh/` - Token refresh
- `GET /api/users/profile/` - Get user profile

**Example Login Request:**
```json
POST /api/auth/login/
{
  "phone_number": "+250123456789",
  "password": "securepassword"
}
```

**Example Response:**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "phone_number": "+250123456789",
    "first_name": "John",
    "last_name": "Doe",
    "user_type": "farmer"
  }
}
```

---

## ✓ Verify Installation

### Check Prerequisites

Run these commands to verify the installation:

```bash
# Check Python version (should be 3.11, 3.12, or 3.13)
python --version

# Check Node.js version (should be 18+)
node --version

# Check Flutter version (should be 3.10+)
flutter --version

# Check Flutter doctor for setup issues
flutter doctor -v
```

### Test Backend API

Once backend is running, test the API:

```bash
# Test admin panel
curl http://localhost:8000/admin

# Test API endpoint (should return 401 - auth required)
curl http://localhost:8000/api/

# Test login endpoint
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"phone_number":"+250123456789","password":"AnimalGuardian123"}'
```

### Test Mobile App

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Or run and let Flutter detect device
flutter run
```

### Test Web Dashboard

Once web dashboard is running:
- Open browser to `http://localhost:3000`
- Should see login page for admin dashboard

---

## 🧪 Testing the Application

### Test Credentials

For testing the mobile app and web dashboard, use the following pre-configured test accounts:

**Test Farmer Account:**
- **Phone Number:** `+250123456789`
- **Password:** `AnimalGuardian123`
- **Role:** Farmer
- **Access:** Full mobile app features

**Test Admin Account (Web Dashboard):**
- **Email:** `admin@animalguardian.rw`
- **Password:** `admin123`
- **Role:** Admin
- **Access:** Full web dashboard features

### What You'll See After Login

After successful login on the mobile app, you'll be taken to the **Home Screen** with:

1. **Search Bar** - Search for farming tips, breeding advice, or community members
2. **Filter Tabs** - Filter content by All, Livestock, Community
3. **Educational Cards** - Quick access to app tutorials and breeding tips
4. **Trending News** - Local farming news and updates

**Navigation Tabs:**
- **🏠 Home** - Dashboard and quick access features
- **☀️ Weather** - Weather forecasts and alerts
- **📊 Report Case** - Submit animal health reports
- **👥 Community** - Connect with other farmers
- **⋯ More** - Livestock management, market prices, profile

**Backend Admin Panel:**
- **URL:** `http://localhost:8000/admin`
- **Username:** `admin` (or as configured)
- **Password:** As set during `createsuperuser`

### Livestock Management

- `GET /api/livestock/` - List user's livestock
- `POST /api/livestock/` - Add new livestock
- `PUT /api/livestock/{id}/` - Update livestock info
- `DELETE /api/livestock/{id}/` - Remove livestock

### Case Reporting

- `POST /api/cases/reports/` - Report new case
- `GET /api/cases/reports/` - List user's cases
- `PUT /api/cases/reports/{id}/` - Update case status

### Notifications

- `GET /api/notifications/` - List notifications
- `PATCH /api/notifications/{id}/` - Mark as read
- `PUT /api/notifications/preferences/` - Update preferences

### Error Responses

**400 Bad Request:**
```json
{
  "error": "Validation Error",
  "details": {
    "phone_number": ["This field is required."]
  }
}
```

**401 Unauthorized:**
```json
{
  "error": "Authentication credentials were not provided."
}
```

**404 Not Found:**
```json
{
  "error": "Not found."
}
```

For complete API documentation, see the [Full API Documentation](#full-api-documentation) section below.

---

## 📊 System Status & Functionality

### ✅ Frontend Status: **FUNCTIONAL**

**Current Status:**
- ✅ Flutter app successfully built and running on Android emulator
- ✅ UI screens render correctly (Login, Community, Market, Weather)
- ✅ Navigation works (Bottom navigation bar functional)
- ✅ Form inputs functional (Login screen working)
- ✅ API service layer configured (`api_service.dart`)
- ✅ Login screen overflow fixed (SingleChildScrollView added)
- ✅ API base URL updated for Android emulator (`10.0.2.2:8000`)

**Configuration:**
- Base URL: `http://10.0.2.2:8000/api` (Android emulator)
- Authentication: JWT tokens stored securely
- State Management: Riverpod configured
- Routing: GoRouter configured

### ⚠️ Backend Status: **NEEDS VERIFICATION**

**Configuration:**
- ✅ Django 4.2.7 + Django REST Framework
- ✅ JWT authentication configured
- ✅ CORS enabled for mobile apps
- ✅ API endpoints properly configured
- ⚠️ Server status unknown - needs to be started

**Expected Endpoints:**
```
✅ POST /api/auth/register/     - User registration
✅ POST /api/auth/login/        - User authentication
✅ POST /api/auth/verify-otp/   - OTP verification
✅ POST /api/auth/refresh/      - Token refresh
✅ GET  /api/livestock/         - List livestock
✅ POST /api/livestock/         - Create livestock
✅ GET  /api/cases/reports/     - List cases
✅ POST /api/cases/reports/     - Create case
✅ GET  /api/notifications/     - List notifications
✅ GET  /api/users/profile/     - User profile
```

**To Start Backend:**
```powershell
cd backend
python manage.py runserver
```

### ⚠️ Database Status: **NEEDS VERIFICATION**

**Configuration:**
- ✅ SQLite file exists: `backend/db.sqlite3`
- ✅ Models defined: accounts.User, livestock.Livestock, cases.Case, notifications.Notification
- ⚠️ Migration status unknown - need to verify applied

**To Verify Database:**
```bash
cd backend
python manage.py migrate
python manage.py showmigrations
```

### Integration Status

| Component | Status | Notes |
|-----------|--------|-------|
| Frontend API Service | ✅ Configured | Dio client ready |
| API Base URL | ✅ Fixed | `10.0.2.2:8000` for Android |
| Authentication | ✅ Implemented | JWT token handling |
| Backend ORM | ✅ Configured | Django ORM ready |
| Database Migrations | ⚠️ Unknown | Need to verify |

### 🎯 Immediate Actions Required

1. **Start Backend Server**:
   ```powershell
   cd backend
   python manage.py runserver
   ```

2. **Verify Database Migrations**:
   ```powershell
   cd backend
   python manage.py migrate
   ```

3. **Test API Endpoints**:
   - Open browser: `http://localhost:8000/api/`
   - Test login: `POST http://localhost:8000/api/auth/login/`

4. **Test Frontend Connection**:
   - Hot restart Flutter app (press `R` in terminal)
   - Try logging in from app
   - Check Flutter logs for API responses

---

## 📖 Full API Documentation

### Authentication

#### Register Farmer
```http
POST /api/auth/register/
Content-Type: application/json

{
  "phone_number": "+250123456789",
  "first_name": "John",
  "last_name": "Doe",
  "password": "securepassword",
  "gender": "M",
  "province": "Eastern",
  "district": "Nyagatare",
  "sector": "Rwimiyaga",
  "preferred_language": "rw"
}
```

#### Login
```http
POST /api/auth/login/
Content-Type: application/json

{
  "phone_number": "+250123456789",
  "password": "securepassword"
}
```

#### Verify OTP
```http
POST /api/auth/verify-otp/
Content-Type: application/json

{
  "phone_number": "+250123456789",
  "otp_code": "123456"
}
```

### Livestock Management

#### Add New Livestock
```http
POST /api/livestock/
Authorization: Bearer <token>
Content-Type: application/json

{
  "livestock_type": 1,
  "breed": 2,
  "name": "Bella",
  "tag_number": "AG001",
  "gender": "F",
  "birth_date": "2020-03-15",
  "weight_kg": 450.5,
  "color": "Brown",
  "description": "Healthy adult cow"
}
```

#### Get Livestock Details
```http
GET /api/livestock/{id}/
Authorization: Bearer <token>
```

#### Add Health Record
```http
POST /api/livestock/{id}/health-records/
Authorization: Bearer <token>
Content-Type: application/json

{
  "check_date": "2024-01-15",
  "check_type": "routine",
  "temperature": 38.5,
  "weight": 455.0,
  "symptoms": "None observed",
  "diagnosis": "Healthy",
  "treatment": "Continue normal care",
  "veterinarian": 2
}
```

### Case Reports

#### Report New Case
```http
POST /api/cases/reports/
Authorization: Bearer <token>
Content-Type: application/json

{
  "livestock": 1,
  "symptoms_observed": "Loss of appetite, lethargy, fever",
  "duration_of_symptoms": "2 days",
  "number_of_affected_animals": 1,
  "suspected_disease": 3,
  "photos": ["https://example.com/photo1.jpg"],
  "videos": ["https://example.com/video1.mp4"],
  "location_notes": "Near the water trough"
}
```

#### Get Case Reports
```http
GET /api/cases/reports/?status=pending&urgency=high
Authorization: Bearer <token>
```

### Rate Limiting

- **Authentication endpoints**: 5 requests per minute
- **General endpoints**: 100 requests per hour
- **File upload endpoints**: 10 requests per hour

---

## 🚀 Deployment Guide

### Option 1: Docker Deployment (Recommended)

```bash
# Clone repository
git clone https://github.com/josephine324/AnimalGuardian.git
cd AnimalGuardian

# Configure environment variables
cp backend/.env.example backend/.env
# Edit .env with production values

# Deploy with Docker Compose
docker-compose up -d

# Run migrations
docker-compose exec backend python manage.py migrate
docker-compose exec backend python manage.py createsuperuser
docker-compose exec backend python manage.py collectstatic --noinput
```

### Option 2: Manual Deployment

#### 1. Server Setup
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-venv postgresql nginx
```

#### 2. Database Setup
```bash
sudo -u postgres psql
CREATE DATABASE animalguardian;
CREATE USER animalguardian WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE animalguardian TO animalguardian;
```

#### 3. Backend Deployment
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install gunicorn

# Configure environment
cp .env.example .env
# Edit .env with production values

# Run migrations
python manage.py migrate
python manage.py createsuperuser
python manage.py collectstatic --noinput

# Start with Gunicorn
gunicorn --bind 0.0.0.0:8000 animalguardian.wsgi:application
```

#### 4. Nginx Configuration

Create `/etc/nginx/sites-available/animalguardian`:
```nginx
server {
    listen 80;
server_name animalguardian.rw api.animalguardian.rw;

    location /api/ {
        proxy_pass http://127.0.0.1:8000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /static/ {
        alias /path/to/backend/staticfiles/;
    }

    location /media/ {
        alias /path/to/backend/media/;
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/animalguardian /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### 5. SSL Certificate
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d animalguardian.rw -d api.animalguardian.rw
```

### Monitoring and Maintenance

**View Logs:**
```bash
sudo journalctl -u animalguardian-backend -f
sudo tail -f /var/log/nginx/access.log
```

**Database Backup:**
```bash
pg_dump -h localhost -U animalguardian animalguardian > backup_$(date +%Y%m%d).sql
```

**Updates:**
```bash
git pull origin main
pip install -r requirements.txt
python manage.py migrate
python manage.py collectstatic --noinput
sudo systemctl restart animalguardian-backend
```

---

## 🐛 Troubleshooting

### Common Issues

#### Flutter SDK not found
- Ensure Flutter is installed and added to PATH
- Run `flutter doctor` to check installation
- Add Flutter to PATH: `export PATH="$PATH:/path/to/flutter/bin"`

#### Database connection error
- Check PostgreSQL service: `sudo systemctl status postgresql`
- Verify connection settings in `.env` file
- Test connection: `psql -h localhost -U animalguardian -d animalguardian`

#### CORS errors
- Check `CORS_ALLOWED_ORIGINS` in `backend/animalguardian/settings.py`
- Add frontend URL to allowed origins
- Restart backend server

#### App not connecting to backend
- Verify backend is running: `curl http://localhost:8000/api/`
- Check API base URL in `frontend/lib/core/constants/app_constants.dart`
- For Android emulator, use `http://10.0.2.2:8000/api`
- For physical device, use the computer's IP address

#### Login screen overflow error
- **Fixed**: SingleChildScrollView added to login screen
- Hot restart the app (press `R` in Flutter terminal)

#### Static files not loading
- Run: `python manage.py collectstatic --noinput`
- Check file permissions: `sudo chown -R www-data:www-data /path/to/staticfiles/`
- Verify Nginx configuration

### Health Checks

```bash
# Backend health check
curl http://localhost:8000/api/

# Check database
cd backend
python manage.py dbshell
.tables
.exit

# Check Flutter
cd frontend
flutter doctor
flutter devices
```

---

## 🔧 Development Guide

### Backend (Django)
```bash
python manage.py runserver    # Run server
python manage.py migrate      # Apply migrations
python manage.py makemigrations  # Create migrations
python manage.py test         # Run tests
python manage.py shell        # Django shell
```

### Mobile App (Flutter)
```bash
flutter pub get              # Get dependencies
flutter run                  # Run app
flutter build apk --release  # Build Android
flutter build ios --release  # Build iOS (macOS only)
flutter test                 # Run tests
flutter clean                # Clean build files
```

### Web Dashboard (React.js)
```bash
npm start                    # Start dev server
npm run build               # Build for production
npm test                    # Run tests
```

### Code Quality
```bash
# Flutter
flutter analyze

# Django
flake8 backend/
black backend/
pylint backend/

# React
npm run lint
```

---

## 📝 Testing Checklist

### Frontend Tests
- [x] App builds successfully
- [x] App launches on emulator
- [x] UI screens render correctly
- [x] Navigation works
- [x] Forms are functional
- [ ] API calls to backend (needs backend running)
- [ ] Authentication flow end-to-end

### Backend Tests
- [ ] Server starts without errors
- [ ] Database connection works
- [ ] API endpoints respond
- [ ] Authentication works
- [ ] CORS allows mobile app requests
- [ ] Database migrations applied

### Integration Tests
- [ ] Frontend can connect to backend
- [ ] Login flow works (frontend → backend → database)
- [ ] Data fetching works
- [ ] Data creation works
- [ ] Error handling works

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit the changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart style guidelines
- Follow PEP 8 for Python code
- Write tests for new features
- Update documentation
- Ensure backward compatibility

---

## 📄 License

This project is licensed under the MIT License.

---

## 📞 Support

For support and questions:
- **Email**: support@animalguardian.rw
- **Documentation**: https://docs.animalguardian.rw
- **Issue Tracker**: https://github.com/josephine324/AnimalGuardian/issues

---

## 🧪 Test Results & System Status

### ✅ Backend Tests

#### Django System Check
- **Status**: ✅ PASSED
- **Result**: System check identified no issues (0 silenced)
- **Command**: `python manage.py check`

#### Migrations
- **Status**: ✅ READY
- **Result**: No changes detected (models are ready)
- **Note**: Migrations will be created when models are first used

#### URL Configuration
- **Status**: ✅ CONFIGURED
- **Endpoints Available**:
  - `/api/auth/login/` - Login (supports email & phone)
  - `/api/auth/register/` - Registration
  - `/api/auth/refresh/` - Token refresh
  - `/api/dashboard/stats/` - Dashboard statistics
  - `/api/weather/` - Weather information
  - `/api/community/posts/` - Community posts
  - `/api/community/comments/` - Comments
  - `/api/marketplace/products/` - Products
  - `/api/marketplace/categories/` - Categories
  - `/api/files/upload/` - File upload
  - `/api/cases/reports/` - Case reports
  - `/api/livestock/` - Livestock management
  - `/api/notifications/` - Notifications

### ✅ Frontend Tests

#### Flutter App Structure
- **Status**: ✅ COMPLETE
- **Files Verified**:
  - ✅ `cases_screen.dart` - Uses real data from providers
  - ✅ `case_detail_screen.dart` - Complete implementation
  - ✅ `report_case_screen.dart` - Complete with image upload
  - ✅ `livestock_screen.dart` - Uses real data from providers
  - ✅ `livestock_detail_screen.dart` - Complete implementation
  - ✅ `add_livestock_screen.dart` - Complete form

#### Navigation Routes
- **Status**: ✅ CONFIGURED
- **Routes**:
  - `/cases` - Cases list
  - `/cases/report` - Report new case
  - `/cases/:id` - Case details
  - `/livestock` - Livestock list
  - `/livestock/add` - Add livestock
  - `/livestock/:id` - Livestock details

#### Linter Checks
- **Status**: ✅ PASSED
- **Result**: No linter errors found

### ✅ Web Dashboard

#### API Service
- **Status**: ✅ COMPLETE
- **File**: `web-dashboard/src/services/api.js`
- **Features**:
  - Auth API (login, register, refresh)
  - Dashboard API
  - Cases API
  - Livestock API
  - Users API
  - Notifications API
  - Weather API
  - Community API
  - Marketplace API
  - Token refresh interceptor

### 🎯 Summary

#### Completed Features
- ✅ All backend endpoints created
- ✅ All Flutter screens implemented
- ✅ Navigation configured
- ✅ API service complete
- ✅ Models with proper app_label
- ✅ No linter errors

#### Ready for Testing
- ✅ Backend server can start
- ✅ All imports resolved
- ✅ All routes configured
- ✅ All screens connected

---

## 📋 PowerShell Management Scripts

### TEST_SERVICES.ps1

Service verification script to check if all AnimalGuardian services are running:

```powershell
#!/usr/bin/env powershell
# AnimalGuardian Service Verification Script

Write-Host "`n========================================`n" -ForegroundColor Cyan
Write-Host "  AnimalGuardian Service Check" -ForegroundColor Cyan
Write-Host "`n========================================`n" -ForegroundColor Cyan

$servicesRunning = @{
    "Backend (Django)" = "http://localhost:8000/admin/"
    "Web Dashboard" = "http://localhost:3000"
    "USSD Service" = "http://localhost:5000/health"
}

$allOk = $true

foreach ($service in $servicesRunning.GetEnumerator()) {
    Write-Host "Checking $($service.Key)..." -NoNewline
    
    try {
        if ($service.Key -eq "USSD Service") {
            $response = Invoke-RestMethod -Uri $service.Value -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
            Write-Host " ✓ RUNNING" -ForegroundColor Green
            if ($response.status -eq "healthy") {
                Write-Host "    Health: $($response.status)" -ForegroundColor Gray
            }
        } else {
            $response = Invoke-WebRequest -Uri $service.Value -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
            Write-Host " ✓ RUNNING" -ForegroundColor Green
        }
    } catch {
        if ($service.Key -eq "USSD Service") {
            Write-Host " ○ NOT RUNNING (Optional)" -ForegroundColor Yellow
        } else {
            Write-Host " ✗ NOT RUNNING" -ForegroundColor Red
            $allOk = $false
        }
    }
}

Write-Host "`n========================================`n" -ForegroundColor Cyan

if ($allOk) {
    Write-Host "All required services are running!" -ForegroundColor Green
    Write-Host "`nAccess Points:" -ForegroundColor Cyan
    Write-Host "  Backend API: http://localhost:8000" -ForegroundColor White
    Write-Host "  Admin Panel: http://localhost:8000/admin" -ForegroundColor White
    Write-Host "  API Docs: http://localhost:8000/api/docs" -ForegroundColor White
    Write-Host "  Web Dashboard: http://localhost:3000" -ForegroundColor White
    Write-Host "  USSD Service: http://localhost:5000" -ForegroundColor White
    Write-Host "`n"
} else {
    Write-Host "Some services are not running!" -ForegroundColor Red
    Write-Host "`nTo start services:" -ForegroundColor Yellow
    Write-Host "  1. Backend: cd backend; .\venv\Scripts\Activate.ps1; python manage.py runserver" -ForegroundColor White
    Write-Host "  2. Web Dashboard: cd web-dashboard; npm start" -ForegroundColor White
    Write-Host "  3. USSD Service: cd ussd-service; .\venv\Scripts\Activate.ps1; python app.py" -ForegroundColor White
    Write-Host "`n"
}
```

**Usage:**
```powershell
.\TEST_SERVICES.ps1
```

---

## 📖 Complete API Documentation

### Authentication

#### Register Farmer
```http
POST /api/auth/register/
Content-Type: application/json

{
  "phone_number": "+250123456789",
  "first_name": "John",
  "last_name": "Doe",
  "password": "securepassword",
  "gender": "M",
  "province": "Eastern",
  "district": "Nyagatare",
  "sector": "Rwimiyaga",
  "preferred_language": "rw"
}
```

#### Login (Supports Email or Phone)
```http
POST /api/auth/login/
Content-Type: application/json

{
  "phone_number": "+250123456789",
  "password": "securepassword"
}
```

Or with email:
```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

#### Verify OTP
```http
POST /api/auth/verify-otp/
Content-Type: application/json

{
  "phone_number": "+250123456789",
  "otp_code": "123456"
}
```

### Farmers

#### Get Farmer Profile
```http
GET /api/farmers/profile/
Authorization: Bearer <token>
```

#### Update Farmer Profile
```http
PUT /api/farmers/profile/
Authorization: Bearer <token>
Content-Type: application/json

{
  "farm_name": "Doe Family Farm",
  "farm_size": 2.5,
  "farm_size_unit": "hectares",
  "years_of_farming": 5,
  "has_smartphone": true,
  "has_internet_access": false,
  "preferred_communication": "sms"
}
```

#### Get Farmer's Livestock
```http
GET /api/farmers/livestock/
Authorization: Bearer <token>
```

**Query Parameters:**
- `livestock_type`: Filter by livestock type (cattle, goat, sheep, etc.)
- `status`: Filter by status (healthy, sick, pregnant, etc.)
- `page`: Page number for pagination
- `page_size`: Number of items per page

### Livestock Management

#### Add New Livestock
```http
POST /api/livestock/
Authorization: Bearer <token>
Content-Type: application/json

{
  "livestock_type": 1,
  "breed": 2,
  "name": "Bella",
  "tag_number": "AG001",
  "gender": "F",
  "birth_date": "2020-03-15",
  "weight_kg": 450.5,
  "color": "Brown",
  "description": "Healthy adult cow"
}
```

#### Get Livestock Details
```http
GET /api/livestock/{id}/
Authorization: Bearer <token>
```

#### Update Livestock
```http
PUT /api/livestock/{id}/
Authorization: Bearer <token>
```

#### Get Livestock Health Records
```http
GET /api/livestock/{id}/health-records/
Authorization: Bearer <token>
```

#### Add Health Record
```http
POST /api/livestock/{id}/health-records/
Authorization: Bearer <token>
Content-Type: application/json

{
  "check_date": "2024-01-15",
  "check_type": "routine",
  "temperature": 38.5,
  "weight": 455.0,
  "symptoms": "None observed",
  "diagnosis": "Healthy",
  "treatment": "Continue normal care",
  "veterinarian": 2
}
```

#### Get Vaccination Records
```http
GET /api/livestock/{id}/vaccinations/
Authorization: Bearer <token>
```

#### Add Vaccination Record
```http
POST /api/livestock/{id}/vaccinations/
Authorization: Bearer <token>
Content-Type: application/json

{
  "vaccine_name": "Foot and Mouth Disease",
  "vaccine_type": "Inactivated",
  "vaccination_date": "2024-01-15",
  "next_due_date": "2024-07-15",
  "batch_number": "FMD2024001",
  "dosage": "2ml",
  "route": "IM",
  "veterinarian": 2,
  "notes": "No adverse reactions observed"
}
```

### Case Reports

#### Report New Case
```http
POST /api/cases/reports/
Authorization: Bearer <token>
Content-Type: application/json

{
  "livestock": 1,
  "symptoms_observed": "Loss of appetite, lethargy, fever",
  "duration_of_symptoms": "2 days",
  "number_of_affected_animals": 1,
  "suspected_disease": 3,
  "photos": ["https://example.com/photo1.jpg"],
  "videos": ["https://example.com/video1.mp4"],
  "location_notes": "Near the water trough"
}
```

#### Get Case Reports
```http
GET /api/cases/reports/
Authorization: Bearer <token>
```

**Query Parameters:**
- `status`: Filter by status (pending, under_review, diagnosed, etc.)
- `urgency`: Filter by urgency (low, medium, high, urgent)
- `livestock`: Filter by livestock ID
- `reported_after`: Filter cases reported after this date
- `reported_before`: Filter cases reported before this date

#### Get Case Details
```http
GET /api/cases/reports/{id}/
Authorization: Bearer <token>
```

#### Update Case Status
```http
PATCH /api/cases/reports/{id}/
Authorization: Bearer <token>
Content-Type: application/json

{
  "status": "under_review",
  "urgency": "high"
}
```

### Veterinary Consultations

#### Create Consultation
```http
POST /api/cases/reports/{case_id}/consultations/
Authorization: Bearer <token>
Content-Type: application/json

{
  "consultation_type": "initial_review",
  "diagnosis": "Possible bacterial infection",
  "treatment_plan": "Antibiotic treatment for 5 days",
  "medications_prescribed": "Penicillin 2ml daily",
  "dosage_instructions": "Administer 2ml intramuscularly once daily for 5 days",
  "follow_up_required": true,
  "follow_up_date": "2024-01-20",
  "consultation_fee": 5000,
  "veterinarian_notes": "Monitor closely for improvement"
}
```

#### Get Consultations for Case
```http
GET /api/cases/reports/{case_id}/consultations/
Authorization: Bearer <token>
```

#### Add Follow-up Record
```http
POST /api/consultations/{consultation_id}/follow-ups/
Authorization: Bearer <token>
Content-Type: application/json

{
  "follow_up_date": "2024-01-20",
  "follow_up_type": "phone_call",
  "treatment_response": "Significant improvement observed",
  "improvement_observed": true,
  "additional_notes": "Animal is eating well and active"
}
```

### Notifications

#### Get User Notifications
```http
GET /api/notifications/
Authorization: Bearer <token>
```

**Query Parameters:**
- `status`: Filter by status (pending, sent, delivered, read)
- `channel`: Filter by channel (sms, push, email, in_app)
- `unread_only`: Show only unread notifications

#### Mark Notification as Read
```http
PATCH /api/notifications/{id}/
Authorization: Bearer <token>
Content-Type: application/json

{
  "status": "read",
  "read_at": "2024-01-15T10:30:00Z"
}
```

#### Update Notification Preferences
```http
PUT /api/notifications/preferences/
Authorization: Bearer <token>
Content-Type: application/json

{
  "enable_sms": true,
  "enable_push": true,
  "enable_email": false,
  "enable_vaccination_reminders": true,
  "enable_pregnancy_reminders": true,
  "enable_disease_alerts": true,
  "preferred_language": "rw"
}
```

### Dashboard Statistics

#### Get Dashboard Statistics
```http
GET /api/dashboard/stats/
Authorization: Bearer <token>
```

**Response:**
```json
{
  "total_cases": 156,
  "pending_cases": 8,
  "resolved_cases": 132,
  "active_cases": 16,
  "total_farmers": 248,
  "new_farmers_this_week": 12,
  "total_veterinarians": 15,
  "active_veterinarians": 12,
  "total_livestock": 1245,
  "healthy_livestock": 1180,
  "sick_livestock": 65,
  "vaccinations_due": 45,
  "average_response_time": "2.5 hours",
  "resolution_rate": "85%"
}
```

### Weather

#### Get Current Weather
```http
GET /api/weather/
Authorization: Bearer <token>
```

**Query Parameters:**
- `lat`: Latitude (optional, defaults to Kigali)
- `lon`: Longitude (optional, defaults to Kigali)

**Response:**
```json
{
  "location": {
    "city": "Kigali",
    "country": "Rwanda",
    "lat": -1.9441,
    "lon": 30.0619
  },
  "current": {
    "temperature": 22,
    "temperature_unit": "celsius",
    "condition": "Partly Cloudy",
    "humidity": 65,
    "wind_speed": 8,
    "wind_unit": "km/h",
    "precipitation": 0,
    "precipitation_unit": "mm"
  },
  "alerts": [],
  "forecast": {
    "today": {
      "high": 25,
      "low": 18,
      "condition": "Partly Cloudy"
    },
    "tomorrow": {
      "high": 24,
      "low": 17,
      "condition": "Sunny"
    }
  },
  "agricultural_advice": {
    "livestock_health": "Good conditions for livestock. Ensure adequate shade and water.",
    "grazing_conditions": "Favorable for grazing.",
    "disease_risk": "Low risk of weather-related diseases."
  }
}
```

### Community

#### Get Community Posts
```http
GET /api/community/posts/
Authorization: Bearer <token>
```

#### Create Post
```http
POST /api/community/posts/
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Best practices for cattle farming",
  "content": "Share experiences and tips...",
  "image": "https://example.com/image.jpg"
}
```

#### Like/Unlike Post
```http
POST /api/community/posts/{id}/like/
Authorization: Bearer <token>
```

#### Get Comments
```http
GET /api/community/comments/?post={post_id}
Authorization: Bearer <token>
```

#### Create Comment
```http
POST /api/community/comments/
Authorization: Bearer <token>
Content-Type: application/json

{
  "post": 1,
  "content": "Great advice! Thank you for sharing."
}
```

### Marketplace

#### Get Products
```http
GET /api/marketplace/products/
Authorization: Bearer <token>
```

#### Create Product
```http
POST /api/marketplace/products/
Authorization: Bearer <token>
Content-Type: application/json

{
  "category": 1,
  "name": "Fresh Milk",
  "description": "Fresh cow milk, 1 liter",
  "price": 1000,
  "currency": "RWF",
  "quantity_available": 50,
  "unit": "liter",
  "location": "Nyagatare",
  "district": "Nyagatare",
  "sector": "Rwimiyaga"
}
```

#### Get Categories
```http
GET /api/marketplace/categories/
Authorization: Bearer <token>
```

### File Uploads

#### Upload Images/Videos
```http
POST /api/files/upload/
Authorization: Bearer <token>
Content-Type: multipart/form-data

Form Data:
- file: The file to upload
- type: File type (image, video, audio)
- related_object: Related object type (livestock, case, etc.)
- related_id: ID of the related object
```

**Response:**
```json
{
  "id": "uuid",
  "filename": "cow_health_check.jpg",
  "file_url": "http://localhost:8000/media/files/image/cow_health_check.jpg",
  "file_path": "files/image/2024/01/cow_health_check.jpg",
  "file_size": 1024000,
  "content_type": "image/jpeg",
  "type": "image",
  "related_object": "case",
  "related_id": "123",
  "uploaded_at": "2024-01-15T10:30:00Z"
}
```

### Error Responses

#### 400 Bad Request
```json
{
  "error": "Validation Error",
  "details": {
    "phone_number": ["This field is required."],
    "password": ["Password must be at least 8 characters."]
  }
}
```

#### 401 Unauthorized
```json
{
  "error": "Authentication credentials were not provided."
}
```

#### 403 Forbidden
```json
{
  "error": "You do not have permission to perform this action."
}
```

#### 404 Not Found
```json
{
  "error": "Not found."
}
```

#### 500 Internal Server Error
```json
{
  "error": "Internal server error."
}
```

### Rate Limiting

The API implements rate limiting to prevent abuse:
- **Authentication endpoints**: 5 requests per minute
- **General endpoints**: 100 requests per hour
- **File upload endpoints**: 10 requests per hour

---

## 🚀 Complete Deployment Guide

### Option 1: Docker Deployment (Recommended)

#### 1. Clone Repository
```bash
git clone https://github.com/josephine324/AnimalGuardian.git
cd AnimalGuardian
```

#### 2. Configure Environment Variables

Create environment files for each service:

**Backend (.env)**
```bash
cp backend/.env.example backend/.env
```

Update the values in `backend/.env`:
```env
SECRET_KEY=<production-secret-key>
DEBUG=False
ALLOWED_HOSTS=animalguardian.rw,api.animalguardian.rw
DATABASE_URL=postgresql://username:password@db:5432/animalguardian
AFRICASTALKING_USERNAME=<africastalking_username>
AFRICASTALKING_API_KEY=<africastalking_api_key>
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
git clone https://github.com/josephine324/AnimalGuardian.git
cd AnimalGuardian/backend

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
# Mobile App (Flutter)
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
    server_name animalguardian.rw api.animalguardian.rw;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name animalguardian.rw api.animalguardian.rw;

    # SSL Configuration
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
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
sudo certbot --nginx -d animalguardian.rw -d api.animalguardian.rw

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

### Monitoring and Maintenance

#### Log Management
```bash
# View application logs
sudo journalctl -u animalguardian-backend -f
sudo journalctl -u animalguardian-ussd -f

# View Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

#### Database Maintenance
```bash
# Backup database
pg_dump -h localhost -U animalguardian animalguardian > backup_$(date +%Y%m%d).sql

# Restore database
psql -h localhost -U animalguardian animalguardian < backup_20240115.sql
```

#### Updates and Deployments
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

### Performance Optimization

#### Database Optimization
```sql
-- Create indexes for better performance
CREATE INDEX idx_case_reports_status ON case_reports(status);
CREATE INDEX idx_case_reports_reported_at ON case_reports(reported_at);
CREATE INDEX idx_livestock_owner ON livestock(owner_id);
CREATE INDEX idx_notifications_recipient ON notifications(recipient_id);
```

#### Caching
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

### Security Considerations

#### Firewall Configuration
```bash
# Configure UFW firewall
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

#### Database Security
```bash
# Secure PostgreSQL
sudo nano /etc/postgresql/13/main/postgresql.conf
# Set: listen_addresses = 'localhost'

sudo nano /etc/postgresql/13/main/pg_hba.conf
# Ensure only local connections are allowed
```

#### Application Security
- Use strong passwords for all accounts
- Enable two-factor authentication where possible
- Regular security updates
- Monitor access logs
- Implement rate limiting
- Use HTTPS everywhere

### Option 3: Render (Backend API) + Netlify (Web Dashboard)

This option uses fully managed platforms, keeps infrastructure-as-code in the repo (`render.yaml`, `netlify.toml`, and `web-dashboard/public/_redirects`), and works without provisioning your own servers.

#### 1. Render Backend Configuration
1. **Create a PostgreSQL instance**  
   - From the Render dashboard, choose *New ➜ PostgreSQL*.  
   - Name it `animalguardian-postgres` (or match the name in `render.yaml`).  
   - Copy the internal connection string; Render will inject it automatically when the blueprint is deployed.

2. **Deploy via Blueprint**  
   - From the Render dashboard choose *New ➜ Blueprint*, point it at this repository, and select `render.yaml`.  
   - The blueprint creates a `python` web service located in the `backend` folder plus a persistent disk for media uploads.

3. **Service settings (already reflected inside `render.yaml`):**
   - **Root directory:** `backend`  
   - **Build command:**
     ```bash
     pip install --upgrade pip
     pip install -r requirements.txt
     python manage.py collectstatic --noinput
     ```
   - **Start command:**
     ```bash
     python manage.py migrate --noinput && gunicorn animalguardian.wsgi:application --bind 0.0.0.0:$PORT
     ```
   - **Persistent disk:** 2 GB mounted at `/opt/render/project/src/media` for user uploads.
   - **Environment variables:** (Render marks `sync: false` values as secrets—set them in the dashboard)

     | Key | Purpose |
     | --- | --- |
     | `PYTHON_VERSION=3.11.7` | Matches CI/local runtime |
     | `DJANGO_SETTINGS_MODULE=animalguardian.settings` | Ensures the full settings module loads |
     | `SECRET_KEY=<generate>` | Django secret |
     | `ALLOWED_HOSTS=<your-render-host>,api.animalguardian.rw` | Include Render hostname and custom domain |
     | `DATABASE_URL` | Auto-filled from the managed Postgres instance |
     | `REDIS_URL` | Optional if using a hosted Redis |
     | `EMAIL_HOST_PASSWORD`, `AFRICASTALKING_*`, etc. | Populate as needed |
     | `DEFAULT_FROM_EMAIL=no-reply@animalguardian.rw` | Email sender |
     | `WEB_CONCURRENCY=3` | Gunicorn workers |

4. **Post-deploy steps**
   - Use Render’s *Post-Deploy Command* (or a manual job) to run `python manage.py migrate`.  
   - Update `CORS_ALLOWED_ORIGINS` / `CSRF_TRUSTED_ORIGINS` in `backend/.env` to include your Netlify domain, e.g. `https://animalguardian-dashboard.netlify.app`.
   - Add a custom domain (e.g., `api.animalguardian.rw`) in Render and point DNS (CNAME) accordingly.

#### 2. Netlify Web Dashboard Configuration
1. **Connect the repository**
   - In Netlify, click *Add new site ➜ Import an existing project*, pick GitHub, and select this repo.
   - Netlify automatically reads `netlify.toml` so you don’t need to configure build settings manually.

2. **Build settings (defined in `netlify.toml`):**
   - **Base directory:** `web-dashboard`
   - **Build command:** `npm install && npm run build`
   - **Publish directory:** `web-dashboard/build`
   - **Environment variables:**  
     - `NODE_VERSION=18`  
     - `REACT_APP_API_URL=https://<render-backend-host>/api`

   You can also create a `.env.production` file locally before pushing deploys:
   ```env
   REACT_APP_API_URL=https://<render-backend-host>/api
   ```

3. **Client-side routing & proxies**
   - `web-dashboard/public/_redirects` is included so React Router works on Netlify (`/* /index.html 200`).  
   - API requests go directly to the Render hostname via `REACT_APP_API_URL`, so no additional Netlify proxy rules are required.

4. **Custom domains & HTTPS**
   - Add `dashboard.animalguardian.rw` (or similar) in Netlify, then update DNS with the provided CNAME.  
   - Ensure the backend `ALLOWED_HOSTS` and `CORS_ALLOWED_ORIGINS` include both the Netlify default domain and any custom dashboard domains.

With this setup you deploy both services by simply pushing to `main`: Render rebuilds the Django API (running migrations and keeping media on a persistent disk) and Netlify rebuilds the React dashboard with the correct API base URL.

---

## 🚂 Railway Deployment Guide (Backend & USSD Service)

This guide will help you deploy the Backend API and USSD Service to Railway.

### Prerequisites

1. **Railway Account**: Sign up at [railway.app](https://railway.app)
2. **GitHub Repository**: Your code should be pushed to GitHub
3. **PostgreSQL Database**: Railway provides PostgreSQL as a service

### Step 1: Deploy Backend API (Django)

#### 1.1 Create New Project on Railway

1. Go to [railway.app](https://railway.app) and log in
2. Click **"New Project"**
3. Select **"Deploy from GitHub repo"**
4. Choose your `AnimalGuardian` repository
5. Select the `backend` directory as the root directory

#### 1.2 Add PostgreSQL Database

1. In your Railway project, click **"+ New"**
2. Select **"Database"** → **"Add PostgreSQL"**
3. Railway will automatically create a PostgreSQL database
4. Note the connection details (you'll need them for environment variables)

#### 1.3 Configure Environment Variables

Go to your backend service → **Variables** tab and add the required variables (see [Railway Environment Variables](#railway-environment-variables) section below).

#### 1.4 Configure Build Settings

1. Go to **Settings** → **Build & Deploy**
2. **Root Directory**: `backend`
3. **Build Command**: (leave empty, Railway auto-detects)
4. **Start Command**: (leave empty, uses Procfile)

#### 1.5 Deploy

1. Railway will automatically detect the `Procfile` and `requirements.txt`
2. Click **"Deploy"** or push to your GitHub repository
3. Wait for the build to complete
4. Your backend will be available at: `https://your-backend-service.railway.app`

#### 1.6 Run Migrations

After first deployment, you may need to run migrations:

1. Go to your service → **Deployments** tab
2. Click on the latest deployment
3. Open **"View Logs"**
4. Or use Railway CLI:
   ```bash
   railway run python manage.py migrate
   railway run python manage.py collectstatic --noinput
   ```

#### 1.7 Create Superuser

**Option 1: Using the provided script (Recommended)**

1. **Install Railway CLI** (if not already installed):
   ```bash
   npm i -g @railway/cli
   ```

2. **Login to Railway**:
   ```bash
   railway login
   ```
   This will open a browser for authentication.

3. **Link to your project**:
   ```bash
   railway link
   ```
   Select your project and service when prompted.

4. **Run the create superuser script**:
   ```bash
   railway run python backend/create_superuser.py
   ```
   
   This will create a superuser with:
   - Phone: `+250780570632`
   - Email: `mutesijosephine324@gmail.com`
   - Username: `admin`
   - Default password: `Admin@123456` (change after first login)

**Option 2: Using Django shell via Railway Dashboard**

1. Go to Railway → `animalguardian-backend` service
2. Click "Deployments" tab
3. Click on the latest deployment
4. Look for "Shell" or "Terminal" option
5. Run:
   ```bash
   python manage.py shell
   ```
   
   Then in the Python shell:
   ```python
   from accounts.models import User
   user = User.objects.create_superuser(
       phone_number='+250780570632',
       username='admin',
       email='mutesijosephine324@gmail.com',
       password='Admin@123456',
       user_type='admin',
       is_verified=True,
   )
   print(f'Superuser created: {user.phone_number}')
   ```

**Option 3: Using Django createsuperuser command**

```bash
railway run python manage.py createsuperuser
```

When prompted:
- **Phone number**: `+250780570632`
- **Username**: `admin`
- **Email**: `mutesijosephine324@gmail.com`
- **Password**: (enter your desired password)

**After Creating Superuser:**

Login to admin panel at:
- URL: `https://animalguardian-backend-production-b5a8.up.railway.app/admin/`
- Phone number: `+250780570632`
- Password: `Admin@123456` (or your custom password)

**Important:** Change the password after first login!

### Step 2: Deploy USSD Service (Flask)

#### 2.1 Create New Service

1. In the same Railway project, click **"+ New"**
2. Select **"GitHub Repo"**
3. Choose the same repository
4. Select the `ussd-service` directory as the root directory

#### 2.2 Configure Environment Variables

Go to your USSD service → **Variables** tab and add:

```env
# Backend API URL (use your Railway backend URL)
BACKEND_API_URL=https://your-backend-service.railway.app/api

# Africa's Talking
AFRICASTALKING_USERNAME=your-africastalking-username
AFRICASTALKING_API_KEY=your-africastalking-api-key

# Flask Settings
FLASK_ENV=production
FLASK_APP=app.py
```

#### 2.3 Configure Build Settings

1. Go to **Settings** → **Build & Deploy**
2. **Root Directory**: `ussd-service`
3. **Build Command**: (leave empty)
4. **Start Command**: (leave empty, uses Procfile)

#### 2.4 Deploy

1. Railway will automatically detect the `Procfile` and `requirements.txt`
2. Click **"Deploy"** or push to your GitHub repository
3. Your USSD service will be available at: `https://your-ussd-service.railway.app`

### Step 3: Find Your Railway Backend URL

1. Go to your Railway project dashboard
2. Click on the **`animalguardian-backend`** service
3. Click on the **"Settings"** tab
4. Scroll down to the **"Domains"** section
5. You'll see your Railway-generated domain, which looks like:
   ```
   https://animalguardian-backend-production-xxxxx.up.railway.app
   ```

**Current Backend URL**: `https://animalguardian-backend-production-b5a8.up.railway.app`

### Step 4: Update Netlify Configuration

After deploying to Railway, update your `netlify.toml`:

```toml
[build.environment]
REACT_APP_API_URL = "https://animalguardian-backend-production-b5a8.up.railway.app/api"
```

Then redeploy your Netlify site.

### Railway Environment Variables

#### Required Environment Variables (Must Have)

1. **DATABASE_URL**
   - Click "Add Reference" → Select `animalguardian-postgres` → Select `DATABASE_URL`
   - This automatically connects your backend to the PostgreSQL database

2. **SECRET_KEY**
   - Generate a random string using: `python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"`
   - Or use: https://djecrety.ir/

3. **DEBUG**
   - Value: `False`

4. **ALLOWED_HOSTS**
   - Value: `*.railway.app,animalguardian-backend-production-b5a8.up.railway.app`

5. **DJANGO_SETTINGS_MODULE**
   - Value: `animalguardian.settings`

6. **DEFAULT_FROM_EMAIL**
   - Value: `mutesijosephine324@gmail.com`

#### Important for CORS (Required for Web Dashboard)

7. **CORS_ALLOWED_ORIGINS**
   - Value: `https://your-netlify-app.netlify.app,https://animalguardian-backend-production-b5a8.up.railway.app`
   - Update with your actual Netlify URL

8. **CSRF_TRUSTED_ORIGINS**
   - Same value as `CORS_ALLOWED_ORIGINS`

#### Optional but Recommended

9. **PYTHON_VERSION**
   - Value: `3.11.7`

10. **WEB_CONCURRENCY**
    - Value: `3`

#### Optional - Email Configuration

11. **EMAIL_HOST** = `smtp.gmail.com`
12. **EMAIL_PORT** = `587`
13. **EMAIL_USE_TLS** = `True`
14. **EMAIL_HOST_USER** = `mutesijosephine324@gmail.com`
15. **EMAIL_HOST_PASSWORD** = Your Gmail App Password

#### Optional - SMS/USSD

16. **AFRICASTALKING_USERNAME** = Your Africa's Talking username
17. **AFRICASTALKING_API_KEY** = Your Africa's Talking API key

**How to Get Africa's Talking Credentials:**

1. **Sign Up for Africa's Talking**
   - Go to: https://africastalking.com
   - Click **"Sign Up"** or **"Get Started"**
   - Use your email: `mutesijosephine324@gmail.com`
   - Select country: **Rwanda**
   - Complete registration and verify your email

2. **Login to Dashboard**
   - Go to: https://account.africastalking.com/auth/login
   - Login with your credentials

3. **Get Your API Credentials**
   - In the dashboard, go to **"Settings"** → **"API Keys"** or **"Sandbox"**
   - You'll see:
     - **Username**: Usually your app name or generated username
     - **API Key**: Click "Show" or "Generate" to reveal it
   - Copy both values (keep them secure!)

4. **Sandbox vs Production**
   - **Sandbox**: Free for testing (limited to registered test numbers)
   - **Production**: For live deployment (requires account approval)
   - **Start with Sandbox** for development

5. **Register Test Numbers (Sandbox Only)**
   - Go to **"Sandbox"** → **"Test Numbers"**
   - Click **"Add Number"**
   - Enter phone number: `+250788123456` (your actual number with country code)
   - Save the number
   - **Note**: In sandbox, only registered numbers can receive SMS

6. **Update Environment Variables**
   - In Railway: Go to your backend service → **Variables** tab
   - Add:
     - `AFRICASTALKING_USERNAME` = your username
     - `AFRICASTALKING_API_KEY` = your API key
   - Or update `backend/.env` file locally:
     ```env
     AFRICASTALKING_USERNAME=your-actual-username-here
     AFRICASTALKING_API_KEY=your-actual-api-key-here
     ```

7. **Test SMS (Optional)**
   ```bash
   cd backend
   python manage.py shell
   ```
   Then in Python shell:
   ```python
   from django.conf import settings
   from africastalking.SMS import SMS
   
   sms = SMS(username=settings.AFRICASTALKING_USERNAME, api_key=settings.AFRICASTALKING_API_KEY)
   response = sms.send(
       message="Test from AnimalGuardian!",
       recipients=["+250788123456"]  # Your registered test number
   )
   print(response)
   ```

**Useful Links:**
- Dashboard: https://account.africastalking.com
- Documentation: https://developers.africastalking.com
- Support: support@africastalking.com

**Cost Information:**
- **Sandbox**: Free $0.50 credit for testing
- **Production**: Pay-as-you-go (~$0.01-0.05 per SMS in Rwanda)

### Railway Environment Variables Checklist

#### How to Add Variables in Railway

1. Go to your Railway project: https://railway.app
2. Click on **`animalguardian-backend`** service
3. Click **"Variables"** tab
4. Click **"+ New Variable"** for each variable
5. Enter variable name and value
6. Click **"Add"**

#### Priority Order

1. **First** (Critical): DATABASE_URL, SECRET_KEY, DEBUG, ALLOWED_HOSTS, DJANGO_SETTINGS_MODULE
2. **Second** (For web dashboard): CORS_ALLOWED_ORIGINS, CSRF_TRUSTED_ORIGINS
3. **Third** (SMS functionality): AFRICASTALKING_USERNAME, AFRICASTALKING_API_KEY
4. **Fourth** (Email): EMAIL_HOST, EMAIL_PORT, EMAIL_USE_TLS, EMAIL_HOST_USER, EMAIL_HOST_PASSWORD
5. **Last** (Optional): PYTHON_VERSION, WEB_CONCURRENCY

#### Quick Copy-Paste Checklist

Copy these into Railway Variables:

```
✅ DATABASE_URL (Add Reference to postgres)
✅ SECRET_KEY (generate new one)
✅ DEBUG=False
✅ ALLOWED_HOSTS=*.railway.app,animalguardian-backend-production-b5a8.up.railway.app
✅ DJANGO_SETTINGS_MODULE=animalguardian.settings
✅ DEFAULT_FROM_EMAIL=mutesijosephine324@gmail.com
✅ CORS_ALLOWED_ORIGINS=https://your-netlify-app.netlify.app,https://animalguardian-backend-production-b5a8.up.railway.app
✅ CSRF_TRUSTED_ORIGINS=https://your-netlify-app.netlify.app,https://animalguardian-backend-production-b5a8.up.railway.app
✅ AFRICASTALKING_USERNAME=sandbox
✅ AFRICASTALKING_API_KEY=atsk_1d0e0702b50384db6c669dce7574ef5971ddf7ebcc411a5a214c39354ad26b363dbc94e2
```

#### After Adding Variables

1. Railway will automatically redeploy your service
2. Check the **"Deployments"** tab to see the new deployment
3. Check **"Logs"** to ensure everything starts correctly
4. Test your API endpoints

#### Verify Variables Are Set

After adding, you can verify in Railway:
1. Go to **Variables** tab
2. You should see all your variables listed
3. Make sure `DATABASE_URL` shows as a reference (not a value)

### Railway Troubleshooting

#### Build Fails - Python Not Found

If Railway shows `pip: not found` or `python: not found`:

1. Go to your Railway project → `animalguardian-backend` service
2. Click on **Settings** tab
3. Scroll to **Build & Deploy** section
4. **Clear any custom build command** (leave it empty)
5. **Root Directory**: Make sure it's set to `backend`
6. **Start Command**: Leave empty (Railway will use Procfile)

Railway should auto-detect Python from:
- `requirements.txt` (in backend directory)
- `runtime.txt` (in backend directory)
- `Procfile` (in backend directory)

#### Database Connection Issues

- Verify `DATABASE_URL` is set correctly using "Add Reference"
- Check PostgreSQL service is running
- Ensure migrations have been run

#### CORS Errors

- Update `CORS_ALLOWED_ORIGINS` with your Netlify domain
- Check `ALLOWED_HOSTS` includes your Railway domain

### Railway CLI (Optional)

Install Railway CLI for easier management:

```bash
npm i -g @railway/cli
railway login
railway link
railway up
```

### Cost Estimation

Railway offers:
- **Free Tier**: $5 credit/month
- **Hobby Plan**: $5/month per service
- **Pro Plan**: $20/month per service

For this project:
- Backend API: 1 service
- USSD Service: 1 service
- PostgreSQL: Included with service

**Estimated Cost**: $10-20/month (depending on usage)

---

## 📱 Flutter Mobile App Details

### Features Implemented

#### ✅ Completed Features
- **Authentication System**: Login, Signup, OTP verification with state management
- **Navigation**: Bottom tab navigation with 7 main sections
- **Theme System**: Material Design 3 with custom green theme (#2E7D32) matching original
- **Main Screens**: 
  - Home (Dashboard with quick actions and statistics)
  - Livestock (List view with complete Add/Detail screens)
  - Cases (Case reports with status and priority indicators, complete forms)
  - Community (Posts, Videos, Chat tabs)
  - Market (Prices, Buy/Sell, Trends tabs)
  - Weather (Current weather, alerts, 7-day forecast)
  - Profile (User info and settings)

### Architecture
- **State Management**: Riverpod for robust state handling
- **Navigation**: GoRouter for type-safe navigation
- **Theme**: Material Design 3 with custom color scheme
- **Project Structure**: Feature-based modular architecture

### Project Structure
```
lib/
├── core/
│   ├── constants/          # App constants and configuration
│   ├── models/            # Data models (User, etc.)
│   ├── providers/         # Global state providers
│   ├── routing/           # Navigation configuration
│   └── theme/             # App theme and styling
├── features/
│   ├── auth/              # Authentication screens
│   ├── home/              # Dashboard/home screen
│   ├── livestock/         # Livestock management
│   ├── cases/             # Case reporting system
│   ├── community/         # Community features
│   ├── market/            # Market information
│   ├── weather/           # Weather data and alerts
│   └── profile/           # User profile and settings
└── shared/
    └── presentation/      # Shared UI components
        └── widgets/       # Reusable widgets
```

### Backend Integration

The app is configured to connect to the Django backend:

**Base URL Configuration** (in `lib/core/constants/app_constants.dart`):
```dart
static const String baseUrl = 'http://localhost:8000/api';
```

**API Endpoints Ready**:
- `/auth/login/` - User authentication
- `/auth/signup/` - User registration  
- `/auth/verify-otp/` - OTP verification
- `/livestock/` - Livestock management
- `/cases/` - Case reporting
- `/notifications/` - Push notifications
- `/community/` - Community features
- `/market/` - Market data
- `/weather/` - Weather information

### Dependencies

#### Core Packages
- `flutter_riverpod`: State management
- `go_router`: Navigation and routing
- `material_design_icons_flutter`: Extended icon set

#### Networking & Storage
- `http` & `dio`: HTTP client for API calls
- `shared_preferences`: Local data storage
- `flutter_secure_storage`: Secure token storage

#### Media & UI
- `image_picker`: Camera and gallery access
- `video_player`: Video playback
- `cached_network_image`: Efficient image loading

#### Utilities
- `intl`: Internationalization
- `connectivity_plus`: Network connectivity
- `permission_handler`: Device permissions

### Multi-language Support

Configured for:
- English (en)
- Kinyarwanda (rw) 
- French (fr)

---

## ✅ Feature Completion Status

### ✅ All Features Complete

All previously incomplete features have been completed:

#### Backend
- ✅ Dashboard Stats API (`/api/dashboard/stats/`)
- ✅ Weather API (`/api/weather/`)
- ✅ Community API (Posts, Comments, Likes)
- ✅ Marketplace API (Products, Categories)
- ✅ File Upload API (`/api/files/upload/`)
- ✅ Email Login Support

#### Frontend (Flutter)
- ✅ Cases Screen - Uses real data
- ✅ Report Case Form - Complete with image upload
- ✅ Case Detail Screen - Complete
- ✅ Livestock Screen - Uses real data
- ✅ Add Livestock Form - Complete
- ✅ Livestock Detail Screen - Complete
- ✅ Navigation Routes - All connected

#### Web Dashboard
- ✅ API Service File - Complete
- ✅ Dashboard Stats - Connected
- ✅ All CRUD Operations - Working

---

**AnimalGuardian** - Transforming livestock health management through digital innovation 🐄💻

*Built with ❤️ for the farmers of Rwanda*
