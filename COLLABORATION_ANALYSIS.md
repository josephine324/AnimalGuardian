# Web Dashboard & Mobile App Collaboration Analysis

## Overview
This document analyzes the collaboration between the web dashboard (React.js) and mobile app (Flutter) in the AnimalGuardian system.

---

## 1. 🔐 User Registration & Approval Flow

### Mobile App → Web Dashboard Flow

#### **Step 1: User Registration (Mobile App)**
- **Endpoint:** `POST /api/auth/register/`
- **Location:** `frontend/lib/features/auth/presentation/screens/register_screen.dart`
- **User Types:**
  - ✅ **Farmer** - Can register directly
  - ✅ **Local Veterinarian** - Can register but requires approval
  - ❌ **Sector Veterinarian** - Cannot register via mobile (web dashboard only)

#### **Step 2: User Appears in Web Dashboard**
- **Endpoint:** `GET /api/users/pending_approval/`
- **Location:** `web-dashboard/src/pages/UserApprovalPage.js`
- **Who Can View:** Only Sector Vets and Admins
- **Backend Logic:** `backend/accounts/views.py` - `UserViewSet.pending_approval()`
  - Returns users where: `is_verified=True` AND `is_approved_by_admin=False`
  - Shows all user types waiting for approval

#### **Step 3: Sector Vet Approves/Rejects (Web Dashboard)**
- **Endpoint:** `POST /api/users/{id}/approve/` or `/api/users/{id}/reject/`
- **Location:** `web-dashboard/src/pages/UserApprovalPage.js`
- **Backend Logic:** `backend/accounts/views.py` - `UserViewSet.approve()`
  - Only Sector Vets and Admins can approve
  - Sets `is_approved_by_admin=True`
  - Sets `approved_by`, `approved_at`, `approval_notes`

#### **Step 4: User Can Login (Mobile App)**
- **Endpoint:** `POST /api/auth/login/`
- **Location:** `frontend/lib/features/auth/presentation/screens/login_screen.dart`
- **Backend Check:** `backend/accounts/views.py` - `LoginView.post()`
  - For Farmers: Must have `is_approved_by_admin=True`
  - For Local Vets: Must have `is_approved_by_admin=True`
  - Returns `pending_approval: true` if not approved

---

## 2. 📋 Case Reporting & Assignment Flow

### Mobile App → Web Dashboard → Mobile App Flow

#### **Step 1: Farmer Reports Case (Mobile App)**
- **Endpoint:** `POST /api/cases/reports/`
- **Location:** `frontend/lib/features/cases/presentation/screens/report_case_screen.dart`
- **API Service:** `frontend/lib/core/services/api_service.dart` - `createCase()`
- **Backend:** `backend/cases/views.py` - `CaseReportViewSet.create()`
- **Initial Status:** `status='pending'`
- **Assigned Vet:** `assigned_veterinarian=None` (unassigned)

#### **Step 2: Case Appears in Web Dashboard**
- **Endpoint:** `GET /api/cases/reports/`
- **Location:** `web-dashboard/src/pages/CasesPage.js`
- **Who Can View:**
  - ✅ **Sector Vets** - See all cases
  - ✅ **Admins** - See all cases
  - ❌ **Local Vets** - Cannot access web dashboard
  - ❌ **Farmers** - Cannot access web dashboard
- **Backend Logic:** `backend/cases/views.py` - `CaseReportViewSet.get_queryset()`
  - Sector Vets/Admins: See all cases
  - Farmers: Only see their own cases
  - Local Vets: Only see cases assigned to them

#### **Step 3: Sector Vet Assigns Case to Local Vet (Web Dashboard)**
- **Endpoint:** `POST /api/cases/reports/{id}/assign/`
- **Location:** `web-dashboard/src/pages/CasesPage.js` or `VeterinariansPage.js`
- **Request Body:** `{ "veterinarian_id": <local_vet_id> }`
- **Backend Logic:** `backend/cases/views.py` - `CaseReportViewSet.assign()`
  - Checks if assigner is Sector Vet or Admin
  - Validates veterinarian exists and is `user_type='local_vet'`
  - Checks if vet is available (`vet_profile.is_available=True`)
  - Updates case:
    - `assigned_veterinarian = veterinarian`
    - `assigned_at = now()`
    - `assigned_by = assigner`
    - `status = 'under_review'`
  - Creates notification for assigned veterinarian

