# Password Hashing - What Does It?

## 🔐 Quick Answer

**Django Framework** automatically hashes passwords using **PBKDF2 with SHA-256** algorithm.

You don't write hashing code yourself - Django does it for you when you call:
- `user.set_password(password)`
- `User.objects.create_user(password=password, ...)`

---

## 📍 Where Password Hashing Happens in Your Code

### **1. User Registration** (`backend/accounts/serializers.py`)

```python
def create(self, validated_data):
    password = validated_data.pop('password')
    
    # Django automatically hashes the password here:
    user = User.objects.create_user(password=password, **validated_data)
    # ↑ This method hashes the password before saving
```

**What happens:**
- `create_user()` is a Django method (from `AbstractUser`)
- It automatically calls the password hasher
- Password is hashed before being saved to database

### **2. Password Change** (`backend/accounts/views.py`)

```python
# User changes their password
user.set_password(new_password)  # ← Django hashes it here
user.save()
```

**What happens:**
- `set_password()` is a Django method (from `AbstractUser`)
- It automatically hashes the password
- You just pass the plain text password, Django does the rest

### **3. Creating Admin Users** (`backend/accounts/migrations/0002_default_admin.py`)

```python
from django.contrib.auth.hashers import make_password

password = make_password('admin123')  # ← Explicitly hash password
# Returns: "pbkdf2_sha256$260000$salt$hash..."
```

**What happens:**
- `make_password()` is Django's hashing function
- Used when you need the hash directly (like in migrations)
- Returns the hashed string

---

## 🔧 How Django's Password Hashing Works

### **The Default Hasher: PBKDF2**

Django uses **PBKDF2 (Password-Based Key Derivation Function 2)** with **SHA-256** by default.

**PBKDF2 Process:**
```
1. User Password: "MyPassword123"
         ↓
2. Django generates random SALT (unique per password)
   Example: "abc123xyz"
         ↓
3. Django combines: password + salt
   "MyPassword123" + "abc123xyz"
         ↓
4. Django hashes it with SHA-256 (260,000 times!)
   SHA-256(SHA-256(SHA-256(...260,000 times...)))
         ↓
5. Django stores in database:
   "pbkdf2_sha256$260000$abc123xyz$def456uvw789..."
   
   Format: algorithm$iterations$salt$hash
```

### **Why 260,000 Iterations?**

- Makes it slow for attackers (they have to try millions of passwords)
- Still fast for legitimate users (one login attempt)
- Industry standard for security

---

## 📝 Code Examples from Your Project

### **Example 1: User Registration**

**File:** `backend/accounts/serializers.py` (line 242)

```python
# User submits password: "MyPassword123"
password = validated_data.pop('password')

# Django automatically hashes it:
user = User.objects.create_user(password=password, **validated_data)

# What Django does internally:
# 1. Takes "MyPassword123"
# 2. Generates salt: "xyz789"
# 3. Hashes 260,000 times
# 4. Stores: "pbkdf2_sha256$260000$xyz789$abc123..."
# 5. Saves to database
```

### **Example 2: Changing Password**

**File:** `backend/accounts/views.py` (line 588)

```python
# User wants to change password to "NewPassword456"
user.set_password(new_password)  # ← Django hashes here
user.save()

# What Django does:
# 1. Takes "NewPassword456"
# 2. Generates NEW salt (different from old one)
# 3. Hashes 260,000 times
# 4. Updates password field in database
```

### **Example 3: Creating Admin in Migration**

**File:** `backend/accounts/migrations/0002_default_admin.py` (line 15)

```python
from django.contrib.auth.hashers import make_password

# Explicitly hash password for admin user
'password': make_password('admin123')

# Returns: "pbkdf2_sha256$260000$salt$hash..."
# This is stored directly in database
```

---

## 🎯 Key Points

### **1. You Never See the Hash**
- You always work with plain text passwords in your code
- Django handles all the hashing automatically
- The hash is only stored in the database

### **2. Each Password Gets Unique Salt**
- Salt = random string added to password
- Even if two users have same password, hashes are different
- Example:
  - User 1 password "password123" → hash: `pbkdf2_sha256$...$salt1$hash1`
  - User 2 password "password123" → hash: `pbkdf2_sha256$...$salt2$hash2`
  - Different salts = different hashes (more secure)

### **3. Hashing is One-Way**
- Password → Hash: Easy (Django does this)
- Hash → Password: Impossible (mathematically)
- Even Django developers can't reverse it

