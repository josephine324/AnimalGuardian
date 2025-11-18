# AnimalGuardian - Complete Functionality Test Guide

## Overview
This document provides a comprehensive guide to test all functionalities of the AnimalGuardian system.

---

## 1. BACKEND API TESTING

### Prerequisites
- Backend API is deployed and accessible
- API Base URL: `https://animalguardian-backend-production-b5a8.up.railway.app/api`

### Test Script
Run the automated test script:
```bash
python test_all_functionalities.py
```

### Manual API Testing

#### 1.1 Authentication Flow
```bash
# 1. Register a new farmer
POST /api/auth/register/
{
  "phone_number": "+250788123456",
  "password": "testpass123",
  "user_type": "farmer",
  "first_name": "Test",
  "last_name": "Farmer"
}

# 2. Login
POST /api/auth/login/
{
  "phone_number": "+250788123456",
  "password": "testpass123"
}
# Response: { "access": "token...", "refresh": "token..." }

# 3. Verify OTP (if required)
POST /api/auth/verify-otp/
{
  "phone_number": "+250788123456",
  "otp": "1234"
}
```

#### 1.2 Livestock Management
```bash
# Get livestock (requires auth token)
GET /api/livestock/
Headers: Authorization: Bearer <token>

# Create livestock
POST /api/livestock/
Headers: Authorization: Bearer <token>
{
  "livestock_type": 1,
  "name": "Bella",
  "gender": "female",
  "status": "healthy"
}

# Get livestock types
GET /api/livestock/types/
```

#### 1.3 Case Management
```bash
# Get cases
GET /api/cases/reports/
Headers: Authorization: Bearer <token>

# Create case
POST /api/cases/reports/
Headers: Authorization: Bearer <token>
{
  "livestock": 1,
  "symptoms_observed": "Loss of appetite",
  "urgency": "high",
  "number_of_affected_animals": 1
}

# Assign case (Admin/Sector Vet)
POST /api/cases/reports/1/assign/
Headers: Authorization: Bearer <admin_token>
{
  "veterinarian_id": 2
}
```

---

## 2. MOBILE APP TESTING

### Prerequisites
- Flutter app is built and running
- Backend API is accessible
- Test user accounts created

### Test Checklist

#### 2.1 Authentication Flow
- [ ] **Splash Screen**
  - App shows splash screen with logo
  - Navigates to welcome/onboarding after delay

- [ ] **Onboarding**
  - All onboarding screens display correctly
  - Navigation works (back button, skip, next)

- [ ] **Registration**
  - Farmer can register with phone number
  - Local Vet can register (with approval notice)
  - Form validation works
  - OTP verification screen appears
  - After OTP, navigates to correct dashboard

- [ ] **Login**
  - User can login with phone/password
  - Error messages display for invalid credentials
  - "Create Account" button navigates to registration
  - After login, navigates to dashboard

#### 2.2 Farmer Dashboard
- [ ] **Home Tab**
  - Displays feed cards
  - Trending news shows
  - Search functionality works
  - Filter chips work (All, Livestock, Market, Tutorial)
  - All links are clickable

- [ ] **Cases Tab**
  - Lists cases from database (real API data)
  - Filter by status works (All, Pending, Under Review, Resolved)
  - Search functionality works
  - "Add Case" button navigates to report case screen
  - Case items are clickable and show details
  - Refresh button reloads cases

- [ ] **Community Tab**
  - Shows community feed
  - Posts display correctly
  - Video posts work
  - Chat list shows
  - Search functionality works
  - Like, comment, share buttons work

- [ ] **Profile Tab**
  - User profile information displays
  - Settings accessible
  - Logout works

- [ ] **Drawer Menu**
  - Opens from hamburger icon
  - All menu items clickable
  - Navigation works correctly
  - Closes after navigation

- [ ] **Bottom Navigation**
  - Always visible on all screens
  - Tab switching works
  - Correct icons and labels

#### 2.3 Livestock Management
- [ ] **View Livestock**
  - Lists livestock from database (real API data)
  - Filter by type works (All, Cattle, Goats, Sheep, Pigs)
  - Search functionality works
  - Refresh button reloads livestock
  - Empty state shows "Add Livestock" button

- [ ] **Add Livestock**
  - Form displays all fields
  - Livestock type dropdown loads
  - Breed dropdown loads based on type
  - Date picker works
  - Form validation works
  - Submit saves to database
  - Success message shows
  - Returns to livestock list
  - New livestock appears in list

- [ ] **Livestock Details**
  - Details screen displays all information
  - Back button works
  - Images display correctly