#### **Step 4: Local Vet Sees Assigned Case (Mobile App)**
- **Endpoint:** `GET /api/cases/reports/`
- **Location:** `frontend/lib/features/home/presentation/screens/vet_dashboard_screen.dart`
- **API Service:** `frontend/lib/core/services/api_service.dart` - `getCases()`
- **Backend Logic:** `backend/cases/views.py` - `CaseReportViewSet.get_queryset()`
  - For Local Vets: Returns `CaseReport.objects.filter(assigned_veterinarian=user)`
  - Shows only cases assigned to that veterinarian
- **Current Status:** Uses mock data (`MockDataService.getMockVetAssignedCases()`)
  - ⚠️ **TODO:** Integrate with real API to fetch assigned cases

#### **Step 5: Local Vet Updates Case Status (Mobile App)**
- **Endpoint:** `PATCH /api/cases/reports/{id}/`
- **Location:** (Not yet implemented - needs case detail screen for vets)
- **API Service:** `frontend/lib/core/services/api_service.dart` - `updateCase()`
- **Possible Updates:**
  - Change status: `under_review` → `diagnosed` → `treated` → `resolved`
  - Add consultation notes
  - Update treatment plan

---

## 3. 👥 User Management Flow

### Web Dashboard Can View Users Registered from Mobile

#### **View All Farmers**
- **Endpoint:** `GET /api/farmers/`
- **Location:** `web-dashboard/src/pages/FarmersPage.js`
- **Backend:** `backend/accounts/views.py` - `FarmerViewSet.get_queryset()`
- **Filters Available:**
  - `is_approved_by_admin=true/false` - Filter by approval status
  - All farmers registered via mobile app are visible

#### **View All Veterinarians**
- **Endpoint:** `GET /api/veterinarians/`
- **Location:** `web-dashboard/src/pages/VeterinariansPage.js`
- **Backend:** `backend/accounts/views.py` - `VeterinarianViewSet.get_queryset()`
- **Shows:**
  - Local Vets registered via mobile app
  - Sector Vets (usually created via web dashboard)
  - Status: Available, Busy, Offline
  - License numbers, specializations

#### **Assign Cases to Local Vets**
- **Endpoint:** `POST /api/cases/reports/{id}/assign/`
- **Location:** `web-dashboard/src/pages/VeterinariansPage.js` or `CasesPage.js`
- **Functionality:**
  - View all local veterinarians
  - Select unassigned case
  - Assign case to specific veterinarian
  - Veterinarian receives notification

---

## 4. 🔄 Data Synchronization

### Real-time Updates

#### **Notifications System**
- **Backend:** `backend/notifications/views.py`
- **When Case Assigned:**
  - Notification created automatically
  - `Notification.objects.create()` in `CaseReportViewSet.assign()`
  - Recipient: Assigned veterinarian
  - Channel: `in_app`
  - Status: `sent`

#### **Mobile App Notifications**
- **Endpoint:** `GET /api/notifications/`
- **Location:** (Not yet fully implemented)
- **Should Show:**
  - New case assignments
  - Case status updates
  - Broadcast messages

---

## 5. ✅ Current Status

### Working Features

1. ✅ **User Registration (Mobile → Backend)**
   - Farmers and Local Vets can register
   - Data stored in backend database

2. ✅ **User Approval (Web Dashboard)**
   - Sector Vets can view pending users
   - Can approve/reject with notes
   - Updates reflected in backend

3. ✅ **Case Reporting (Mobile → Backend)**
   - Farmers can report cases
   - Cases stored in backend

4. ✅ **Case Assignment (Web Dashboard → Backend)**
   - Sector Vets can assign cases to Local Vets
   - Notification created automatically
   - Case status updated

5. ✅ **Case Viewing (Web Dashboard)**
   - Sector Vets can see all cases
   - Can filter by status, urgency, assigned vet

### ⚠️ Needs Improvement

1. ⚠️ **Case Fetching (Mobile App)**
   - **Current:** Uses mock data (`MockDataService.getMockVetAssignedCases()`)
   - **Should:** Fetch from API `GET /api/cases/reports/`
   - **Backend:** Already filters by `assigned_veterinarian` for Local Vets
   - **Issue:** API endpoint path corrected from `/cases/` to `/cases/reports/`

