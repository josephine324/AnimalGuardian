# AnimalGuardian Technical Architecture & Data Flow
## Complete Technical Explanation for Panel Presentation

---

## 📋 Table of Contents
1. [System Overview](#system-overview)
2. [Architecture Components](#architecture-components)
3. [Data Flow - How Information Moves](#data-flow)
4. [Database Structure & Storage](#database-structure)
5. [Security Measures](#security-measures)
6. [How Everything Works Together](#how-everything-works-together)

---

## 🏗️ System Overview

**AnimalGuardian** is a digital livestock management system built with:
- **Backend**: Django REST Framework (Python)
- **Frontend**: React (Web Dashboard) and Flutter (Mobile App)
- **Database**: PostgreSQL (Production) or SQLite (Development)
- **Authentication**: JWT (JSON Web Tokens)

Think of it like a **three-layer cake**:
1. **Top Layer (Frontend)**: What users see and interact with
2. **Middle Layer (Backend API)**: The brain that processes requests
3. **Bottom Layer (Database)**: Where all data is stored permanently

---

## 🧩 Architecture Components

### 1. **Frontend Applications**
- **Web Dashboard** (React): For admins and veterinarians to manage the system
- **Mobile App** (Flutter): For farmers to register livestock, report cases, etc.
- **USSD Service**: For farmers without smartphones (basic phone access)

### 2. **Backend API Server**
- **Django Framework**: Handles all business logic
- **REST API**: Provides endpoints for data operations
- **Authentication System**: Verifies user identity
- **File Storage**: Stores images and documents

### 3. **Database**
- **PostgreSQL** (Production): Professional database system
- **SQLite** (Development): Simple file-based database for testing
- Stores: Users, Livestock, Cases, Notifications, etc.

---

## 🔄 Data Flow - How Information Moves

### **Example: A Farmer Adds a New Cow**

Let's trace what happens when a farmer adds a new cow to the system:

#### **Step 1: User Action (Frontend)**
```
Farmer opens mobile app → Clicks "Add Livestock" → Fills form → Clicks "Save"
```

**What happens:**
- Mobile app creates a JSON object with cow information:
```json
{
  "name": "Bella",
  "livestock_type": 1,
  "breed": 2,
  "gender": "F",
  "birth_date": "2020-05-15",
  "weight_kg": 350
}
```

#### **Step 2: Request Sent to Backend**
```
Mobile App → HTTP POST Request → https://animalguardian.onrender.com/api/livestock/
```

**Request includes:**
- **URL**: `/api/livestock/`
- **Method**: POST (create new record)
- **Headers**: 
  - `Authorization: Bearer <JWT_TOKEN>` (proves user is logged in)
  - `Content-Type: application/json`
- **Body**: The JSON data about the cow

#### **Step 3: Backend Receives Request**

**Django URL Router** (`urls.py`):
```
/api/livestock/ → routes to → livestock/views.py → LivestockViewSet
```

**Middleware Processing** (happens automatically):
1. **CORS Middleware**: Checks if request is from allowed origin
2. **Security Middleware**: Adds security headers
3. **Authentication Middleware**: Extracts JWT token from header
4. **Permission Check**: Verifies user has permission to create livestock

#### **Step 4: Authentication & Authorization**

**JWT Token Verification:**
```
Backend extracts token → Validates signature → Extracts user info → Loads user from database
```

**What the token contains:**
- User ID
- Username
- Expiration time
- Signature (prevents tampering)

**Permission Check:**
- System checks: "Is this user a farmer? Can they create livestock?"
- If yes → Continue
- If no → Return error "Permission Denied"

#### **Step 5: Data Validation**

**Serializer** (`livestock/serializers.py`):
```python
# Checks:
- Is livestock_type valid?
- Is breed valid?
- Is birth_date in the past?
- Is weight_kg a positive number?
- Are required fields present?
```

**If validation fails:**
- Returns error message to frontend
- No data is saved

**If validation passes:**
- Data is cleaned and formatted
- Ready to save to database

#### **Step 6: Database Operation**

**Django ORM (Object-Relational Mapping):**
```python
# Creates SQL query automatically:
INSERT INTO livestock (
    owner_id, livestock_type_id, breed_id, name, 
    gender, birth_date, weight_kg, created_at
) VALUES (
    123, 1, 2, 'Bella', 'F', '2020-05-15', 350, NOW()
)
```

**Database executes:**
- Opens connection to PostgreSQL
- Executes INSERT query
- Returns new record ID (e.g., 456)

#### **Step 7: Response Sent Back**

**Backend creates response:**
```json
{
  "id": 456,
  "name": "Bella",
  "livestock_type": 1,
  "breed": 2,
  "gender": "F",
  "birth_date": "2020-05-15",
  "weight_kg": 350,
  "owner": 123,
  "created_at": "2024-01-15T10:30:00Z"
}
```

**HTTP Response:**
- Status Code: `201 Created` (success)
- Headers: Content-Type, CORS headers
- Body: JSON with new livestock data

#### **Step 8: Frontend Updates**

**Mobile App receives response:**
- Displays success message
- Adds new cow to list
- Updates UI to show the new livestock

---

## 💾 Database Structure & Storage

### **Database Tables (Think of them as Excel Sheets)**

#### **1. Users Table** (`users`)
Stores all user accounts:
```
| id | username | phone_number | email | password_hash | user_type | is_active | created_at |
|----|----------|--------------|-------|---------------|------------|-----------|------------|
| 1  | john_doe | 0781234567   | john@ | pbkdf2_sha256$| farmer     | True      | 2024-01-01 |
| 2  | dr_smith | 0799876543   | vet@  | pbkdf2_sha256$| sector_vet | True      | 2024-01-02 |
```

**Key Fields:**
- `id`: Unique identifier (Primary Key)
- `phone_number`: Login identifier (unique)
- `password_hash`: Encrypted password (never stored in plain text)
- `user_type`: farmer, sector_vet, local_vet, admin, field_officer
- `is_approved_by_admin`: Must be True for local_vets to login

#### **2. Livestock Table** (`livestock`)
Stores all animals:
```
| id | owner_id | livestock_type_id | breed_id | name | tag_number | gender | birth_date | weight_kg | status | created_at |
|----|----------|-------------------|----------|------|------------|--------|------------|-----------|--------|-------------|
| 1  | 1        | 1                 | 2        | Bella| TAG001     | F      | 2020-05-15 | 350       | healthy| 2024-01-15 |
| 2  | 1        | 1                 | 3        | Max  | TAG002     | M      | 2019-03-20 | 450       | healthy| 2024-01-16 |
```

**Relationships:**
- `owner_id` → Links to `users.id` (Foreign Key)
- `livestock_type_id` → Links to `livestock_types.id`
- `breed_id` → Links to `breeds.id`

#### **3. Livestock Types Table** (`livestock_types`)
Reference data:
```
| id | name | name_kinyarwanda | average_lifespan_years | gestation_period_days |
|----|------|------------------|------------------------|----------------------|
| 1  | Cow  | Inka             | 20                     | 280                  |
| 2  | Goat | Ihene             | 15                     | 150                  |
| 3  | Pig  | Ingurube          | 12                     | 114                  |
```

#### **4. Cases Table** (`case_reports`)
Disease/health case reports:
```
| id | reporter_id | livestock_id | disease_id | symptoms | status | created_at |
|----|-------------|-------------|------------|----------|--------|------------|
| 1  | 1           | 1           | 5          | Fever... | open   | 2024-01-20 |
```

#### **5. Veterinarian Profiles Table** (`veterinarian_profiles`)
Extended info for vets:
```
| id | user_id | license_number | license_type | specialization | is_available | rating |
|----|---------|----------------|--------------|----------------|--------------|--------|
| 1  | 2       | VET-2024-001   | licensed     | Large Animals  | True         | 4.5    |
```

### **Database Relationships**

**One-to-Many:**
- One User → Many Livestock (a farmer can have many animals)
- One Livestock → Many Vaccination Records

**One-to-One:**
- One User → One VeterinarianProfile (if user is a vet)
- One User → One FarmerProfile (if user is a farmer)

**Many-to-Many:**
- Cases can involve multiple livestock
- Veterinarians can handle multiple cases

### **Database Indexes (For Speed)**

Indexes are like bookmarks in a book - they help find data quickly:

```python
# Example indexes on users table:
- users_user_type_idx: Fast lookup by user_type
- users_created_at_idx: Fast sorting by creation date
- users_approved_idx: Fast filtering of approved users
```

**Why important:**
- Without indexes: Searching 10,000 users = scan all 10,000 rows
- With indexes: Searching 10,000 users = jump directly to relevant rows

---

## 🔒 Security Measures

### **1. Password Security**

#### **How Passwords Are Stored:**

**NEVER stored in plain text!**

**Process:**
1. User creates password: `"MyPassword123"`
2. Django uses **PBKDF2** algorithm with **SHA-256** hashing
3. Adds a random **salt** (unique per password)
4. Hashes password + salt multiple times (260,000 iterations)
5. Stores in database: `pbkdf2_sha256$260000$salt$hashed_value`

**Example:**
```
Original: "MyPassword123"
Stored:   "pbkdf2_sha256$260000$abc123xyz$def456uvw..."
```

**Why this is secure:**
- Even if database is hacked, passwords cannot be reversed
- Each password has unique salt (prevents rainbow table attacks)
- High iteration count (slow for attackers, fast for legitimate users)

#### **Password Validation:**
- Minimum length: 8 characters
- Cannot be too similar to username
- Cannot be common password (like "password123")
- Cannot be all numbers

### **2. JWT Authentication (JSON Web Tokens)**

#### **What is JWT?**
A secure way to prove identity without storing sessions on server.

**Token Structure:**
```
Header.Payload.Signature
```

**Example Token:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMjMsImV4cCI6MTcwNTI4MDAwMH0.signature_hash
```

**Parts:**
1. **Header**: Algorithm used (HS256)
2. **Payload**: User ID, expiration time, permissions
3. **Signature**: Prevents tampering (uses SECRET_KEY)

#### **How It Works:**

**Login Flow:**
```
1. User submits phone_number + password
2. Backend verifies credentials
3. Backend generates JWT token (valid for 24 hours)
4. Backend returns token to frontend
5. Frontend stores token (localStorage or secure storage)
```

**Subsequent Requests:**
```
1. Frontend sends request with: Authorization: Bearer <token>
2. Backend extracts token
3. Backend verifies signature (ensures token wasn't tampered)
4. Backend checks expiration
5. Backend loads user from database
6. Request proceeds
```

**Token Expiration:**
- **Access Token**: 24 hours (for regular API calls)
- **Refresh Token**: 7 days (to get new access token)

**Security Features:**
- Tokens are signed (cannot be modified)
- Tokens expire (limits damage if stolen)
- Tokens contain minimal info (no sensitive data)

### **3. HTTPS/SSL Encryption**

**All communication is encrypted:**
- Frontend ↔ Backend: HTTPS (encrypted)
- Backend ↔ Database: Encrypted connection (if PostgreSQL)

**What this means:**
- Even if someone intercepts network traffic, they see encrypted data
- Only the intended recipient can decrypt

### **4. CORS (Cross-Origin Resource Sharing)**

**Prevents unauthorized websites from accessing API:**

**Allowed Origins:**
- `https://animalguards.netlify.app` (Production frontend)
- `http://localhost:*` (Development only)

**What happens:**
- Browser checks: "Is this request from an allowed origin?"
- If yes → Request proceeds
- If no → Request blocked by browser

### **5. Input Validation & Sanitization**

**Every input is validated:**

**Example - Phone Number:**
```python
# Must match pattern: 078, 079, 073, or 072 followed by 7 digits
# Prevents SQL injection, XSS attacks
```

**Example - Email:**
```python
# Must be valid email format
# Prevents invalid data
```

**Example - Numbers:**
```python
# Weight must be positive number
# Prevents negative values, text in number fields
```

### **6. SQL Injection Prevention**

**Django ORM automatically prevents SQL injection:**

**Bad (Vulnerable):**
```python
# NEVER do this:
query = f"SELECT * FROM users WHERE phone_number = '{phone}'"
# Attacker could input: ' OR '1'='1
```

**Good (Django ORM):**
```python
# Django does this automatically:
User.objects.filter(phone_number=phone)
# Automatically escapes special characters
```

### **7. User Approval System**

**For Local Veterinarians:**
- Cannot login until approved by Sector Veterinarian or Admin
- `is_approved_by_admin` must be `True`
- Prevents unauthorized access

**Approval Process:**
1. Local vet registers
2. Account created but `is_approved_by_admin = False`
3. Sector vet/admin reviews application
4. Sector vet/admin approves → `is_approved_by_admin = True`
5. Local vet can now login

### **8. Role-Based Access Control**

**Different permissions for different user types:**

**Farmers:**
- Can create/read/update own livestock
- Can report cases
- Cannot approve users
- Cannot access admin dashboard

**Sector Veterinarians:**
- Can approve local vets
- Can view all cases in their sector
- Can update case status
- Cannot delete users

**Admins:**
- Full access to all features
- Can approve/reject any user
- Can delete users
- Can access analytics

**Implementation:**
```python
# In views.py:
permission_classes = [IsAuthenticated]

# Custom permission check:
if user.user_type != 'admin':
    return Response({'error': 'Permission denied'}, status=403)
```

### **9. Database Connection Security**

**PostgreSQL Connection:**
- Uses connection pooling (reuses connections)
- Connection timeout: 10 seconds
- Statement timeout: 30 seconds (prevents long-running queries)
- Connections encrypted (if database supports SSL)

### **10. Secret Key Management**

**SECRET_KEY:**
- Used to sign JWT tokens
- Stored in environment variables (not in code)
- Different for development vs production
- Never committed to version control

**Environment Variables:**
```
SECRET_KEY=your-secret-key-here
DATABASE_URL=postgresql://user:pass@host:port/dbname
AFRICASTALKING_API_KEY=your-api-key
```

---

## 🔗 How Everything Works Together

### **Complete User Journey: Registration to Adding Livestock**

#### **Phase 1: User Registration**

```
1. Farmer opens mobile app
2. Clicks "Register"
3. Fills form: phone_number, password, name, location
4. App sends POST /api/auth/register/
5. Backend validates data
6. Backend hashes password (PBKDF2)
7. Backend creates user in database
8. Backend sets is_verified = True (auto-verify)
9. Backend sets is_approved_by_admin = True (farmers auto-approved)
10. Backend returns success message
11. App shows "Registration successful"
```

#### **Phase 2: User Login**

```
1. Farmer enters phone_number + password
2. App sends POST /api/auth/login/
3. Backend finds user by phone_number
4. Backend checks password (compares hash)
5. Backend checks is_active = True
6. Backend checks is_approved_by_admin = True
7. Backend generates JWT token
8. Backend returns: {access_token, refresh_token, user_data}
9. App stores token in secure storage
10. App navigates to dashboard
```

#### **Phase 3: Adding Livestock**

```
1. Farmer clicks "Add Livestock"
2. Fills form: name, type, breed, gender, birth_date
3. App sends POST /api/livestock/ with Authorization header
4. Backend middleware extracts JWT token
5. Backend verifies token signature
6. Backend loads user from database
7. Backend checks permission (IsAuthenticated)
8. Backend validates data (serializer)
9. Backend creates Livestock object
10. Backend saves to database (INSERT query)
11. Backend returns new livestock data
12. App displays success + adds to list
```

#### **Phase 4: Reporting a Case**

```
1. Farmer notices sick cow
2. Clicks "Report Case"
3. Selects livestock, enters symptoms
4. App sends POST /api/cases/ with JWT token
5. Backend validates user is authenticated
6. Backend validates case data
7. Backend creates CaseReport in database
8. Backend creates Notification for nearby vets
9. Backend returns case ID
10. App shows "Case reported successfully"
11. Vets receive notification
```

### **Data Synchronization**

**How data stays consistent:**

1. **Single Source of Truth**: Database is the only source of truth
2. **All changes go through API**: No direct database access from frontend
3. **Transactions**: Multiple related operations happen together (all succeed or all fail)
4. **Timestamps**: Every record has `created_at` and `updated_at`

### **Error Handling**

**What happens when something goes wrong:**

**Example: Invalid Data**
```
1. User submits invalid data
2. Backend validation fails
3. Backend returns: {error: "Validation failed", details: {...}}
4. Frontend displays error message
5. User corrects and resubmits
```

**Example: Network Error**
```
1. Request fails (no internet)
2. Frontend catches error
3. Frontend shows "Connection error, please try again"
4. Data is not lost (stored locally if needed)
5. User retries when connection restored
```

**Example: Authentication Expired**
```
1. Token expires (24 hours passed)
2. Backend returns 401 Unauthorized
3. Frontend detects 401
4. Frontend uses refresh_token to get new access_token
5. Frontend retries original request
6. User doesn't notice (seamless)
```

---

## 📊 Database Schema Diagram (Simplified)

```
┌─────────────┐
│   users     │
├─────────────┤
│ id (PK)     │──┐
│ phone_number│  │
│ email       │  │
│ password    │  │
│ user_type   │  │
│ is_approved │  │
└─────────────┘  │
                 │
                 │ (owner_id)
                 │
┌────────────────┴──────────┐
│      livestock            │
├───────────────────────────┤
│ id (PK)                   │
│ owner_id (FK) ────────────┘
│ livestock_type_id (FK) ───┐
│ breed_id (FK) ────────────┤
│ name                       │
│ tag_number                 │
│ gender                     │
│ birth_date                 │
│ weight_kg                  │
│ status                     │
└───────────────────────────┘
         │
         │ (livestock_id)
         │
┌────────┴──────────────┐
│  vaccination_records  │
├───────────────────────┤
│ id (PK)               │
│ livestock_id (FK)     │
│ vaccine_name          │
│ vaccination_date      │
│ veterinarian_id (FK)  │
└───────────────────────┘

┌─────────────┐
│ case_reports│
├─────────────┤
│ id (PK)     │
│ reporter_id │──┐
│ livestock_id│  │
│ disease_id  │  │
│ symptoms    │  │
│ status      │  │
└─────────────┘  │
                 │
                 │ (user_id)
                 │
┌────────────────┴──────────┐
│ veterinarian_profiles     │
├───────────────────────────┤
│ id (PK)                   │
│ user_id (FK) ─────────────┘
│ license_number            │
│ specialization            │
│ is_available              │
│ rating                    │
└───────────────────────────┘
```

---

## 🎯 Key Takeaways for Panel

### **1. Security First**
- Passwords are never stored in plain text
- All communication is encrypted (HTTPS)
- JWT tokens expire automatically
- Users must be approved before accessing system
- Input validation prevents attacks

### **2. Scalable Architecture**
- Database indexes for fast queries
- Connection pooling for efficiency
- RESTful API design (standard, predictable)
- Separation of concerns (frontend, backend, database)

### **3. Data Integrity**
- All data validated before saving
- Foreign keys ensure relationships are valid
- Transactions ensure consistency
- Timestamps track all changes

### **4. User Experience**
- Fast response times (indexed database)
- Automatic token refresh (seamless login)
- Clear error messages
- Role-based access (users see only what they need)

### **5. Maintainability**
- Clean code structure
- Django ORM (no raw SQL)
- Comprehensive error handling
- Logging for debugging

---

## 📝 Technical Stack Summary

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Backend Framework** | Django REST Framework | API server, business logic |
| **Database** | PostgreSQL (prod) / SQLite (dev) | Data storage |
| **Authentication** | JWT (SimpleJWT) | Secure user authentication |
| **Frontend Web** | React | Admin/vet dashboard |
| **Frontend Mobile** | Flutter | Farmer mobile app |
| **Password Hashing** | PBKDF2 + SHA-256 | Secure password storage |
| **API Communication** | REST API (JSON) | Data exchange |
| **Security** | HTTPS, CORS, Input Validation | Protection against attacks |

---

## 🔍 Questions Panel Might Ask

### **Q: How do you ensure data privacy?**
**A:** 
- Passwords are hashed (cannot be reversed)
- JWT tokens expire (limited time access)
- HTTPS encrypts all communication
- Users can only access their own data (permission checks)
- Database access is restricted (only backend can access)

### **Q: What happens if the database crashes?**
**A:**
- PostgreSQL has built-in backup mechanisms
- Database transactions ensure data consistency
- Regular backups should be configured (not in code, but deployment)
- Connection pooling handles temporary disconnections

### **Q: How do you handle many users at once?**
**A:**
- Database indexes speed up queries
- Connection pooling reuses connections
- JWT tokens (stateless) - no server-side session storage
- Pagination limits data returned per request
- Caching can be added for frequently accessed data

### **Q: Can someone hack into the system?**
**A:**
- Multiple layers of security (authentication, authorization, validation)
- SQL injection prevented by Django ORM
- XSS attacks prevented by input sanitization
- CORS prevents unauthorized websites
- JWT signature prevents token tampering
- Regular security updates to dependencies

### **Q: How is data backed up?**
**A:**
- Database backups should be configured at hosting level (Render/Railway)
- PostgreSQL supports automatic backups
- Database transactions ensure data integrity
- Timestamps track all changes (audit trail)

---

## 📚 Additional Resources

- **Django Documentation**: https://docs.djangoproject.com/
- **Django REST Framework**: https://www.django-rest-framework.org/
- **JWT Introduction**: https://jwt.io/introduction
- **PostgreSQL Security**: https://www.postgresql.org/docs/current/security.html

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Prepared for**: Technical Panel Presentation