#### 2.4 Case Management
- [ ] **View Cases**
  - Lists cases from database (real API data)
  - Status and urgency badges display correctly
  - Filter by status works
  - Search functionality works
  - Refresh button reloads cases

- [ ] **Report Case**
  - Form displays all fields
  - Livestock selection works
  - Urgency selection works
  - Image selection works (web compatible)
  - Form validation works
  - Submit saves to database
  - Success message shows
  - Returns to cases list
  - New case appears in list

- [ ] **Case Details**
  - Details screen displays all information
  - Back button works
  - Images display correctly

#### 2.5 Vet Dashboard
- [ ] **Home Tab**
  - Shows welcome message
  - Displays quick stats (Active/Resolved Cases)
  - Quick actions work
  - Recent cases list shows

- [ ] **Cases Tab**
  - Lists assigned cases from database (real API data)
  - Filter by status works
  - Case details show farmer information
  - Refresh button reloads cases

- [ ] **Community Tab**
  - Same as farmer community tab

- [ ] **Profile Tab**
  - Vet profile information
  - Shows approval status if pending
  - Settings accessible

#### 2.6 Additional Features
- [ ] **Market Tab**
  - Product categories display
  - Products list shows
  - Search works
  - Filter by category works

- [ ] **Weather Tab**
  - Weather data displays
  - Location shows (Nyagatare, Rwanda)
  - Refresh works

- [ ] **Settings**
  - All settings pages accessible
  - Edit Profile works
  - Change Password works
  - Language selection works
  - Help & Support works
  - Privacy Policy works
  - Terms of Service works

---

## 3. WEB DASHBOARD TESTING

### Prerequisites
- Web dashboard is deployed and accessible
- Admin/Sector Vet account exists
- Backend API is accessible

### Test Checklist

#### 3.1 Authentication
- [ ] **Login**
  - Admin can login
  - Sector Vet can login
  - Error messages display for invalid credentials
  - Session persists after page refresh
  - Logout works

#### 3.2 Dashboard Overview
- [ ] **Statistics**
  - Total farmers count
  - Total veterinarians count
  - Total cases count
  - Active cases count
  - Charts display correctly

#### 3.3 User Management
- [ ] **Farmers**
  - List all farmers
  - Add new farmer (form works, saves to database)
  - Approve/Reject farmers
  - View farmer profile
  - Filter and search work

- [ ] **Veterinarians**
  - List all veterinarians
  - Add new veterinarian (form works, saves to database)
  - Approve/Reject veterinarians
  - View veterinarian profile
  - Assign case to veterinarian
  - Filter and search work

#### 3.4 Case Management
- [ ] **Cases**
  - List all cases
  - Add new case (form works, saves to database)
  - View case details
  - Assign case to veterinarian
  - Update case status
  - Filter by status works
  - Search works

#### 3.5 Notifications
- [ ] **Notifications**
  - List all notifications
  - Mark as read works
  - Filter by type works

- [ ] **Broadcasts**
  - List all broadcasts (Sector Vet/Admin)
  - Create broadcast
  - Send broadcast (creates notifications)
  - Filter by channel works

#### 3.6 Settings
- [ ] **Profile Settings**
  - Update profile works
  - Save changes works

- [ ] **System Settings**
  - Settings save to localStorage
  - Changes persist

---

## 4. DATA FLOW TESTS

### 4.1 Mobile → Backend → Database
- [ ] **Farmer Registration**
  1. Register on mobile app
  2. Check database: User created with correct type
  3. Check web dashboard: User appears in farmers list

- [ ] **Add Livestock**
  1. Add livestock on mobile app
  2. Check database: Livestock record created with correct owner
  3. Check mobile app: Livestock appears in list
  4. Check web dashboard: Livestock visible in admin view

- [ ] **Report Case**
  1. Report case on mobile app
  2. Check database: Case created with correct reporter
  3. Check mobile app: Case appears in farmer's cases
  4. Check web dashboard: Case appears in all cases

### 4.2 Web Dashboard → Backend → Database
- [ ] **Add Farmer**
  1. Add farmer on web dashboard
  2. Check database: User created
  3. Check web dashboard: Farmer appears in list
  4. Check mobile app: Farmer can login

- [ ] **Add Veterinarian**
  1. Add vet on web dashboard
  2. Check database: User created with vet profile
  3. Check web dashboard: Vet appears in list
  4. Check mobile app: Vet can login (after approval)

- [ ] **Assign Case**
  1. Assign case to vet on web dashboard
  2. Check database: Case updated with assigned_veterinarian
  3. Check web dashboard: Case shows as assigned
  4. Check mobile app: Case appears in vet's assigned cases

### 4.3 Cross-Platform Sync
- [ ] **Case Created on Mobile → Visible on Web**
  1. Create case on mobile
  2. Refresh web dashboard
  3. Case appears in cases list

