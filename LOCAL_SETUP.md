# 🚀 Local Development Setup Guide

This guide will help you run the AnimalGuardian project locally in Visual Studio Code, with the mobile app and web dashboard connecting to the deployed backend at `https://animalguardian.onrender.com`.

## 📋 Prerequisites

Before you begin, make sure you have the following installed:

- **Python 3.11+** - [Download](https://www.python.org/downloads/)
- **Node.js 18+** - [Download](https://nodejs.org/)
- **Flutter 3.10+** - [Download](https://flutter.dev/docs/get-started/install)
- **Git** - [Download](https://git-scm.com/downloads)
- **Visual Studio Code** - [Download](https://code.visualstudio.com/)

## 🔧 Configuration

### ✅ Environment Files Created

The following `.env` files have been created and configured to use the deployed backend:

1. **`frontend/.env`** - Points to `https://animalguardian.onrender.com/api`
2. **`web-dashboard/.env`** - Points to `https://animalguardian.onrender.com/api`

Both applications will now fetch data from the deployed backend at `https://animalguardian.onrender.com`.

## 📱 Running the Mobile App (Flutter)

### Step 1: Install Dependencies

```powershell
cd frontend
flutter pub get
```

### Step 2: Verify Environment Configuration

The `.env` file in the `frontend` directory should contain:
```
API_BASE_URL=https://animalguardian.onrender.com/api
```

### Step 3: Run the App

**Option A: Using VS Code**
1. Open the `frontend` folder in VS Code
2. Press `F5` or go to Run > Start Debugging
3. Select your target device (emulator or physical device)

**Option B: Using Terminal**
```powershell
cd frontend
flutter run
```

The app will connect to the deployed backend automatically.

## 💻 Running the Web Dashboard (React)

### Step 1: Install Dependencies

```powershell
cd web-dashboard
npm install
```

### Step 2: Verify Environment Configuration

The `.env` file in the `web-dashboard` directory should contain:
```
REACT_APP_API_URL=https://animalguardian.onrender.com/api
```

### Step 3: Run the Development Server

**Option A: Using VS Code**
1. Open the `web-dashboard` folder in VS Code
2. Open the terminal (`` Ctrl+` ``)
3. Run: `npm start`

**Option B: Using Terminal**
```powershell
cd web-dashboard
npm start
```

The dashboard will open at `http://localhost:3000` and connect to the deployed backend.

## 🎯 Testing the Setup

### Test Mobile App Connection

1. Launch the Flutter app
2. Try to register a new account or login
3. Check that data is being fetched from `https://animalguardian.onrender.com/api`

### Test Web Dashboard Connection

1. Open `http://localhost:3000` in your browser
2. Try to login or register
3. Check the browser console (F12) for any API errors
4. Verify that API calls are going to `https://animalguardian.onrender.com/api`

## 🔍 Troubleshooting

### Mobile App Issues

**Problem: App can't connect to backend**
- Check that `frontend/.env` exists and contains the correct URL
- Verify your internet connection
- Check if the deployed backend is accessible: https://animalguardian.onrender.com/health/

**Problem: Environment variables not loading**
- Make sure `.env` file is in the `frontend` directory
- Restart the Flutter app after creating/modifying `.env`
- Check that `flutter_dotenv` is properly configured in `pubspec.yaml`

### Web Dashboard Issues

**Problem: Dashboard can't connect to backend**
- Check that `web-dashboard/.env` exists and contains `REACT_APP_API_URL`
- Restart the development server after creating/modifying `.env`
- Clear browser cache and reload

**Problem: CORS errors**
- The deployed backend should allow CORS from localhost
- Check browser console for specific error messages
- Verify the backend URL is correct

### General Issues

**Problem: API calls failing**
- Verify the deployed backend is running: https://animalguardian.onrender.com/health/
- Check your internet connection
- Review the API documentation at: https://animalguardian.onrender.com/api/

## 📝 Important Notes

1. **No Local Backend Required**: Since you're using the deployed backend, you don't need to run the Django server locally.

2. **Real Data**: All data (users, cases, livestock) will be from the deployed backend. Any accounts you create will be stored on the deployed server.

3. **Account Creation**: 
   - **Farmers**: Auto-approved, can login immediately
   - **Local Veterinarians**: Must be approved by a sector vet before login
   - **Sector Veterinarians**: Auto-approved, can login immediately

4. **API Endpoints**: The deployed backend API is available at:
   - Base URL: `https://animalguardian.onrender.com/api`
   - Health Check: `https://animalguardian.onrender.com/health/`
   - Admin Panel: `https://animalguardian.onrender.com/admin/`

## 🎨 VS Code Extensions (Recommended)

For the best development experience, install these VS Code extensions:

- **Flutter** - Official Flutter extension
- **Dart** - Dart language support
- **ES7+ React/Redux/React-Native snippets** - React development
- **Prettier** - Code formatting
- **ESLint** - JavaScript linting

## 🚀 Quick Start Commands

### Mobile App
```powershell
cd frontend
flutter pub get
flutter run
```

### Web Dashboard
```powershell
cd web-dashboard
npm install
npm start
```

## 📚 Additional Resources

- **Backend API Documentation**: https://animalguardian.onrender.com/api/
- **Flutter Documentation**: https://flutter.dev/docs
- **React Documentation**: https://react.dev/
- **Project README**: See `README.md` for full project documentation

## ✅ Verification Checklist

- [ ] Python 3.11+ installed
- [ ] Node.js 18+ installed
- [ ] Flutter 3.10+ installed
- [ ] `frontend/.env` file exists with correct API URL
- [ ] `web-dashboard/.env` file exists with correct API URL
- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] Node.js dependencies installed (`npm install`)
- [ ] Mobile app can connect to backend
- [ ] Web dashboard can connect to backend
- [ ] Can create accounts and login successfully

---

**Happy Coding! 🎉**

If you encounter any issues, check the troubleshooting section or refer to the main `README.md` file.

