# AnimalGuardian Endpoint Testing Guide

## Overview
This document provides a comprehensive guide for testing all API endpoints for Sector Vet, Local Vet, and Farmer roles.

## Test Script
Run the automated test script:
```bash
python test_endpoints_by_role.py
```

**Note:** Before running, update `TEST_CREDENTIALS` in the script with real test account credentials.

---

## Endpoint Permissions by Role

### 1. PUBLIC ENDPOINTS (No Authentication Required)
All roles can access these endpoints:

- `GET /api/livestock/types/` - Get livestock types
- `GET /api/livestock/breeds/` - Get breeds
- `GET /api/cases/diseases/` - Get diseases
- `GET /api/marketplace/categories/` - Get marketplace categories
- `GET /api/marketplace/products/` - Get marketplace products

---

### 2. FARMER ENDPOINTS

#### Authentication
- `POST /api/auth/register/` - Register new farmer
- `POST /api/auth/login/` - Login
- `POST /api/auth/verify-otp/` - Verify OTP

#### Livestock Management
- ✅ `GET /api/livestock/` - **View own livestock only**
- ✅ `POST /api/livestock/` - **Create livestock** (Only farmers can create)
- ✅ `GET /api/livestock/{id}/` - View livestock details
- ✅ `PATCH /api/livestock/{id}/` - Update own livestock
- ✅ `DELETE /api/livestock/{id}/` - Delete own livestock

#### Case Management
- ✅ `GET /api/cases/reports/` - **View own cases only**
- ✅ `POST /api/cases/reports/` - **Create case report** (Only farmers can create)
- ✅ `GET /api/cases/reports/{id}/` - View case details
- ❌ `PATCH /api/cases/reports/{id}/` - Cannot update cases (read-only)
- ❌ `POST /api/cases/reports/{id}/assign/` - Cannot assign cases

#### Community
- ✅ `GET /api/community/posts/` - View community posts
- ✅ `POST /api/community/posts/` - Create post
- ✅ `GET /api/community/comments/` - View comments
- ✅ `POST /api/community/comments/` - Create comment

#### Notifications
- ✅ `GET /api/notifications/` - View own notifications

#### Weather
- ✅ `GET /api/weather/` - Get weather data

#### Dashboard
- ✅ `GET /api/dashboard/stats/` - Get dashboard statistics

#### Restricted (Should Fail)
- ❌ `GET /api/users/` - Cannot view all users
- ❌ `GET /api/farmers/` - Cannot view all farmers
- ❌ `GET /api/veterinarians/` - Cannot view veterinarians
- ❌ `GET /api/broadcasts/` - Cannot view broadcasts

---

### 3. LOCAL VET ENDPOINTS

#### Authentication
- `POST /api/auth/register/` - Register new local vet (requires approval)
- `POST /api/auth/login/` - Login
- `POST /api/auth/verify-otp/` - Verify OTP

#### Case Management
- ✅ `GET /api/cases/reports/` - **View assigned cases only**
- ❌ `POST /api/cases/reports/` - **Cannot create cases** (Only farmers can create)
- ✅ `GET /api/cases/reports/{id}/` - View case details
- ✅ `PATCH /api/cases/reports/{id}/` - **Update assigned case status**
- ❌ `POST /api/cases/reports/{id}/assign/` - Cannot assign cases

#### Livestock Management
- ✅ `GET /api/livestock/` - **View livestock from assigned cases** (Read-only)
- ❌ `POST /api/livestock/` - **Cannot create livestock** (Only farmers can create)
- ✅ `GET /api/livestock/{id}/` - View livestock details (from assigned cases)
- ❌ `PATCH /api/livestock/{id}/` - Cannot update livestock
- ❌ `DELETE /api/livestock/{id}/` - Cannot delete livestock

#### Community
- ✅ `GET /api/community/posts/` - View community posts
- ✅ `POST /api/community/posts/` - Create post
- ✅ `GET /api/community/comments/` - View comments
- ✅ `POST /api/community/comments/` - Create comment