- [ ] **Case Assigned on Web → Visible on Mobile**
  1. Assign case on web dashboard
  2. Refresh vet mobile app
  3. Case appears in vet's assigned cases

---

## 5. ERROR HANDLING TESTS

### 5.1 API Errors
- [ ] **401 Unauthorized**
  - Request without token returns 401
  - Mobile app handles gracefully
  - Web dashboard redirects to login

- [ ] **403 Forbidden**
  - Farmer tries to access admin endpoint → 403
  - Error message displays correctly

- [ ] **404 Not Found**
  - Invalid endpoint → 404
  - Error handled gracefully

- [ ] **500 Server Error**
  - Server error → 500
  - Error message displays
  - App doesn't crash

- [ ] **Network Errors**
  - No internet connection
  - Timeout errors
  - Connection refused
  - All handled gracefully with user-friendly messages

### 5.2 Mobile App Errors
- [ ] **Empty States**
  - No livestock → Shows "Add Livestock" button
  - No cases → Shows "Report Case" button
  - No data → Shows appropriate empty state message

- [ ] **Loading States**
  - Loading indicators show during API calls
  - Skeleton screens or spinners display

- [ ] **Error Messages**
  - API errors show user-friendly messages
  - Validation errors show inline
  - Network errors show retry option

---

## 6. SECURITY TESTS

### 6.1 Authentication
- [ ] **JWT Tokens**
  - Tokens are stored securely
  - Tokens expire correctly
  - Token refresh works
  - Invalid tokens are rejected

### 6.2 Authorization
- [ ] **Role-Based Access**
  - Farmers can only see their own livestock/cases
  - Vets can only see assigned cases
  - Admins can see all data
  - Unauthorized actions are blocked

### 6.3 Data Validation
- [ ] **Input Validation**
  - Phone numbers validated
  - Email format validated
  - Password strength enforced
  - Required fields enforced

---

## 7. PERFORMANCE TESTS

### 7.1 API Response Times
- [ ] **List Endpoints**
  - GET /api/livestock/ → < 2s
  - GET /api/cases/reports/ → < 2s
  - GET /api/users/ → < 2s

- [ ] **Detail Endpoints**
  - GET /api/livestock/{id}/ → < 1s
  - GET /api/cases/reports/{id}/ → < 1s

- [ ] **Create/Update**
  - POST /api/livestock/ → < 3s
  - POST /api/cases/reports/ → < 3s

### 7.2 Mobile App Performance
- [ ] **App Launch**
  - App opens in < 3s
  - Splash screen displays correctly

- [ ] **Navigation**
  - Tab switching is instant
  - Screen transitions are smooth
  - No lag or jank

- [ ] **Data Loading**
  - Lists load progressively
  - Images load correctly
  - No memory leaks

---

## 8. USSD SERVICE TESTING

### Prerequisites
- USSD service is deployed
- Test phone number available
- Africa's Talking credentials configured

### Test Checklist
- [ ] **USSD Menu**
  - Dial USSD code
  - Menu displays correctly
  - Navigation works

- [ ] **Case Reporting via USSD**
  - Report case through USSD
  - Case appears in database
  - Case visible on web dashboard

- [ ] **User Verification**
  - Only approved users can access
  - Unapproved users see appropriate message

---

## TEST RESULTS TEMPLATE

```
Date: [Date]
Tester: [Name]
Environment: [Production/Staging/Development]

Backend API: [Pass/Fail/Partial]
Mobile App: [Pass/Fail/Partial]
Web Dashboard: [Pass/Fail/Partial]
Data Flow: [Pass/Fail/Partial]
Error Handling: [Pass/Fail/Partial]
Security: [Pass/Fail/Partial]
Performance: [Pass/Fail/Partial]

Issues Found:
1. [Issue description]
2. [Issue description]

Notes:
[Additional notes]
```

---

## QUICK TEST COMMANDS

### Test Backend API
```bash
# Health check
curl https://animalguardian-backend-production-b5a8.up.railway.app/api/dashboard/health/

# Get livestock types (public)
curl https://animalguardian-backend-production-b5a8.up.railway.app/api/livestock/types/

# Test protected endpoint (should return 401)
curl https://animalguardian-backend-production-b5a8.up.railway.app/api/livestock/
```

### Run Automated Tests
```bash
# Python test script
python test_all_functionalities.py

# View results
cat test_results.json
```

---

## NEXT STEPS AFTER TESTING

1. Document all issues found
2. Prioritize fixes (Critical, High, Medium, Low)
3. Create bug reports for each issue
4. Re-test after fixes
5. Update test documentation