### **4. Password Verification**

When user logs in:

```python
# User enters: phone_number + "MyPassword123"
user = authenticate(username=phone_number, password="MyPassword123")

# What Django does:
# 1. Finds user by phone_number
# 2. Gets stored hash: "pbkdf2_sha256$260000$salt$hash"
# 3. Takes entered password: "MyPassword123"
# 4. Adds same salt from stored hash
# 5. Hashes 260,000 times
# 6. Compares new hash with stored hash
# 7. If match → login successful
# 8. If no match → login failed
```

---

## 🔍 Where is the Hashing Code?

**Django's Built-in Code** (you don't see this, it's in Django itself):

**Location:** Django's `django.contrib.auth.hashers` module

**Key Functions:**
- `PBKDF2PasswordHasher` - The actual hasher class
- `make_password()` - Function to hash passwords
- `check_password()` - Function to verify passwords

**Your Code Just Calls It:**
```python
# Your code (simple):
user.set_password("MyPassword123")

# Django's code (complex, but you don't write it):
class PBKDF2PasswordHasher:
    def encode(self, password, salt, iterations=None):
        # Generates salt
        # Hashes password + salt 260,000 times
        # Returns: "pbkdf2_sha256$260000$salt$hash"
```

---

## 🛡️ Security Features

### **1. Salt Prevents Rainbow Table Attacks**
- Rainbow table = pre-computed password hashes
- With unique salt per password, rainbow tables are useless
- Attacker would need separate rainbow table for each salt

### **2. High Iteration Count**
- 260,000 iterations = slow for attackers
- If attacker tries 1,000 passwords/second:
  - With 260,000 iterations: 260 seconds per password
  - 1,000 passwords = 260,000 seconds = 72 hours
- Legitimate user: 1 login = 0.1 seconds (acceptable)

### **3. Algorithm is Industry Standard**
- PBKDF2 is recommended by security experts
- Used by banks, governments, major tech companies
- Proven secure over many years

---

## 📊 Visual Flow

```
┌─────────────────────────────────────────┐
│  USER ENTERS PASSWORD                    │
│  "MyPassword123"                         │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  YOUR CODE                               │
│  user.set_password("MyPassword123")     │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  DJANGO'S HASHER (Automatic)            │
│  1. Generate salt: "xyz789"              │
│  2. Combine: "MyPassword123" + "xyz789"  │
│  3. Hash with SHA-256 (260,000 times)   │
│  4. Result: "pbkdf2_sha256$..."         │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  DATABASE                                │
│  password = "pbkdf2_sha256$260000$..."  │
│  (Original password is gone forever)     │
└─────────────────────────────────────────┘
```

---

## ❓ Common Questions

### **Q: Can I see the original password?**
**A:** No! Once hashed, it's impossible to get the original password back. That's the whole point of hashing.

### **Q: What if I need to reset a password?**
**A:** You don't recover the old password. You generate a new one:
```python
user.set_password("NewPassword456")  # Hash new password
user.save()  # Old hash is replaced
```

### **Q: Can I change the hashing algorithm?**
**A:** Yes, but you shouldn't need to. PBKDF2 is secure. If you want to change it, you'd modify Django's `PASSWORD_HASHERS` setting.

### **Q: How does Django know which hasher to use?**
**A:** The hash string itself contains the algorithm:
```
"pbkdf2_sha256$260000$salt$hash"
  ↑           ↑       ↑    ↑
  algorithm   iterations salt hash
```
Django reads the algorithm from the stored hash.

---

## 🎓 Summary

**What hashes passwords?**
- **Django Framework** (specifically `django.contrib.auth.hashers`)

**How?**
- Uses **PBKDF2 with SHA-256**
- 260,000 iterations
- Unique salt per password

**When?**
- Automatically when you call:
  - `user.set_password(password)`
  - `User.objects.create_user(password=password)`
  - `make_password(password)`

**Where in your code?**
- `backend/accounts/serializers.py` - User registration
- `backend/accounts/views.py` - Password changes
- `backend/accounts/migrations/` - Creating default users

**You don't need to:**
- Write hashing code
- Understand the math
- Worry about security (Django handles it)

**You just need to:**
- Call `set_password()` or `create_user()`
- Django does the rest automatically!

---

**Remember:** Django is like a security guard that automatically locks your passwords. You just hand them the password, and they lock it up securely. You never need to know how the lock works - it just works!

