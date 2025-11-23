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
- [User Types & Access](#user-types--access)
- [Deployment](#deployment)
- [API Documentation](#api-documentation)
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
- **Case Reporting**: Report animal health issues with photos/videos
- **Livestock Management**: Add and manage livestock inventory with health records
- **Case Tracking**: View case status and history
- **Profile Management**: Edit profile and change password
- **Password Reset**: Forgot password functionality with email OTP

**For Local Veterinarians:**
- **Assigned Cases**: View and manage cases assigned by sector vets
- **Case Details**: View complete case information and update status
- **Availability Toggle**: Set online/offline status
- **Profile Management**: View veterinarian profile

**Technical Features:**
- Cross-platform (iOS and Android)
- JWT-based authentication
- Real-time data synchronization
- Image upload for case reports
- Responsive UI with Material Design 3

### 💻 Web Dashboard (React.js)

**For Sector Veterinarians:**
- **Dashboard Overview**: Real-time statistics and metrics
- **Case Management**: View all cases, assign to local vets, track status
- **Location-Based Assignment**: See farmer location (sector/district) for efficient assignment
- **Veterinarian Management**: View and approve local veterinarians
- **Farmer Management**: View all registered farmers
- **Livestock Overview**: View all livestock records
- **Analytics**: Disease trends and statistics
- **Auto-Refresh**: Dashboard updates every 30 seconds

**Authentication:**
- Sector vet registration (auto-approved)
- Login with email/phone and password
- Password reset functionality
- Session management

### 🔧 Backend Services (Django REST Framework)

**Core Features:**
- **RESTful API**: Secure data management with JWT authentication
- **User Management**: Registration, authentication, password reset
- **Case Management**: Create, update, assign, and track cases
- **Livestock Management**: CRUD operations for livestock records
- **File Upload**: Secure media upload and storage
- **Notifications**: Email notifications for password reset and case updates
- **Database**: PostgreSQL with optimized queries and indexing
- **CORS**: Configured for cross-origin requests

**API Endpoints:**
- `/api/auth/` - Authentication (register, login, password reset)
- `/api/cases/` - Case reporting and management
- `/api/livestock/` - Livestock management
- `/api/dashboard/` - Dashboard statistics
- `/api/accounts/` - User management
- `/api/files/upload/` - File upload

---

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Mobile App    │    │  Web Dashboard  │
│    (Flutter)    │    │   (React.js)    │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          └──────────┬───────────┘
                     │
          ┌──────────▼──────────┐
          │   Django REST API   │
          │   (Backend Server)  │
          └──────────┬──────────┘
                     │
          ┌──────────▼──────────┐
          │   PostgreSQL        │
          │   Database          │
          └─────────────────────┘
```

---

## 🛠️ Technology Stack

### Frontend
- **Flutter** 3.10+ - Mobile application framework
- **Dart** 3.0+ - Programming language
- **Riverpod** - State management
- **GoRouter** - Navigation
- **HTTP** - API communication

### Web Dashboard
- **React.js** 18+ - Frontend framework
- **Tailwind CSS** - Styling
- **Axios** - HTTP client
- **React Router** - Routing

### Backend
- **Django** 4.2+ - Web framework
- **Django REST Framework** 3.14+ - API framework
- **PostgreSQL** 13+ - Database (Production)
- **SQLite** - Database (Local Development)
- **Gunicorn** - WSGI server (Production)
- **JWT** - Authentication

### Deployment
- **Render** - Backend hosting
- **Netlify** - Web dashboard hosting
- **PostgreSQL** - Managed database on Render

---

## 📁 Project Structure

```
AnimalGuardian/
├── frontend/                  # Flutter Mobile App
│   ├── lib/
│   │   ├── core/             # App configuration & shared logic
│   │   │   ├── constants/     # App constants
│   │   │   ├── models/        # Data models
│   │   │   ├── providers/     # Global state providers
│   │   │   ├── routing/       # Navigation configuration
│   │   │   ├── services/      # API services
│   │   │   └── theme/         # App theme
│   │   └── features/          # Feature-based modules
│   │       ├── auth/          # Authentication
│   │       ├── cases/         # Case reporting
│   │       ├── livestock/     # Livestock management
│   │       ├── home/          # Dashboard
│   │       └── ...
│   ├── android/              # Android configuration
│   ├── ios/                  # iOS configuration
│   └── pubspec.yaml          # Flutter dependencies
│
├── backend/                   # Django REST API
│   ├── animalguardian/       # Django project settings
│   ├── accounts/             # User management
│   ├── cases/                # Case reporting system
│   ├── livestock/            # Livestock models & views
│   ├── dashboard/            # Dashboard statistics
│   ├── notifications/        # Notification system
│   ├── files/                # File upload handling
│   ├── manage.py             # Django management
│   └── requirements.txt      # Python dependencies
│
├── web-dashboard/            # React.js Admin Panel
│   ├── src/
│   │   ├── pages/            # Dashboard pages
│   │   ├── components/       # UI components
│   │   ├── services/         # API services
│   │   └── App.js            # Main app component
│   └── package.json          # Node dependencies
│
├── render.yaml               # Render deployment configuration
├── netlify.toml              # Netlify deployment configuration
└── README.md                # This file
```

---

## 🚀 Installation & Setup

### Prerequisites

- **Python** 3.11+ ([Download](https://www.python.org/downloads/))
- **Node.js** 18+ ([Download](https://nodejs.org/))
- **Flutter** 3.10+ ([Download](https://flutter.dev/docs/get-started/install))
- **PostgreSQL** 13+ (for production) or SQLite (for local development)
- **Git** ([Download](https://git-scm.com/downloads))

### Backend Setup

1. **Navigate to backend directory:**
   ```powershell
   cd backend
   ```

2. **Create virtual environment:**
   ```powershell
   python -m venv venv
   ```

3. **Activate virtual environment:**
   ```powershell
   # Windows PowerShell:
   .\venv\Scripts\Activate.ps1
   
   # Windows CMD:
   venv\Scripts\activate
   
   # macOS/Linux:
   source venv/bin/activate
   ```

4. **Install dependencies:**
   ```powershell
   pip install -r requirements.txt
   ```

5. **Set up environment variables:**
   Create a `.env` file in the `backend` directory:
   ```env
   SECRET_KEY=your-secret-key-here
   DEBUG=True
   DATABASE_URL=  # Leave empty for SQLite (local development)
   CORS_ALLOW_ALL_ORIGINS=True
   EMAIL_HOST=smtp.gmail.com
   EMAIL_PORT=587
   EMAIL_USE_TLS=True
   EMAIL_HOST_USER=your-email@gmail.com
   EMAIL_HOST_PASSWORD=your-app-password
   DEFAULT_FROM_EMAIL=your-email@gmail.com
   ```

6. **Run migrations:**
   ```powershell
   python manage.py migrate
   ```

7. **Seed livestock types (optional):**
   ```powershell
   python manage.py seed_livestock_types
   ```

8. **Create superuser (optional):**
   ```powershell
   python manage.py createsuperuser
   ```

### Mobile App Setup

1. **Navigate to frontend directory:**
   ```powershell
   cd frontend
   ```

2. **Install dependencies:**
   ```powershell
   flutter pub get
   ```

3. **Configure API URL:**
   Create a `.env` file in the `frontend` directory:
   ```env
   API_BASE_URL=http://localhost:8000/api
   ```
   Or for production:
   ```env
   API_BASE_URL=https://animalguardian.onrender.com/api
   ```

4. **Run the app:**
   ```powershell
   flutter run
   ```

### Web Dashboard Setup

1. **Navigate to web-dashboard directory:**
   ```powershell
   cd web-dashboard
   ```

2. **Install dependencies:**
   ```powershell
   npm install
   ```

3. **Configure API URL:**
   Create a `.env` file in the `web-dashboard` directory:
   ```env
   REACT_APP_API_URL=http://localhost:8000/api
   ```
   Or for production:
   ```env
   REACT_APP_API_URL=https://animalguardian.onrender.com/api
   ```

4. **Run the development server:**
   ```powershell
   npm start
   ```

---

## 🏃 Running the Application

### Backend (Local Development)

```powershell
cd backend
.\venv\Scripts\Activate.ps1
$env:DATABASE_URL = $null  # Use SQLite
python manage.py runserver
```

The backend will be available at: **http://localhost:8000**

- **API Base URL:** http://localhost:8000/api
- **Admin Panel:** http://localhost:8000/admin
- **Health Check:** http://localhost:8000/health/

### Mobile App

```powershell
cd frontend
flutter run
```

### Web Dashboard

```powershell
cd web-dashboard
npm start
```

The dashboard will be available at: **http://localhost:3000**

---

## 👥 User Types & Access

### 1. Farmers
- **Platform:** Mobile App (Flutter)
- **Registration:** Via mobile app
- **Features:**
  - Report animal health cases
  - Manage livestock inventory
  - Track case status
  - View case history
  - Edit profile and change password
- **Auto-Approved:** Yes (can login immediately after registration)

### 2. Local Veterinarians
- **Platform:** Mobile App (Flutter)
- **Registration:** Via mobile app
- **Features:**
  - View assigned cases
  - Update case status
  - Toggle availability
  - View profile
- **Approval Required:** Yes (must be approved by sector vet before login)

### 3. Sector Veterinarians
- **Platform:** Web Dashboard (React.js)
- **Registration:** Via web dashboard
- **Features:**
  - View all cases
  - Assign cases to local vets
  - View all farmers and veterinarians
  - Approve/reject local veterinarians
  - View dashboard statistics
  - Manage livestock records
- **Auto-Approved:** Yes (can login immediately after registration)

### 4. Administrators
- **Platform:** Web Dashboard (React.js)
- **Creation:** Via Django admin or management command
- **Features:**
  - Full system access
  - User management
  - System configuration

---

## 🚢 Deployment

### Backend Deployment (Render)

1. **Create a Render account** and connect your GitHub repository

2. **Create a PostgreSQL database** on Render

3. **Create a Web Service:**
   - **Build Command:** `cd backend && pip install --upgrade pip setuptools wheel && pip install -r requirements.txt`
   - **Start Command:** `cd backend && chmod +x render-start.sh && bash render-start.sh`
   - **Environment Variables:**
     - `PYTHON_VERSION=3.11.0`
     - `DJANGO_SETTINGS_MODULE=animalguardian.settings`
     - `DEBUG=False`
     - `SECRET_KEY=<your-secret-key>`
     - `DATABASE_URL=<from-postgresql-database>`
     - `CORS_ALLOW_ALL_ORIGINS=True`
     - `ALLOWED_HOSTS=animalguardian.onrender.com,*.onrender.com`
     - `EMAIL_HOST_USER=<your-email>`
     - `EMAIL_HOST_PASSWORD=<your-app-password>`
     - `DEFAULT_FROM_EMAIL=<your-email>`

4. **Deploy using `render.yaml`** (Blueprints) or manually configure

### Web Dashboard Deployment (Netlify)

1. **Create a Netlify account** and connect your GitHub repository

2. **Configure build settings:**
   - **Base directory:** `web-dashboard`
   - **Build command:** `CI=false npm install && npm run build`
   - **Publish directory:** `web-dashboard/build`
   - **Environment variable:** `REACT_APP_API_URL=https://animalguardian.onrender.com/api`

3. **Deploy**

### Mobile App Build

**Build APK (Android):**
```powershell
cd frontend
flutter build apk --release
```

The APK will be located at: `frontend/build/app/outputs/flutter-apk/app-release.apk`

---

## 📚 API Documentation

### Authentication Endpoints

- `POST /api/auth/register/` - Register a new user
- `POST /api/auth/login/` - Login user
- `POST /api/auth/password-reset/request/` - Request password reset OTP
- `POST /api/auth/password-reset/verify-otp/` - Verify OTP code
- `POST /api/auth/password-reset/reset/` - Reset password

### Case Endpoints

- `GET /api/cases/reports/` - List all cases (filtered by user role)
- `POST /api/cases/reports/` - Create a new case report
- `GET /api/cases/reports/{id}/` - Get case details
- `PUT /api/cases/reports/{id}/` - Update case (farmer can edit own cases)
- `DELETE /api/cases/reports/{id}/` - Delete case (farmer can delete own cases)
- `POST /api/cases/reports/{id}/assign/` - Assign case to veterinarian (sector vet only)

### Livestock Endpoints

- `GET /api/livestock/livestock/` - List livestock (filtered by user role)
- `POST /api/livestock/livestock/` - Create livestock record (farmer only)
- `GET /api/livestock/livestock/{id}/` - Get livestock details
- `PUT /api/livestock/livestock/{id}/` - Update livestock
- `DELETE /api/livestock/livestock/{id}/` - Delete livestock
- `GET /api/livestock/types/` - List livestock types (public)
- `GET /api/livestock/breeds/` - List breeds (public)

### Dashboard Endpoints

- `GET /api/dashboard/stats/` - Get dashboard statistics (sector vet/admin only)

### User Management Endpoints

- `GET /api/accounts/users/` - List users (filtered by role)
- `GET /api/accounts/users/{id}/` - Get user details
- `PUT /api/accounts/users/{id}/approve/` - Approve user (sector vet/admin only)

### File Upload

- `POST /api/files/upload/` - Upload file (image/video)

---

## 🔐 Security Features

- **JWT Authentication:** Secure token-based authentication
- **Password Hashing:** PBKDF2 algorithm for password storage
- **CORS Configuration:** Configured for secure cross-origin requests
- **Role-Based Access Control:** Different permissions for different user types
- **Input Validation:** Comprehensive validation on both frontend and backend
- **SQL Injection Protection:** Django ORM prevents SQL injection
- **HTTPS:** All production deployments use HTTPS

---

## 🧪 Testing

### Backend Testing

```powershell
cd backend
python manage.py test
```

### Mobile App Testing

```powershell
cd frontend
flutter test
```

---

## 📝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🙏 Acknowledgments

- Built for the farmers of Nyagatare District, Rwanda
- Designed with accessibility and inclusivity in mind
- Optimized for low-resource environments

---

## 📞 Support

For issues, questions, or contributions, please open an issue on the GitHub repository.

---

**AnimalGuardian** - Transforming livestock health management through digital innovation 🐄💻

*Built with ❤️ for the farmers of Rwanda*