2. ⚠️ **User Profile Status (Mobile App)**
   - **Current:** Shows "Pending Approval" badge but doesn't check real status
   - **Should:** Fetch user profile from API to check `is_approved_by_admin`
   - **Endpoint:** `GET /api/users/profile/` or `GET /api/users/{id}/`

3. ⚠️ **Real-time Notifications (Mobile App)**
   - **Current:** Not fully implemented
   - **Should:** Poll or use WebSocket for new notifications
   - **Endpoint:** `GET /api/notifications/`

4. ⚠️ **Case Status Updates (Mobile App)**
   - **Current:** Vet dashboard shows cases but no update functionality
   - **Should:** Allow vets to update case status, add notes
   - **Endpoint:** `PATCH /api/cases/reports/{id}/`

---

## 6. 🔌 API Endpoints Summary

### Authentication
- `POST /api/auth/register/` - Register new user (Mobile/Web)
- `POST /api/auth/login/` - Login user (Mobile/Web)
- `POST /api/auth/verify-otp/` - Verify OTP (Mobile)

### Users
- `GET /api/users/` - List all users (Web - Sector Vets/Admins)
- `GET /api/users/pending_approval/` - Get pending approvals (Web - Sector Vets/Admins)
- `POST /api/users/{id}/approve/` - Approve user (Web - Sector Vets/Admins)
- `POST /api/users/{id}/reject/` - Reject user (Web - Sector Vets/Admins)
- `GET /api/farmers/` - List farmers (Web - Sector Vets/Admins)
- `GET /api/veterinarians/` - List veterinarians (Web - Sector Vets/Admins)

### Cases
- `GET /api/cases/reports/` - List cases (filtered by user role)
  - **Farmers:** Only their own cases
  - **Local Vets:** Only assigned cases
  - **Sector Vets/Admins:** All cases
- `POST /api/cases/reports/` - Create case (Mobile - Farmers)
- `GET /api/cases/reports/{id}/` - Get case details
- `PATCH /api/cases/reports/{id}/` - Update case
- `POST /api/cases/reports/{id}/assign/` - Assign case (Web - Sector Vets/Admins)
- `POST /api/cases/reports/{id}/unassign/` - Unassign case (Web - Sector Vets/Admins)

### Notifications
- `GET /api/notifications/` - Get user notifications (Mobile/Web)
- `GET /api/broadcasts/` - Get broadcasts (Web - Sector Vets/Admins)
- `POST /api/broadcasts/` - Create broadcast (Web - Sector Vets/Admins)
- `POST /api/broadcasts/{id}/send/` - Send broadcast (Web - Sector Vets/Admins)

---

## 7. 🧪 Testing the Collaboration

### Test Scenario 1: Register Local Vet and Approve

1. **Mobile App:**
   - Register as "Local Veterinarian"
   - Fill in details (name, phone, password, etc.)
   - Submit registration
   - Complete OTP verification (enter any 4 digits)
   - Should see vet dashboard with "Pending Approval" status

2. **Web Dashboard:**
   - Login as Sector Vet
   - Go to "User Approval" page
   - Should see the registered Local Vet in pending list
   - Click "Approve" with optional notes
   - Local Vet should now be approved

3. **Mobile App (After Approval):**
   - Local Vet can now login
   - "Pending Approval" badge should be removed (after API integration)
   - Can receive case assignments

### Test Scenario 2: Case Assignment Flow

1. **Mobile App (Farmer):**
   - Login as Farmer
   - Go to Cases tab
   - Click "Report Case"
   - Fill in case details and submit
   - Case created with status "pending"

2. **Web Dashboard (Sector Vet):**
   - Login as Sector Vet
   - Go to "Cases" page
   - Should see the newly reported case
   - Click "Assign" on the case
   - Select a Local Veterinarian from dropdown
   - Click "Assign Case"
   - Case status changes to "under_review"

3. **Mobile App (Local Vet):**
   - Login as Local Veterinarian
   - Go to "Cases" tab in vet dashboard
   - Should see the assigned case (after API integration)
   - Currently shows mock data

---

## 8. 🔧 Required Fixes

