# AnimalGuardian - Simple Data Flow Explanation

## 🎯 Quick Overview

Think of AnimalGuardian like a **restaurant**:
- **Frontend (Mobile/Web App)** = Customer placing order
- **Backend API** = Waiter taking order and kitchen
- **Database** = Storage room where ingredients are kept

---

## 📱 Example: Farmer Adds a Cow

### Step-by-Step Flow:

```
┌─────────────┐
│   FARMER    │
│  (Mobile)   │
└──────┬──────┘
       │ 1. Fills form: "Bella", Cow, Female, 350kg
       │
       ▼
┌─────────────────────────────────────┐
│  2. HTTP POST Request                │
│  URL: /api/livestock/                │
│  Headers: Authorization: Bearer TOKEN │
│  Body: {name: "Bella", type: 1...}  │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  3. BACKEND RECEIVES REQUEST         │
│  - Checks JWT token (is user logged in?)│
│  - Verifies permission (can farmer add?)│
│  - Validates data (is data correct?) │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  4. DATABASE OPERATION               │
│  INSERT INTO livestock VALUES (...)  │
│  Database assigns ID: 456            │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  5. RESPONSE SENT BACK               │
│  Status: 201 Created                 │
│  Body: {id: 456, name: "Bella"...}   │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────┐
│   FARMER    │
│  (Mobile)   │
│  Sees:      │
│  "Bella added successfully!"         │
└─────────────┘
```

---

## 🔐 Security Layers

### Layer 1: Password Protection
```
User Password: "MyPassword123"
         ↓
   [PBKDF2 Hash]
         ↓
Stored: "pbkdf2_sha256$260000$salt$hash..."
```
**Result**: Even if database is hacked, password cannot be recovered

### Layer 2: JWT Token
```
Login → Backend generates token → Frontend stores token
         ↓
Every request includes: Authorization: Bearer <token>
         ↓
Backend verifies token → Allows/Denies request
```
**Result**: User doesn't need to login every time, but token expires after 24 hours

### Layer 3: HTTPS Encryption
```
All data sent over internet is encrypted
```
**Result**: Even if intercepted, data is unreadable

### Layer 4: Permission Checks
```
Request → Check user type → Check permission → Allow/Deny
```
**Result**: Farmers can't access admin features, vets can't delete users

---

## 💾 Database Storage

### How Data is Organized:

**Users Table** (like a phone book):
```
ID | Phone      | Name      | Type    | Password (hashed)
1  | 0781234567 | John Doe  | farmer  | pbkdf2_sha256$...
2  | 0799876543 | Dr. Smith | vet     | pbkdf2_sha256$...
```

**Livestock Table** (like a farm registry):
```
ID | Owner | Name  | Type | Weight | Status
1  | 1     | Bella | Cow  | 350kg  | healthy
2  | 1     | Max   | Cow  | 450kg  | healthy
```

**Relationships**:
- Owner ID "1" links to User ID "1" (John Doe owns these animals)
- This prevents orphaned records (can't have livestock without owner)

---

## 🔄 Complete User Journey

### Registration → Login → Add Livestock → Report Case

```
1. REGISTRATION
   User enters: phone, password, name
   ↓
   Backend: Hashes password, saves to database
   ↓
   Response: "Account created!"

2. LOGIN
   User enters: phone, password
   ↓
   Backend: Checks password hash, generates JWT token
   ↓
   Response: {token, user_data}

3. ADD LIVESTOCK
   User enters: cow details
   ↓
   Backend: Validates, saves to database
   ↓
   Response: {livestock_id, details}

4. REPORT CASE
   User selects: sick cow, enters symptoms
   ↓
   Backend: Creates case, notifies vets
   ↓
   Response: {case_id, status}
```

---

## 🛡️ Security Checklist

✅ **Passwords**: Hashed with PBKDF2 (cannot be reversed)  
✅ **Tokens**: JWT with expiration (auto-logout after 24h)  
✅ **HTTPS**: All communication encrypted  
✅ **Validation**: All inputs checked before saving  
✅ **Permissions**: Users can only access their data  
✅ **Approval**: Local vets must be approved before login  
✅ **CORS**: Only allowed websites can access API  
✅ **SQL Injection**: Prevented by Django ORM  

---

## 📊 Database Relationships

```
USER (1) ────< (Many) LIVESTOCK
  │
  │ (One-to-One)
  │
  ├─── VETERINARIAN_PROFILE (if vet)
  └─── FARMER_PROFILE (if farmer)

LIVESTOCK (1) ────< (Many) VACCINATION_RECORDS
LIVESTOCK (1) ────< (Many) HEALTH_RECORDS
LIVESTOCK (1) ────< (Many) CASE_REPORTS
```

**Meaning**:
- One user can have many livestock
- One livestock can have many vaccination records
- One user has one profile (vet or farmer, not both)

---

## 🎓 Key Concepts Explained Simply

### **JWT Token** = Temporary ID Card
- Proves you're logged in
- Expires after 24 hours
- Can't be faked (has signature)

### **Password Hash** = One-Way Lock
- Password → Hash (easy)
- Hash → Password (impossible)
- Like turning milk into cheese (can't reverse)

### **Database Index** = Book Index
- Without index: Search entire book (slow)
- With index: Jump to page number (fast)

### **Foreign Key** = Reference Link
- Livestock.owner_id → Users.id
- Ensures livestock always has valid owner
- Prevents orphaned records

### **API Endpoint** = Mailbox Address
- `/api/livestock/` = "Send livestock requests here"
- `/api/cases/` = "Send case reports here"
- Each has specific purpose

---

## 🚨 What Happens When Things Go Wrong?

### **Invalid Data**
```
User submits: weight = -50kg
↓
Backend: "Error: Weight must be positive"
↓
Frontend: Shows error message
↓
User: Fixes and resubmits
```

### **Expired Token**
```
User makes request
↓
Backend: "Token expired"
↓
Frontend: Uses refresh_token to get new token
↓
Frontend: Retries request automatically
↓
User: Doesn't notice (seamless)
```

### **No Internet**
```
User tries to add livestock
↓
Request fails
↓
Frontend: "Connection error, please try again"
↓
User: Retries when internet restored
```

---

## 💡 For Panel: Key Points

1. **Security**: Multiple layers protect user data
2. **Speed**: Database indexes make queries fast
3. **Reliability**: Transactions ensure data consistency
4. **Scalability**: Architecture handles growth
5. **User Experience**: Fast, secure, intuitive

---

**Remember**: 
- Frontend = What users see
- Backend = Brain that processes
- Database = Storage room
- Security = Multiple locks on the door

