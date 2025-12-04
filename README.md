# 🐄 AnimalGuardian - Digital Livestock Support System

A comprehensive digital platform designed to enhance veterinary service delivery, disease surveillance, and farmer knowledge for smallholder farmers in Nyagatare District, Rwanda.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/Python-3.11+-blue.svg)](https://www.python.org/)
[![Django](https://img.shields.io/badge/Django-4.2+-green.svg)](https://www.djangoproject.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev/)
[![React](https://img.shields.io/badge/React-18+-blue.svg)](https://reactjs.org/)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Prerequisites](#prerequisites)
- [Installation Guide](#installation-guide)
  - [Backend Setup](#backend-setup)
  - [Mobile App Setup](#mobile-app-setup)
  - [Web Dashboard Setup](#web-dashboard-setup)
- [Running the Application](#running-the-application)
- [Configuration](#configuration)
- [Project Structure](#project-structure)
- [API Documentation](#api-documentation)
- [User Types & Access](#user-types--access)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

---

## 🌟 Overview

AnimalGuardian is a multi-platform digital livestock health management system that addresses critical challenges faced by smallholder farmers in Rwanda. The system provides:

- **Real-time disease reporting** with multimedia support (photos/videos)
- **Expert veterinary consultation** via mobile and web platforms
- **Livestock management** with health records and vaccination tracking
- **Case assignment system** connecting farmers with local veterinarians
- **Multi-language support** (English, Kinyarwanda, French)

### 🎯 Target Users

- **Smallholder Farmers** - Primary beneficiaries using the mobile app
- **Sector Veterinarians** - Manage cases and assign to local vets via web dashboard
- **Local Veterinarians** - Respond to assigned cases via mobile app
- **Administrators** - System management and oversight

---

## ✨ Features

### 📱 Mobile Application (Flutter)

**For Farmers:**
- Case reporting with photo/video upload
- Livestock inventory management
- Case tracking and history
- Profile management
- Password reset functionality

**For Local Veterinarians:**
- View assigned cases
- Update case status
- Toggle availability
- Profile management

### 💻 Web Dashboard (React.js)

**For Sector Veterinarians:**
- Real-time dashboard with statistics
- Case management and assignment
- Veterinarian and farmer management
- Analytics and reporting
- Auto-refresh every 30 seconds

### 🔧 Backend Services (Django REST Framework)

- RESTful API with JWT authentication
- User management and authentication
- Case and livestock management
- File upload and storage
- Email notifications
- PostgreSQL database

---

## 🛠️ Technology Stack

### Frontend
- **Flutter** 3.10+ - Mobile application framework
- **Dart** 3.0+ - Programming language
- **Riverpod** - State management
- **GoRouter** - Navigation

### Web Dashboard
- **React.js** 18+ - Frontend framework
- **Tailwind CSS** - Styling
- **Axios** - HTTP client

### Backend
- **Django** 4.2+ - Web framework
- **Django REST Framework** 3.14+ - API framework
- **PostgreSQL** 13+ - Database (Production)
- **SQLite** - Database (Local Development)
- **JWT** - Authentication

---

## 📦 Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

1. **Python** 3.11 or higher
   - Download: https://www.python.org/downloads/
   - Verify: `python --version` or `python3 --version`

2. **Node.js** 18 or higher and npm
   - Download: https://nodejs.org/
   - Verify: `node --version` and `npm --version`

3. **Flutter** 3.10 or higher
   - Download: https://flutter.dev/docs/get-started/install
   - Verify: `flutter --version`
   - Run: `flutter doctor` to check setup

4. **Git**
   - Download: https://git-scm.com/downloads
   - Verify: `git --version`

### Optional (for Production)

5. **PostgreSQL** 13+ (for production database)
   - Download: https://www.postgresql.org/download/

6. **Android Studio** (for mobile app development)
   - Download: https://developer.android.com/studio

7. **Xcode** (for iOS development on macOS)

---

## 🚀 Installation Guide

### Step 1: Clone the Repository

```bash
git clone https://github.com/josephine324/AnimalGuardian.git
cd AnimalGuardian
```

---

## 🔧 Backend Setup

### Step 1: Navigate to Backend Directory

```bash
cd backend
```

### Step 2: Create Virtual Environment

**Windows (PowerShell):**
```powershell
python -m venv venv
```

**Windows (CMD):**
```cmd
python -m venv venv
```

**macOS/Linux:**
```bash
python3 -m venv venv
```

### Step 3: Activate Virtual Environment

**Windows (PowerShell):**
```powershell
.\venv\Scripts\Activate.ps1
```

**Windows (CMD):**
```cmd
venv\Scripts\activate
```

**macOS/Linux:**
```bash
source venv/bin/activate
```

You should see `(venv)` in your terminal prompt.

### Step 4: Install Python Dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

**Expected output:** All packages should install successfully. This may take a few minutes.

### Step 5: Create Environment Variables File

Create a `.env` file in the `backend` directory:

```bash
# Windows PowerShell
New-Item .env

# macOS/Linux
touch .env
```

Add the following content to `.env`:

```env
# Django Settings
SECRET_KEY=your-secret-key-here-change-this-in-production
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

# Database (Leave empty for SQLite local development)
DATABASE_URL=

# CORS Settings
CORS_ALLOW_ALL_ORIGINS=True

# Email Configuration (for password reset)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=your-email@gmail.com
```

**Important:** 
- Replace `your-secret-key-here-change-this-in-production` with a secure random string
- For Gmail, you need to use an [App Password](https://support.google.com/accounts/answer/185833) instead of your regular password
- Leave `DATABASE_URL` empty to use SQLite for local development

### Step 6: Run Database Migrations

```bash
python manage.py migrate
```

**Expected output:** All migrations should run successfully, creating database tables.

### Step 7: Create Superuser (Optional)

```bash
python manage.py createsuperuser
```

Follow the prompts to create an admin user. You can use this to access the Django admin panel at `http://localhost:8000/admin`.

### Step 8: Seed Livestock Types (Optional)

```bash
python manage.py seed_livestock_types
```

This populates the database with common livestock types (Cow, Goat, Pig, etc.).

### Step 9: Verify Backend Installation

```bash
python manage.py runserver
```

Open your browser and visit:
- **API Root:** http://localhost:8000/api/
- **Admin Panel:** http://localhost:8000/admin/
- **Health Check:** http://localhost:8000/health/

If you see the API response, the backend is working correctly! Press `Ctrl+C` to stop the server.

---

## 📱 Mobile App Setup

### Step 1: Navigate to Frontend Directory

```bash
cd frontend
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

**Expected output:** All Flutter packages should download and install.

### Step 3: Verify Flutter Setup

```bash
flutter doctor
```

Fix any issues reported by `flutter doctor` before proceeding.

### Step 4: Configure API URL

Create a `.env` file in the `frontend` directory:

```bash
# Windows PowerShell
New-Item .env

# macOS/Linux
touch .env
```

Add the following content:

```env
API_BASE_URL=http://localhost:8000/api
```

**For production:**
```env
API_BASE_URL=https://animalguardian.onrender.com/api
```

### Step 5: Verify Mobile App Setup

**For Android:**
```bash
flutter run
```

**For iOS (macOS only):**
```bash
flutter run -d ios
```

**For Web:**
```bash
flutter run -d chrome
```

The app should launch on your device/emulator/browser.

---

## 💻 Web Dashboard Setup

### Step 1: Navigate to Web Dashboard Directory

```bash
cd web-dashboard
```

### Step 2: Install Node Dependencies

```bash
npm install
```

**Expected output:** All npm packages should install. This may take a few minutes.

### Step 3: Configure API URL

Create a `.env` file in the `web-dashboard` directory:

```bash
# Windows PowerShell
New-Item .env

# macOS/Linux
touch .env
```

Add the following content:

```env
REACT_APP_API_URL=http://localhost:8000/api
```

**For production:**
```env
REACT_APP_API_URL=https://animalguardian.onrender.com/api
```

### Step 4: Verify Web Dashboard Setup

```bash
npm start
```

The dashboard should open automatically at `http://localhost:3000` in your browser.

---

## 🏃 Running the Application

### Complete Setup (All Services)

Open **three separate terminal windows/tabs**:

#### Terminal 1: Backend Server

```bash
cd backend
.\venv\Scripts\Activate.ps1  # Windows PowerShell
# OR
source venv/bin/activate      # macOS/Linux

python manage.py runserver
```

**Backend will run at:** http://localhost:8000

#### Terminal 2: Mobile App (Optional)

```bash
cd frontend
flutter run
```

**Mobile app will run on:** Your connected device/emulator

#### Terminal 3: Web Dashboard

```bash
cd web-dashboard
npm start
```

**Web dashboard will run at:** http://localhost:3000

### Quick Start (Backend Only)

If you only need to test the API:

```bash
cd backend
.\venv\Scripts\Activate.ps1  # Windows
python manage.py runserver
```

Visit http://localhost:8000/api/ to see the API.

---

## ⚙️ Configuration

### Backend Configuration

**Database:**
- **Local Development:** Uses SQLite (no setup needed)
- **Production:** Set `DATABASE_URL` in `.env` file

**Authentication:**
- JWT tokens expire after 24 hours
- Refresh tokens expire after 7 days

**CORS:**
- Configured in `backend/animalguardian/settings.py`
- For local development, `CORS_ALLOW_ALL_ORIGINS=True`

### Mobile App Configuration

**API URL:**
- Set in `frontend/.env` file
- Default: `http://localhost:8000/api`

**Platforms:**
- Android: Requires Android SDK
- iOS: Requires Xcode (macOS only)
- Web: Works on any browser

### Web Dashboard Configuration

**API URL:**
- Set in `web-dashboard/.env` file
- Default: `http://localhost:8000/api`

**Port:**
- Default: 3000
- Change in `package.json` if needed

---

## 📁 Project Structure

```
AnimalGuardian/
├── backend/                   # Django REST API
│   ├── accounts/             # User management
│   ├── cases/                # Case reporting system
│   ├── livestock/            # Livestock models & views
│   ├── dashboard/            # Dashboard statistics
│   ├── notifications/        # Notification system
│   ├── files/                # File upload handling
│   ├── manage.py             # Django management
│   ├── requirements.txt      # Python dependencies
│   └── .env                  # Environment variables
│
├── frontend/                 # Flutter Mobile App
│   ├── lib/
│   │   ├── core/             # App configuration
│   │   └── features/         # Feature modules
│   ├── android/              # Android configuration
│   ├── ios/                  # iOS configuration
│   ├── pubspec.yaml          # Flutter dependencies
│   └── .env                  # Environment variables
│
├── web-dashboard/            # React.js Admin Panel
│   ├── src/
│   │   ├── pages/            # Dashboard pages
│   │   ├── components/       # UI components
│   │   └── services/         # API services
│   ├── package.json          # Node dependencies
│   └── .env                  # Environment variables
│
├── docs/                     # Documentation
├── render.yaml               # Render deployment config
├── netlify.toml              # Netlify deployment config
└── README.md                 # This file
```

---

## 📚 API Documentation

### Base URL

- **Local:** http://localhost:8000/api
- **Production:** https://animalguardian.onrender.com/api

### Authentication Endpoints

- `POST /api/auth/register/` - Register a new user
- `POST /api/auth/login/` - Login user
- `POST /api/auth/password-reset/request/` - Request password reset OTP
- `POST /api/auth/password-reset/verify-otp/` - Verify OTP code
- `POST /api/auth/password-reset/reset/` - Reset password

### Case Endpoints

- `GET /api/cases/reports/` - List all cases
- `POST /api/cases/reports/` - Create a new case report
- `GET /api/cases/reports/{id}/` - Get case details
- `PUT /api/cases/reports/{id}/` - Update case
- `DELETE /api/cases/reports/{id}/` - Delete case
- `POST /api/cases/reports/{id}/assign/` - Assign case to veterinarian

### Livestock Endpoints

- `GET /api/livestock/livestock/` - List livestock
- `POST /api/livestock/livestock/` - Create livestock record
- `GET /api/livestock/livestock/{id}/` - Get livestock details
- `PUT /api/livestock/livestock/{id}/` - Update livestock
- `DELETE /api/livestock/livestock/{id}/` - Delete livestock
- `GET /api/livestock/types/` - List livestock types
- `GET /api/livestock/breeds/` - List breeds

### Dashboard Endpoints

- `GET /api/dashboard/stats/` - Get dashboard statistics

### User Management Endpoints

- `GET /api/accounts/users/` - List users
- `GET /api/accounts/users/{id}/` - Get user details
- `POST /api/accounts/users/{id}/approve/` - Approve user

### File Upload

- `POST /api/files/upload/` - Upload file (image/video)

**Full API Documentation:** Visit http://localhost:8000/api/schema/swagger-ui/ when backend is running.

---

## 👥 User Types & Access

### 1. Farmers
- **Platform:** Mobile App (Flutter)
- **Registration:** Via mobile app
- **Features:** Report cases, manage livestock, track cases
- **Auto-Approved:** Yes

### 2. Local Veterinarians
- **Platform:** Mobile App (Flutter)
- **Registration:** Via mobile app
- **Features:** View assigned cases, update status
- **Approval Required:** Yes (must be approved by sector vet)

### 3. Sector Veterinarians
- **Platform:** Web Dashboard (React.js)
- **Registration:** Via web dashboard
- **Features:** Manage cases, assign to vets, view analytics
- **Auto-Approved:** Yes

### 4. Administrators
- **Platform:** Web Dashboard (React.js)
- **Creation:** Via Django admin
- **Features:** Full system access

---

## 🚢 Deployment

### Backend Deployment (Render)

1. Create a Render account and connect GitHub repository
2. Create a PostgreSQL database on Render
3. Create a Web Service with:
   - **Build Command:** `cd backend && pip install -r requirements.txt`
   - **Start Command:** `cd backend && bash render-start.sh`
   - **Environment Variables:** Set all variables from `.env` file

### Web Dashboard Deployment (Netlify)

1. Create a Netlify account and connect GitHub repository
2. Configure build settings:
   - **Base directory:** `web-dashboard`
   - **Build command:** `npm install && npm run build`
   - **Publish directory:** `web-dashboard/build`
   - **Environment variable:** `REACT_APP_API_URL`

### Mobile App Build

**Android APK:**
```bash
cd frontend
flutter build apk --release
```

**iOS (macOS only):**
```bash
cd frontend
flutter build ios --release
```

---

## 🔧 Troubleshooting

### Backend Issues

**Problem: Database connection error (PostgreSQL)**
```
psycopg2.OperationalError: could not translate host name "dpg-..." to address
```

**Solution:** This happens when Django tries to connect to a production PostgreSQL database. For local development, use SQLite:

**Git Bash:**
```bash
export DATABASE_URL=""
python manage.py runserver
```

**PowerShell:**
```powershell
$env:DATABASE_URL = ""
python manage.py runserver
```

**Or use the startup script:**
```bash
cd backend
bash start_local.sh  # Git Bash
# OR
.\start_local.ps1    # PowerShell
```

The settings are configured to automatically use SQLite when `DEBUG=True` (local development mode).

**Problem: Module not found**
```bash
# Solution: Reinstall dependencies
pip install -r requirements.txt
```

**Problem: Database migration errors**
```bash
# Solution: Reset database (WARNING: Deletes all data)
python manage.py flush
python manage.py migrate
```

**Problem: Port 8000 already in use**
```bash
# Solution: Use different port
python manage.py runserver 8001
```

### Mobile App Issues

**Problem: Flutter packages not installing**
```bash
# Solution: Clean and reinstall
flutter clean
flutter pub get
```

**Problem: API connection errors**
- Check that backend is running
- Verify API URL in `.env` file
- Check CORS settings in backend

### Web Dashboard Issues

**Problem: npm install fails**
```bash
# Solution: Clear cache and reinstall
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

**Problem: API connection errors**
- Check that backend is running
- Verify `REACT_APP_API_URL` in `.env` file
- Check browser console for errors

### Common Issues

**Problem: Virtual environment not activating**
- Windows PowerShell: Run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Make sure you're in the correct directory

**Problem: Python version mismatch**
- Ensure Python 3.11+ is installed
- Use `python3` instead of `python` on macOS/Linux

---

## 🧪 Testing

### Backend Testing

```bash
cd backend
python manage.py test
```

### Mobile App Testing

```bash
cd frontend
flutter test
```

### Web Dashboard Testing

```bash
cd web-dashboard
npm test
```

---

## 📝 Dependencies

### Backend Dependencies

Key packages in `backend/requirements.txt`:
- Django 4.2.7
- Django REST Framework 3.14.0
- djangorestframework-simplejwt 5.3.0
- psycopg2-binary 2.9.9 (PostgreSQL)
- django-cors-headers 4.3.1
- Pillow 10.0.0 (Image processing)
- gunicorn 21.2.0 (Production server)

### Mobile App Dependencies

Key packages in `frontend/pubspec.yaml`:
- flutter_riverpod 2.4.9 (State management)
- go_router 12.1.3 (Navigation)
- http 1.1.0 (API calls)
- image_picker 1.0.4 (Camera/gallery)
- flutter_secure_storage 9.0.0 (Secure storage)

### Web Dashboard Dependencies

Key packages in `web-dashboard/package.json`:
- react 18.2.0
- react-router-dom 6.30.1
- axios 1.6.2 (HTTP client)
- tailwindcss 3.3.6 (Styling)
- recharts 2.8.0 (Charts)

---

## 🔐 Security Features

- **JWT Authentication:** Secure token-based authentication
- **Password Hashing:** PBKDF2 algorithm (260,000 iterations)
- **CORS Configuration:** Secure cross-origin requests
- **Role-Based Access Control:** Different permissions per user type
- **Input Validation:** Comprehensive validation on frontend and backend
- **SQL Injection Protection:** Django ORM prevents SQL injection
- **HTTPS:** All production deployments use HTTPS

---

## 📞 Support

For issues, questions, or contributions:
- Open an issue on GitHub: https://github.com/josephine324/AnimalGuardian/issues
- Check the documentation in the `docs/` folder

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🙏 Acknowledgments

- Built for the farmers of Nyagatare District, Rwanda
- Designed with accessibility and inclusivity in mind
- Optimized for low-resource environments

---

**AnimalGuardian** - Transforming livestock health management through digital innovation 🐄💻

*Built with ❤️ for the farmers of Rwanda*

---

## 🎓 Quick Reference

### Start Backend
```bash
cd backend
.\venv\Scripts\Activate.ps1  # Windows
python manage.py runserver
```

### Start Mobile App
```bash
cd frontend
flutter run
```

### Start Web Dashboard
```bash
cd web-dashboard
npm start
```

### Check Backend Health
Visit: http://localhost:8000/health/

### Access Admin Panel
Visit: http://localhost:8000/admin/

### View API Documentation
Visit: http://localhost:8000/api/schema/swagger-ui/

---

**Last Updated:** December 2024  
**Version:** 1.0.0  
**Maintainer:** josephine324
