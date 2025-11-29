# ⚡ Quick Start Guide

Get the AnimalGuardian project running locally in minutes!

## 🎯 What's Configured

✅ **Frontend (Flutter)**: Configured to use `https://animalguardian.onrender.com/api`  
✅ **Web Dashboard (React)**: Configured to use `https://animalguardian.onrender.com/api`  
✅ **Backend**: Using deployed backend (no local setup needed)

## 🚀 Quick Start

### 1. Mobile App (Flutter)

```powershell
# Navigate to frontend directory
cd frontend

# Install dependencies
flutter pub get

# Run the app
flutter run
```

The app will automatically connect to the deployed backend at `https://animalguardian.onrender.com/api`.

### 2. Web Dashboard (React)

```powershell
# Navigate to web-dashboard directory
cd web-dashboard

# Install dependencies
npm install

# Start development server
npm start
```

The dashboard will open at `http://localhost:3000` and connect to the deployed backend.

## ✅ Verify It's Working

1. **Mobile App**: Try to register or login - data should come from the deployed backend
2. **Web Dashboard**: Open `http://localhost:3000` and try to login - check browser console (F12) for API calls

## 📝 Environment Files

Both applications are pre-configured with `.env` files:

- `frontend/.env` → `API_BASE_URL=https://animalguardian.onrender.com/api`
- `web-dashboard/.env` → `REACT_APP_API_URL=https://animalguardian.onrender.com/api`

## 🔗 Backend API

- **Base URL**: https://animalguardian.onrender.com/api
- **Health Check**: https://animalguardian.onrender.com/health/
- **Admin Panel**: https://animalguardian.onrender.com/admin/

## 💡 Tips

- **No local backend needed** - Everything connects to the deployed backend
- **Real data** - All accounts and data are stored on the deployed server
- **Account types**:
  - Farmers: Auto-approved ✅
  - Sector Vets: Auto-approved ✅
  - Local Vets: Need approval ⏳

## 🆘 Need Help?

See `LOCAL_SETUP.md` for detailed setup instructions and troubleshooting.

---

**That's it! You're ready to develop! 🎉**