#### Notifications
- ✅ `GET /api/notifications/` - View own notifications

#### Weather
- ✅ `GET /api/weather/` - Get weather data

#### Dashboard
- ✅ `GET /api/dashboard/stats/` - Get dashboard statistics

#### Restricted (Should Fail)
- ❌ `GET /api/users/` - Cannot view all users
- ❌ `GET /api/farmers/` - Cannot view all farmers
- ❌ `GET /api/veterinarians/` - Cannot view all veterinarians
- ❌ `GET /api/broadcasts/` - Cannot view broadcasts
- ❌ `POST /api/broadcasts/` - Cannot create broadcasts

---

### 4. SECTOR VET ENDPOINTS

#### Authentication
- `POST /api/auth/login/` - Login (Sector vets are created by admin, not via registration)

#### User Management
- ✅ `GET /api/users/` - **View all users**
- ✅ `GET /api/farmers/` - **View all farmers**
- ✅ `GET /api/veterinarians/` - **View all veterinarians**
- ✅ `PATCH /api/farmers/{id}/` - Approve/reject farmers
- ✅ `PATCH /api/veterinarians/{id}/` - Approve/reject local vets

#### Case Management
- ✅ `GET /api/cases/reports/` - **View all cases**
- ❌ `POST /api/cases/reports/` - **Cannot create cases** (Only farmers can create)
- ✅ `GET /api/cases/reports/{id}/` - View case details
- ✅ `PATCH /api/cases/reports/{id}/` - Update case
- ✅ `POST /api/cases/reports/{id}/assign/` - **Assign case to local vet**

#### Livestock Management
- ✅ `GET /api/livestock/` - **View all livestock** (Read-only)
- ❌ `POST /api/livestock/` - **Cannot create livestock** (Only farmers can create)
- ✅ `GET /api/livestock/{id}/` - View livestock details
- ❌ `PATCH /api/livestock/{id}/` - Cannot update livestock
- ❌ `DELETE /api/livestock/{id}/` - Cannot delete livestock

#### Broadcasts
- ✅ `GET /api/broadcasts/` - **View all broadcasts**
- ✅ `POST /api/broadcasts/` - **Create broadcast**
- ✅ `POST /api/broadcasts/{id}/send/` - **Send broadcast**

#### Notifications
- ✅ `GET /api/notifications/` - View notifications

#### Weather
- ✅ `GET /api/weather/` - Get weather data

#### Dashboard
- ✅ `GET /api/dashboard/stats/` - Get dashboard statistics

---

## Testing Checklist

### Farmer Tests
- [ ] Can register via mobile app
- [ ] Can login
- [ ] Can create livestock
- [ ] Can view own livestock only
- [ ] Can update own livestock
- [ ] Can create case reports
- [ ] Can view own cases only
- [ ] Cannot view other farmers' livestock
- [ ] Cannot view other farmers' cases
- [ ] Cannot access admin endpoints
- [ ] Cannot assign cases
- [ ] Cannot create broadcasts

### Local Vet Tests
- [ ] Can register via mobile app (requires approval)
- [ ] Can login (after approval)
- [ ] Can view assigned cases only
- [ ] Can update assigned case status
- [ ] Cannot create cases
- [ ] Cannot create livestock
- [ ] Can view livestock from assigned cases
- [ ] Cannot view all livestock
- [ ] Cannot access admin endpoints
- [ ] Cannot assign cases
- [ ] Cannot create broadcasts

### Sector Vet Tests
- [ ] Can login (created by admin)
- [ ] Can view all users
- [ ] Can view all farmers
- [ ] Can view all veterinarians
- [ ] Can approve/reject farmers
- [ ] Can approve/reject local vets
- [ ] Can view all cases
- [ ] Can assign cases to local vets
- [ ] Cannot create cases
- [ ] Cannot create livestock
- [ ] Can view all livestock (read-only)
- [ ] Can create broadcasts
- [ ] Can send broadcasts