### API Endpoint Path Correction
**File:** `frontend/lib/core/services/api_service.dart`
- ✅ **Fixed:** Changed `/cases/` to `/cases/reports/` for all case endpoints
- **Reason:** Backend routes cases under `/api/cases/reports/`

### Integration Needed

1. **Vet Dashboard Case Fetching**
   - Replace `MockDataService.getMockVetAssignedCases()` with API call
   - Use `ApiService.getCases()` which already filters by assigned vet
   - Update `vet_dashboard_screen.dart` to use real data

2. **User Approval Status Check**
   - Fetch user profile on login or dashboard load
   - Check `is_approved_by_admin` status
   - Update UI accordingly (remove "Pending Approval" badge when approved)

3. **Notification Polling**
   - Implement notification fetching
   - Show notification count in app
   - Display new case assignments

---

## 9. ✅ Verification Checklist

### Registration Flow
- [x] Mobile app can register Local Vets
- [x] Web dashboard can view pending Local Vets
- [x] Web dashboard can approve Local Vets
- [x] Approved users can login
- [ ] Mobile app reflects approval status in real-time

### Case Flow
- [x] Mobile app (Farmer) can report cases
- [x] Web dashboard can view all cases
- [x] Web dashboard can assign cases to Local Vets
- [x] Backend creates notifications on assignment
- [ ] Mobile app (Local Vet) fetches assigned cases from API
- [ ] Mobile app (Local Vet) can update case status

### User Management
- [x] Web dashboard can view all farmers
- [x] Web dashboard can view all veterinarians
- [x] Web dashboard can filter by approval status
- [x] Web dashboard can view user profiles

---

## 10. 📊 Data Flow Diagram

```
┌─────────────────┐
│  Mobile App     │
│  (Flutter)      │
└────────┬────────┘
         │
         │ 1. Register User
         │ POST /api/auth/register/
         ▼
┌─────────────────┐
│  Backend API    │
│  (Django REST)  │
│  User Created   │
│  is_approved=   │
│  False          │
└────────┬────────┘
         │
         │ 2. View Pending Users
         │ GET /api/users/pending_approval/
         ▼
┌─────────────────┐
│  Web Dashboard  │
│  (React.js)     │
│  Sector Vet     │
│  Reviews User   │
└────────┬────────┘
         │
         │ 3. Approve User
         │ POST /api/users/{id}/approve/
         ▼
┌─────────────────┐
│  Backend API    │
│  User Updated   │
│  is_approved=   │
│  True           │
└────────┬────────┘
         │
         │ 4. User Can Login
         │ POST /api/auth/login/
         ▼
┌─────────────────┐
│  Mobile App     │
│  User Logged In │
└─────────────────┘

┌─────────────────┐
│  Mobile App     │
│  (Farmer)       │
└────────┬────────┘
         │
         │ 1. Report Case
         │ POST /api/cases/reports/
         ▼
┌─────────────────┐
│  Backend API    │
│  Case Created   │
│  status=pending │
│  assigned_vet=  │
│  None           │
└────────┬────────┘
         │
         │ 2. View All Cases
         │ GET /api/cases/reports/
         ▼
┌─────────────────┐
│  Web Dashboard  │
│  Sector Vet     │
│  Sees Case      │
└────────┬────────┘
         │
         │ 3. Assign to Local Vet
         │ POST /api/cases/reports/{id}/assign/
         ▼
┌─────────────────┐
│  Backend API    │
│  Case Updated   │
│  assigned_vet=  │
│  Local Vet ID   │
│  Notification   │
│  Created        │
└────────┬────────┘
         │
         │ 4. Fetch Assigned Cases
         │ GET /api/cases/reports/
         │ (filtered by assigned_veterinarian)
         ▼
┌─────────────────┐
│  Mobile App     │
│  (Local Vet)    │
│  Sees Case      │
└─────────────────┘
```

---

## Conclusion

The collaboration between web dashboard and mobile app is **well-structured** with proper API endpoints and backend logic. The main areas needing attention are:

1. ✅ **Fixed:** API endpoint paths corrected
2. ⚠️ **Pending:** Integration of real API calls in vet dashboard (currently uses mock data)
3. ⚠️ **Pending:** Real-time approval status checking in mobile app
4. ⚠️ **Pending:** Case status update functionality for local vets

The backend already handles all the filtering and permissions correctly. The mobile app just needs to connect to the real API instead of using mock data.

