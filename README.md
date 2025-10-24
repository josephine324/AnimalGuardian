# 🐄 AnimalGuardian - Digital Livestock Support System

A comprehensive digital platform designed to enhance veterinary service delivery, disease surveillance, and farmer knowledge for smallholder farmers in Nyagatare District, Rwanda.

Video explaining the app: https://youtu.be/2XZ3YG0hbZ0


## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Installation](#installation)
- [Usage](#usage)
- [API Documentation](#api-documentation)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [Research Background](#research-background)
- [License](#license)

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

## ✨ Features

### 📱 Mobile Application (React Native)
- **Case Reporting**: Report animal health issues with photos/videos
- **Veterinary Consultation**: Chat with certified veterinarians
- **Health Records**: Track vaccination and treatment history
- **Weather Integration**: Get weather-based health alerts
- **Offline Support**: Basic functionality without internet

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

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Mobile App    │    │  Web Dashboard  │    │   USSD/SMS      │
│  (React Native) │    │   (React.js)    │    │   Service       │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────▼─────────────┐
                    │     Django Backend        │
                    │   (REST API + Admin)      │
                    └─────────────┬─────────────┘
                                 │
                    ┌─────────────▼─────────────┐
                    │     PostgreSQL            │
                    │    Database Server        │
                    └───────────────────────────┘
```

## 🛠️ Technology Stack

### Frontend
- **React Native** - Cross-platform mobile development
- **React.js** - Web dashboard interface
- **JavaScript/TypeScript** - Programming languages
- **React Navigation** - Mobile navigation
- **React Query** - Data fetching and caching
- **Tailwind CSS** - Utility-first styling

### Backend
- **Python 3.11+** - Core programming language
- **Django 4.2** - Web framework
- **Django REST Framework** - API development
- **PostgreSQL** - Primary database
- **SQLite** - Development database
- **JWT** - Authentication tokens

### Services & APIs
- **Africa's Talking API** - USSD and SMS services
- **AWS S3** - File storage (production)
- **Heroku** - Hosting platform (pilot)
- **Docker** - Containerization

### Development Tools
- **Git** - Version control
- **GitHub** - Code repository
- **VS Code** - Development environment
- **Postman** - API testing

## 🚀 Installation

### Prerequisites

- **Node.js** (v16 or higher)
- **Python** (3.11 or higher)
- **PostgreSQL** (12 or higher)
- **Git**
- **Android Studio** (for mobile development)

### Backend Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/josephine324/AnimalGuardian.git
   cd AnimalGuadian
   ```

2. **Set up Python virtual environment**
   ```bash
   cd backend
   python -m venv venv
   
   # Windows
   venv\Scripts\activate
   
   # macOS/Linux
   source venv/bin/activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Environment configuration**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

5. **Database setup**
   ```bash
   python manage.py migrate
   python manage.py createsuperuser
   ```

6. **Run development server**
   ```bash
   python manage.py runserver
   ```

### Frontend Setup

1. **Install dependencies**
   ```bash
   cd ../frontend
   npm install
   ```

2. **Run Metro bundler**
   ```bash
   npx react-native start
   ```

3. **Run on Android** (requires Android SDK)
   ```bash
   npx react-native run-android
   ```

### Web Dashboard Setup

1. **Install dependencies**
   ```bash
   cd ../web-dashboard
   npm install
   ```

2. **Start development server**
   ```bash
   npm start
   ```

## 📖 Usage

### For Farmers

1. **Install the mobile app** from the app store
2. **Create an account** with your phone number
3. **Add livestock** to your profile
4. **Report health issues** with photos/videos
5. **Receive expert advice** from veterinarians
6. **Get health reminders** for vaccinations and checkups

### For Veterinarians

1. **Access the web dashboard** at `http://localhost:3000`
2. **Log in** with your credentials
3. **Review case reports** from farmers
4. **Provide expert advice** and treatment recommendations
5. **Track case progress** and follow-ups
6. **Monitor disease trends** and outbreaks

### For Administrators

1. **Access Django admin** at `http://localhost:8000/admin`
2. **Manage user accounts** and permissions
3. **Configure system settings** and notifications
4. **Monitor system performance** and usage statistics
5. **Generate reports** and analytics

## 📚 API Documentation

### Authentication Endpoints
- `POST /api/auth/register/` - User registration
- `POST /api/auth/login/` - User login
- `POST /api/auth/refresh/` - Token refresh

### Livestock Management
- `GET /api/livestock/` - List user's livestock
- `POST /api/livestock/` - Add new livestock
- `PUT /api/livestock/{id}/` - Update livestock info
- `DELETE /api/livestock/{id}/` - Remove livestock

### Case Reporting
- `POST /api/cases/` - Report new case
- `GET /api/cases/` - List user's cases
- `PUT /api/cases/{id}/` - Update case status
- `POST /api/cases/{id}/response/` - Add veterinarian response

### Notifications
- `GET /api/notifications/` - Get user notifications
- `PUT /api/notifications/{id}/read/` - Mark as read
- `POST /api/notifications/preferences/` - Update preferences

## 📁 Project Structure

```
AnimalGuardian/
├── backend/                 # Django backend
│   ├── animalguardian/     # Main Django project
│   ├── accounts/           # User management
│   ├── livestock/          # Livestock models & views
│   ├── cases/              # Case reporting system
│   ├── notifications/      # Notification system
│   ├── requirements.txt    # Python dependencies
│   └── manage.py          # Django management script
├── frontend/               # React Native mobile app
│   ├── src/
│   │   ├── screens/       # App screens
│   │   ├── navigation/    # Navigation setup
│   │   ├── services/      # API services
│   │   └── components/    # Reusable components
│   ├── package.json       # Node dependencies
│   └── App.js            # Main app component
├── web-dashboard/         # React.js web interface
│   ├── src/
│   │   ├── pages/        # Dashboard pages
│   │   ├── components/   # UI components
│   │   └── hooks/        # Custom hooks
│   └── package.json      # Node dependencies
├── ussd-service/         # USSD/SMS service
│   ├── app.py           # Flask USSD handler
│   └── requirements.txt # Python dependencies
├── docs/                # Documentation
│   ├── API_DOCUMENTATION.md
│   └── DEPLOYMENT_GUIDE.md
├── scripts/             # Setup and deployment scripts
├── docker-compose.yml   # Docker configuration
└── README.md           # This file
```

## 🤝 Contributing

We welcome contributions to AnimalGuardian! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Development Guidelines

- Follow PEP 8 for Python code
- Use ESLint for JavaScript/TypeScript
- Write tests for new features
- Update documentation as needed
- Follow the existing code style

## 🔬 Research Background

This project is based on academic research conducted in Nyagatare District, Rwanda, focusing on digital solutions for livestock health management. The research addresses:

### Key Challenges
- **High disease prevalence** (Brucellosis, Rift Valley Fever, etc.)
- **Limited veterinary access** (1 vet per thousands of cattle)
- **Knowledge gaps** among smallholder farmers
- **Inefficient disease surveillance** systems

### Research Objectives
1. Assess animal health management gaps among smallholder farmers
2. Develop a digital system for veterinary consultancy and disease reporting
3. Evaluate system effectiveness in improving service delivery
4. Provide recommendations for national scaling

### Target Impact
- **Improved animal health** through early disease detection
- **Enhanced farmer knowledge** via digital education
- **Better veterinary service delivery** through technology
- **Strengthened disease surveillance** for national food security

### Research Methodology
- **Mixed-methods approach** combining qualitative and quantitative data
- **Field surveys** with 690+ farmers in Nyagatare District
- **Veterinarian interviews** and focus group discussions
- **Pilot testing** with iterative system improvements

## 📊 Project Status

- ✅ **Backend API** - Complete and functional
- ✅ **Web Dashboard** - Complete with admin interface
- ✅ **Database Models** - All entities implemented
- ✅ **Authentication System** - JWT-based security
- 🔄 **Mobile App** - In development (Android setup required)
- 🔄 **USSD Service** - Basic implementation complete
- ⏳ **Production Deployment** - Pending

## 🌍 Impact & Future

### Short-term Goals
- Complete mobile app development
- Deploy pilot system in Nyagatare District
- Train 100+ farmers on system usage
- Establish veterinarian network

### Long-term Vision
- **National rollout** across all 30 districts of Rwanda
- **Integration** with government livestock programs
- **Expansion** to other East African countries
- **AI-powered** disease diagnosis and treatment recommendations

### Expected Outcomes
- **30% reduction** in animal mortality rates
- **50% improvement** in veterinary response time
- **Enhanced food security** for rural communities
- **Digital transformation** of livestock sector

## 📞 Support & Contact

- **Project Lead**: Josephine Mutesi
- **Research Supervisor**: Thadee Gatera
- **Institution**: African Leadership University
- **Email**: [Contact information]
- **GitHub**:https://github.com/josephine324/AnimalGuardian.git


## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments
- **African Leadership University** - Academic support and supervision
- **Nyagatare District Farmers** - Research participants and feedback
- **Rwanda Agriculture Board (RAB)** - Technical guidance
- **Africa's Talking** - USSD/SMS service integration
- **Open Source Community** - Tools and libraries used

---

**AnimalGuardian** - Transforming livestock health management through digital innovation 🐄💻

*Built with ❤️ for the farmers of Rwanda*