---

## Manual Testing Commands

### Test Farmer Endpoints
```bash
# Login as farmer
curl -X POST https://animalguardian-backend-production-b5a8.up.railway.app/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+250788000003", "password": "testpass123"}'

# Get token from response, then:
TOKEN="your_token_here"

# Create livestock (should succeed)
curl -X POST https://animalguardian-backend-production-b5a8.up.railway.app/api/livestock/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"livestock_type": 1, "name": "Test Cow", "gender": "F", "status": "healthy"}'

# Create case (should succeed)
curl -X POST https://animalguardian-backend-production-b5a8.up.railway.app/api/cases/reports/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"livestock": 1, "symptoms_observed": "Test symptoms", "urgency": "medium"}'

# Try to access admin endpoint (should fail with 403)
curl -X GET https://animalguardian-backend-production-b5a8.up.railway.app/api/users/ \
  -H "Authorization: Bearer $TOKEN"
```

### Test Local Vet Endpoints
```bash
# Login as local vet
curl -X POST https://animalguardian-backend-production-b5a8.up.railway.app/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+250788000002", "password": "testpass123"}'

TOKEN="your_token_here"

# View assigned cases (should succeed)
curl -X GET https://animalguardian-backend-production-b5a8.up.railway.app/api/cases/reports/ \
  -H "Authorization: Bearer $TOKEN"

# Try to create case (should fail with 403)
curl -X POST https://animalguardian-backend-production-b5a8.up.railway.app/api/cases/reports/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"livestock": 1, "symptoms_observed": "Test", "urgency": "medium"}'

# Try to create livestock (should fail with 403)
curl -X POST https://animalguardian-backend-production-b5a8.up.railway.app/api/livestock/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"livestock_type": 1, "name": "Test", "gender": "F"}'
```

### Test Sector Vet Endpoints
```bash
# Login as sector vet
curl -X POST https://animalguardian-backend-production-b5a8.up.railway.app/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+250788000001", "password": "testpass123"}'

TOKEN="your_token_here"

# View all users (should succeed)
curl -X GET https://animalguardian-backend-production-b5a8.up.railway.app/api/users/ \
  -H "Authorization: Bearer $TOKEN"

# Assign case (should succeed)
curl -X POST https://animalguardian-backend-production-b5a8.up.railway.app/api/cases/reports/1/assign/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"veterinarian_id": 2}'

# Try to create case (should fail with 403)
curl -X POST https://animalguardian-backend-production-b5a8.up.railway.app/api/cases/reports/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"livestock": 1, "symptoms_observed": "Test", "urgency": "medium"}'

# Create broadcast (should succeed)
curl -X POST https://animalguardian-backend-production-b5a8.up.railway.app/api/broadcasts/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Broadcast", "message": "Test message", "channel": "in_app"}'
```

---

## Expected Test Results

### Farmer
- ✅ Can create livestock
- ✅ Can create cases
- ✅ Can view own data only
- ❌ Cannot access admin endpoints
- ❌ Cannot assign cases

### Local Vet
- ❌ Cannot create livestock
- ❌ Cannot create cases
- ✅ Can view assigned cases
- ✅ Can update case status
- ❌ Cannot access admin endpoints
- ❌ Cannot assign cases

### Sector Vet
- ❌ Cannot create livestock
- ❌ Cannot create cases
- ✅ Can view all data
- ✅ Can assign cases
- ✅ Can create broadcasts
- ✅ Can manage users

---

## Notes

1. **Test Accounts**: Create test accounts for each role before running tests
2. **Approval Status**: Local vets must be approved by sector vet before they can login
3. **Case Assignment**: Cases must exist before testing assignment
4. **Livestock Ownership**: Farmers can only see/modify their own livestock
5. **Case Visibility**: 
   - Farmers see only their own cases
   - Local vets see only assigned cases
   - Sector vets see all cases

