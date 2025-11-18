# AnimalGuardian Endpoint Test Summary

## Test Script Created
- **File**: `test_endpoints_by_role.py`
- **Purpose**: Comprehensive testing of all API endpoints for Sector Vet, Local Vet, and Farmer roles

## Setup Required

### 1. Create Test Accounts
Before running tests, create test accounts for each role:

**Sector Vet:**
- Phone: `+250788000001`
- Password: `testpass123`
- Created via admin dashboard (not via registration)

**Local Vet:**
- Phone: `+250788000002`
- Password: `testpass123`
- Register via mobile app, then approve via sector vet dashboard

**Farmer:**
- Phone: `+250788000003`
- Password: `testpass123`
- Register via mobile app or USSD

### 2. Update Test Script
Edit `test_endpoints_by_role.py` and update `TEST_CREDENTIALS` with actual test account credentials.

## Endpoint Test Matrix

### Public Endpoints (No Auth)
| Endpoint | Expected Status | Notes |
|----------|----------------|-------|
| `GET /api/livestock/types/` | 200 | May require auth (check backend) |
| `GET /api/livestock/breeds/` | 200 | May require auth (check backend) |
| `GET /api/cases/diseases/` | 200 | May require auth (check backend) |
| `GET /api/marketplace/categories/` | 200 | ✅ Public |
| `GET /api/marketplace/products/` | 200 | ✅ Public |

### Farmer Endpoints
| Endpoint | Method | Expected | Notes |
|----------|--------|----------|-------|
| `/api/livestock/` | GET | 200 | Own livestock only |
| `/api/livestock/` | POST | 201 | ✅ Can create |
| `/api/cases/reports/` | GET | 200 | Own cases only |
| `/api/cases/reports/` | POST | 201 | ✅ Can create |
| `/api/users/` | GET | 403 | ❌ Should fail |
| `/api/farmers/` | GET | 403 | ❌ Should fail |
| `/api/veterinarians/` | GET | 403 | ❌ Should fail |
| `/api/broadcasts/` | GET | 403 | ❌ Should fail |

### Local Vet Endpoints
| Endpoint | Method | Expected | Notes |
|----------|--------|----------|-------|
| `/api/cases/reports/` | GET | 200 | Assigned cases only |
| `/api/cases/reports/` | POST | 403 | ❌ Cannot create |
| `/api/cases/reports/{id}/` | PATCH | 200 | Can update status |
| `/api/livestock/` | GET | 200 | From assigned cases |
| `/api/livestock/` | POST | 403 | ❌ Cannot create |
| `/api/cases/reports/{id}/assign/` | POST | 403 | ❌ Cannot assign |
| `/api/users/` | GET | 403 | ❌ Should fail |
| `/api/broadcasts/` | GET | 403 | ❌ Should fail |

### Sector Vet Endpoints
| Endpoint | Method | Expected | Notes |
|----------|--------|----------|-------|
| `/api/users/` | GET | 200 | ✅ Can view all |
| `/api/farmers/` | GET | 200 | ✅ Can view all |
| `/api/veterinarians/` | GET | 200 | ✅ Can view all |
| `/api/cases/reports/` | GET | 200 | ✅ All cases |
| `/api/cases/reports/` | POST | 403 | ❌ Cannot create |
| `/api/cases/reports/{id}/assign/` | POST | 200 | ✅ Can assign |
| `/api/livestock/` | GET | 200 | ✅ All livestock |
| `/api/livestock/` | POST | 403 | ❌ Cannot create |
| `/api/broadcasts/` | GET | 200 | ✅ Can view |
| `/api/broadcasts/` | POST | 201 | ✅ Can create |

## Key Test Scenarios

### 1. Farmer Can Create Livestock ✅
- **Test**: POST `/api/livestock/` as farmer
- **Expected**: 201 Created
- **Verify**: Livestock is created with farmer as owner

### 2. Farmer Can Create Cases ✅
- **Test**: POST `/api/cases/reports/` as farmer
- **Expected**: 201 Created
- **Verify**: Case is created with farmer as reporter

### 3. Local Vet Cannot Create Cases ❌
- **Test**: POST `/api/cases/reports/` as local vet
- **Expected**: 403 Forbidden
- **Verify**: Error message indicates permission denied

### 4. Local Vet Cannot Create Livestock ❌
- **Test**: POST `/api/livestock/` as local vet
- **Expected**: 403 Forbidden
- **Verify**: Error message indicates only farmers can create

### 5. Sector Vet Cannot Create Cases ❌
- **Test**: POST `/api/cases/reports/` as sector vet
- **Expected**: 403 Forbidden
- **Verify**: Error message indicates permission denied

### 6. Sector Vet Cannot Create Livestock ❌
- **Test**: POST `/api/livestock/` as sector vet
- **Expected**: 403 Forbidden
- **Verify**: Error message indicates only farmers can create

### 7. Sector Vet Can Assign Cases ✅
- **Test**: POST `/api/cases/reports/{id}/assign/` as sector vet
- **Expected**: 200 OK
- **Verify**: Case is assigned to local vet

### 8. Local Vet Can View Assigned Cases Only ✅
- **Test**: GET `/api/cases/reports/` as local vet
- **Expected**: 200 OK
- **Verify**: Only cases assigned to this vet are returned

### 9. Farmer Can View Own Cases Only ✅
- **Test**: GET `/api/cases/reports/` as farmer
- **Expected**: 200 OK
- **Verify**: Only cases created by this farmer are returned

### 10. Sector Vet Can View All Cases ✅
- **Test**: GET `/api/cases/reports/` as sector vet
- **Expected**: 200 OK
- **Verify**: All cases are returned

## Running Tests

### Option 1: Automated Script
```bash
python test_endpoints_by_role.py
```

### Option 2: Manual Testing
Use the curl commands in `ENDPOINT_TESTING_GUIDE.md`

### Option 3: Postman/Insomnia
Import the endpoints from the guide and test manually

## Expected Results

After running tests with valid credentials:

- **Public Endpoints**: All should pass (if truly public)
- **Farmer Tests**: 
  - ✅ Can create livestock and cases
  - ❌ Cannot access admin endpoints
- **Local Vet Tests**:
  - ✅ Can view assigned cases
  - ❌ Cannot create cases or livestock
- **Sector Vet Tests**:
  - ✅ Can view all data
  - ✅ Can assign cases
  - ❌ Cannot create cases or livestock

## Notes

1. Some endpoints may require authentication even if marked as public (check backend settings)
2. Test accounts must be created and approved before testing
3. Local vets must be approved by sector vet before they can login
4. Cases must exist before testing assignment functionality
5. Livestock must exist before testing case creation

