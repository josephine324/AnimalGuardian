# AnimalGuardian System Architecture Flow
## Complete Explanation for Panel Presentation

---

## 🎯 Overview

This document explains the complete data flow and system architecture of AnimalGuardian based on the system architecture diagram. This is designed for explaining to a technical panel how all components work together.

---

## 🏗️ System Components

### **1. User Interfaces (Entry Points)**

#### **A. Smartphone App (Mobile Application)**
- **Who uses it:** Farmers with smartphones
- **What it does:** 
  - Farmers can register livestock
  - Report disease cases
  - Upload photos/videos of animals
  - View notifications and advice
  - Track livestock health records

#### **B. USSD Interface (Feature Phone)**
- **Who uses it:** Farmers with basic phones (no smartphone)
- **What it does:**
  - Access system via dial codes (like *123#)
  - Report cases via text
  - Receive notifications via SMS
  - Limited functionality (no photos, but can report cases)

---

### **2. Backend Server (The Brain)**

**Location:** Django REST API Server (hosted on Render/Railway)

**Functions:**
1. **Data Storage Management**
   - Receives data from mobile app and USSD
   - Validates all incoming data
   - Processes and formats data before saving

2. **Authentication**
   - Verifies user identity (phone number + password)
   - Generates JWT tokens
   - Manages user sessions
   - Controls access permissions

3. **Managing Notifications**
   - Creates notifications when cases are reported
   - Sends alerts to veterinarians
   - Sends advice/updates to farmers
   - Manages SMS notifications via Africa's Talking API

4. **Comprehensive Case Management**
   - Processes case reports from farmers
   - Routes cases to appropriate veterinarians
   - Tracks case status (open, in-progress, resolved)
   - Links cases to livestock records

---

### **3. Database (Central Storage)**

**Type:** PostgreSQL (Production) or SQLite (Development)

**Stores:**
- User accounts (farmers, vets, admins)
- Livestock records (cows, goats, etc.)
- Case reports (disease cases)
- Vaccination records
- Health records
- Notification history
- Farmer profiles

**Relationships:**
- Links farmers to their livestock
- Links cases to livestock and veterinarians
- Maintains data integrity through foreign keys

---

### **4. Farmer Profiles (Extended User Data)**

**What it stores:**
- Farm information (farm name, size, location)
- Livestock inventory (total count, types)
- Farming experience (years of farming)
- Technology access (smartphone, basic phone, internet)
- Communication preferences (SMS, USSD, app, call)
- Historical records and notification advice

**Purpose:**
- Helps system understand farmer's context
- Enables personalized notifications
- Tracks farmer engagement

---

### **5. Notification Module**

**Functions:**
- Receives notification requests from:
  - Backend Server (when cases are created)
  - USSD Interface (when farmers report via USSD)
  - Comprehensive Case Management (case updates)

**What it does:**
- Formats messages for different channels (SMS, in-app, USSD)
- Sends notifications via Africa's Talking API
- Tracks delivery status
- Stores notification history in Database

**Output:**
- Sends "Case information and advice to farmers"
- Notifies veterinarians about new cases
- Sends reminders (vaccination due, health checks)

---

### **6. Case Information / Advice to Farmers**

**What it is:**
- Output system that delivers information back to farmers
- Receives data from Database (case updates, vet advice)

**Delivers:**
- Disease diagnosis and treatment advice
- Vaccination reminders
- Health check recommendations
- General livestock management tips
- Case resolution updates

**Channels:**
- SMS (for basic phone users)
- In-app notifications (for smartphone users)
- USSD responses (for feature phone users)

---

### **7. Vet Portal (Veterinarian Dashboard)**

**Who uses it:** Veterinarians (Sector Vets, Local Vets)

**What it does:**
- Receives data from Backend Server
- Displays dashboard with:
  - Pending cases in their area
  - Assigned cases
  - Farmer information
  - Livestock health records
  - Case statistics

**Capabilities:**
- View case details and symptoms
- Update case status
- Provide diagnosis and treatment advice
- Approve/reject local vet registrations
- Access database to update records

---

### **8. Vet Portal Communication**

**What it is:**
- Communication interface within Vet Portal
- Allows vets to communicate with:
  - Farmers (about their cases)
  - Other veterinarians (consultation)
  - System administrators

**Functions:**
- Send advice to farmers
- Request additional information
- Escalate complex cases
- Coordinate with other vets

**Output:**
- Feeds into Comprehensive Case Management
- Updates case records
- Triggers notifications to farmers

---

### **9. Comprehensive Case Management**

**What it is:**
- Central system for managing all disease cases
- Coordinates between farmers, vets, and database

**Functions:**
- Receives case reports from:
  - USSD Interface (feature phone reports)
  - Backend Server (mobile app reports)
  - Vet Portal Communication (vet updates)

- Processes cases:
  - Assigns cases to appropriate veterinarians
  - Tracks case lifecycle (reported → assigned → in-progress → resolved)
  - Links cases to livestock records
  - Stores case history

- Outputs to:
  - Database (saves case records)
  - Notification Module (triggers notifications)

---

## 🔄 Complete Data Flow Scenarios

### **Scenario 1: Farmer Reports Disease Case via Mobile App**

```
1. FARMER (Smartphone App)
   ↓
   Fills form: Selects cow "Bella", enters symptoms "Fever, loss of appetite"
   ↓
   Clicks "Report Case"
   ↓

2. BACKEND SERVER
   ↓
   Receives: POST /api/cases/
   ↓
   Authenticates: Checks JWT token (is farmer logged in?)
   ↓
   Validates: Checks data is correct (cow exists, symptoms provided)
   ↓
   Processes: Creates CaseReport object
   ↓
   Routes: Determines which vet should handle (based on location)
   ↓

3. DATABASE
   ↓
   Saves: New case record
   - case_id: 123
   - reporter_id: 1 (farmer)
   - livestock_id: 5 (Bella the cow)
   - symptoms: "Fever, loss of appetite"
   - status: "open"
   - assigned_vet_id: 2
   ↓

4. NOTIFICATION MODULE
   ↓
   Receives: Case created event
   ↓
   Formats: "New case reported: Cow 'Bella' showing fever symptoms"
   ↓
   Sends: SMS to assigned veterinarian
   ↓

5. VET PORTAL
   ↓
   Veterinarian logs in
   ↓
   Sees: New case notification
   ↓
   Views: Case details from Database
   ↓
   Responds: Provides diagnosis and treatment advice
   ↓

6. COMPREHENSIVE CASE MANAGEMENT
   ↓
   Receives: Vet's response via Vet Portal Communication
   ↓
   Updates: Case status to "in_progress"
   ↓
   Saves: Diagnosis and treatment to Database
   ↓

7. NOTIFICATION MODULE
   ↓
   Receives: Case update event
   ↓
   Formats: "Your cow 'Bella' has been diagnosed. Treatment: [advice]"
   ↓
   Sends: SMS/In-app notification to Farmer
   ↓

8. CASE INFORMATION / ADVICE TO FARMERS
   ↓
   Delivers: Treatment advice to Farmer's smartphone
   ↓
   Farmer sees: Diagnosis and treatment instructions
```

---

### **Scenario 2: Farmer Reports Case via USSD (Feature Phone)**

```
1. FARMER (Feature Phone)
   ↓
   Dials: *123# (USSD code)
   ↓
   Selects: "Report Case"
   ↓
   Enters: Livestock tag number, symptoms (via text)
   ↓

2. USSD INTERFACE
   ↓
   Receives: USSD request
   ↓
   Formats: Converts USSD input to API request
   ↓
   Sends: POST /api/cases/ to Backend Server
   ↓

3. BACKEND SERVER
   ↓
   Authenticates: Verifies farmer by phone number
   ↓
   Validates: Checks livestock tag exists
   ↓
   Processes: Creates case
   ↓

4. COMPREHENSIVE CASE MANAGEMENT
   ↓
   Receives: Case from Backend Server
   ↓
   Processes: Assigns to veterinarian
   ↓
   Saves: To Database
   ↓

5. NOTIFICATION MODULE
   ↓
   Receives: Case created event
   ↓
   Sends: SMS to veterinarian
   ↓
   Sends: Confirmation SMS to farmer: "Case #123 received"
   ↓

6. VET PORTAL
   ↓
   Vet reviews case
   ↓
   Provides advice via Vet Portal Communication
   ↓

7. CASE INFORMATION / ADVICE TO FARMERS
   ↓
   Sends: SMS to farmer's feature phone
   ↓
   "Case #123: Your livestock needs [treatment]. Contact vet: [number]"
```

---

### **Scenario 3: Veterinarian Reviews and Updates Case**

```
1. VET PORTAL (Veterinarian Dashboard)
   ↓
   Veterinarian logs in
   ↓
   Sees: List of assigned cases
   ↓
   Clicks: Case #123
   ↓

2. DATABASE
   ↓
   Vet Portal queries: GET /api/cases/123/
   ↓
   Returns: Case details, livestock info, farmer info, symptoms
   ↓

3. VET PORTAL
   ↓
   Veterinarian reviews:
   - Symptoms: "Fever, loss of appetite"
   - Livestock: Cow "Bella", 4 years old
   - History: Last vaccination 6 months ago
   ↓
   Provides: Diagnosis and treatment
   ↓

4. VET PORTAL COMMUNICATION
   ↓
   Veterinarian enters:
   - Diagnosis: "Bacterial infection"
   - Treatment: "Antibiotic injection, rest for 3 days"
   - Follow-up: "Check in 2 days"
   ↓
   Submits: Updates case
   ↓

5. COMPREHENSIVE CASE MANAGEMENT
   ↓
   Receives: Vet's update
   ↓
   Processes: Updates case status to "in_progress"
   ↓
   Saves: Diagnosis and treatment to Database
   ↓

6. NOTIFICATION MODULE
   ↓
   Receives: Case update event
   ↓
   Formats: Message with diagnosis and treatment
   ↓
   Sends: Notification to farmer
   ↓

7. CASE INFORMATION / ADVICE TO FARMERS
   ↓
   Delivers: Treatment advice
   ↓
   Farmer receives: Diagnosis and treatment instructions
```

---

### **Scenario 4: Farmer Registers New Livestock**

```
1. FARMER (Smartphone App)
   ↓
   Clicks: "Add Livestock"
   ↓
   Fills form:
   - Name: "Bella"
   - Type: Cow
   - Breed: Holstein
   - Gender: Female
   - Birth Date: 2020-05-15
   - Weight: 350kg
   ↓
   Clicks: "Save"
   ↓

2. BACKEND SERVER
   ↓
   Receives: POST /api/livestock/
   ↓
   Authenticates: Checks JWT token
   ↓
   Validates: Checks data (type exists, breed valid, dates correct)
   ↓
   Processes: Creates Livestock object
   ↓

3. DATABASE
   ↓
   Saves: New livestock record
   - id: 456
   - owner_id: 1 (farmer)
   - livestock_type_id: 1 (Cow)
   - breed_id: 2 (Holstein)
   - name: "Bella"
   - gender: "F"
   - birth_date: 2020-05-15
   - weight_kg: 350
   ↓

4. FARMER PROFILES
   ↓
   Updates: total_livestock_count (increments by 1)
   ↓
   Saves: Updated profile to Database
   ↓

5. BACKEND SERVER
   ↓
   Returns: Success response with new livestock data
   ↓

6. FARMER (Smartphone App)
   ↓
   Receives: Success message
   ↓
   Sees: "Bella" added to livestock list
```

---

## 🔗 Component Interactions

### **Data Flow Patterns**

#### **1. Farmer → System (Input Flow)**
```
Mobile App/USSD → Backend Server → Database
                              ↓
                    Comprehensive Case Management
                              ↓
                         Notification Module
```

#### **2. System → Farmer (Output Flow)**
```
Database → Notification Module → Case Information/Advice → Farmer
```

#### **3. Veterinarian → System (Input Flow)**
```
Vet Portal → Vet Portal Communication → Comprehensive Case Management → Database
```

#### **4. System → Veterinarian (Output Flow)**
```
Database → Backend Server → Vet Portal
```

#### **5. Cross-Component Communication**
```
Backend Server ↔ Database ↔ Farmer Profiles
Vet Portal ↔ Database
Comprehensive Case Management ↔ Database ↔ Notification Module
```

---

## 🛡️ Security in the Flow

### **Authentication Points:**
1. **Mobile App → Backend Server**
   - JWT token in Authorization header
   - Token verified before processing

2. **USSD → Backend Server**
   - Phone number verification
   - PIN or OTP validation

3. **Vet Portal → Backend Server**
   - JWT token authentication
   - Role-based access (only vets can access)

### **Data Validation:**
- All inputs validated at Backend Server
- Database constraints prevent invalid data
- Foreign keys ensure relationships are valid

### **Data Encryption:**
- HTTPS for all API communication
- Encrypted database connections
- Secure password storage (hashed)

---

## 📊 System Architecture Diagram Explanation

### **Key Flows Shown in Diagram:**

#### **Flow 1: Farmer Input (Mobile App)**
```
Smartphone App → Backend Server → Database
                              ↓
                    Farmer Profiles
```

#### **Flow 2: Farmer Input (USSD)**
```
Feature Phone → USSD Interface → Comprehensive Case Management → Database
                              ↓
                    Notification Module
```

#### **Flow 3: Veterinarian Access**
```
Backend Server → Vet Portal → Database
                              ↓
                    Vet Portal Communication → Comprehensive Case Management
```

#### **Flow 4: Notifications**
```
Database → Case Information/Advice → Farmers
Notification Module → Database
```

---

## 🎯 Key Points for Panel Presentation

### **1. Multiple Access Points**
- **Smartphone App**: Full functionality, media uploads
- **USSD**: Basic functionality for feature phones
- **Vet Portal**: Web dashboard for veterinarians

### **2. Centralized Processing**
- **Backend Server**: Single point for all business logic
- **Database**: Single source of truth
- **Comprehensive Case Management**: Centralized case coordination

### **3. Bidirectional Communication**
- Farmers can report cases
- System can send advice/notifications back
- Veterinarians can provide input
- System routes information appropriately

### **4. Scalable Architecture**
- Each component has specific responsibility
- Components can be scaled independently
- Database handles all storage
- Notification system handles all communications

### **5. Security Throughout**
- Authentication at every entry point
- Data validation at Backend Server
- Encrypted communication
- Secure database storage

---

## 💡 Real-World Example: Complete Case Lifecycle

### **Day 1: Case Reported**
```
9:00 AM - Farmer notices cow "Bella" is sick
9:05 AM - Farmer opens mobile app, reports case
9:06 AM - Backend Server receives, validates, saves to Database
9:07 AM - Comprehensive Case Management assigns to nearest vet
9:08 AM - Notification Module sends SMS to veterinarian
9:10 AM - Veterinarian receives notification on phone
```

### **Day 1: Veterinarian Responds**
```
10:00 AM - Veterinarian logs into Vet Portal
10:05 AM - Reviews case details from Database
10:10 AM - Provides diagnosis via Vet Portal Communication
10:11 AM - Comprehensive Case Management updates case status
10:12 AM - Database saves diagnosis and treatment
10:13 AM - Notification Module sends SMS to farmer
10:15 AM - Farmer receives treatment advice on phone
```

### **Day 3: Follow-up**
```
9:00 AM - System checks Database for cases needing follow-up
9:01 AM - Finds Case #123 (Bella) - 2 days old
9:02 AM - Notification Module sends follow-up SMS to farmer
9:05 AM - Farmer receives: "How is Bella? Reply with status"
9:10 AM - Farmer replies via USSD: "Bella is better"
9:11 AM - USSD Interface updates case status
9:12 AM - Database records follow-up
```

---

## 🔍 Technical Details for Each Component

### **Backend Server (Django REST API)**
- **Technology**: Python, Django, Django REST Framework
- **Functions**: Authentication, validation, business logic
- **Endpoints**: `/api/cases/`, `/api/livestock/`, `/api/auth/`, etc.
- **Security**: JWT tokens, input validation, HTTPS

### **Database (PostgreSQL)**
- **Technology**: PostgreSQL (production), SQLite (development)
- **Functions**: Data storage, relationships, queries
- **Tables**: users, livestock, case_reports, notifications, etc.
- **Security**: Encrypted connections, hashed passwords, foreign keys

### **Notification Module**
- **Technology**: Django + Africa's Talking API
- **Functions**: SMS sending, notification formatting
- **Channels**: SMS, in-app, USSD responses
- **Security**: API key authentication

### **Vet Portal**
- **Technology**: React (web dashboard)
- **Functions**: Case management, vet dashboard, communication
- **Access**: Web browser, requires vet authentication
- **Security**: JWT tokens, role-based access

---

## 📝 Summary for Panel

### **System Architecture Highlights:**

1. **Three Entry Points:**
   - Mobile App (smartphones)
   - USSD (feature phones)
   - Vet Portal (web dashboard)

2. **Central Processing:**
   - Backend Server handles all logic
   - Database stores all data
   - Comprehensive Case Management coordinates cases

3. **Communication Flow:**
   - Farmers → System (report cases)
   - System → Veterinarians (notify about cases)
   - Veterinarians → System (provide advice)
   - System → Farmers (deliver advice)

4. **Data Storage:**
   - Database: All system data
   - Farmer Profiles: Extended farmer information
   - All linked through relationships

5. **Security:**
   - Authentication at every entry point
   - Data validation throughout
   - Encrypted communication
   - Secure storage

---

**This architecture ensures:**
- ✅ Farmers can access system via any device
- ✅ Veterinarians can efficiently manage cases
- ✅ All data is centralized and secure
- ✅ Notifications reach the right people
- ✅ System is scalable and maintainable

---

**Document Version**: 1.0  
**Prepared for**: Panel Presentation  
**Based on**: System Architecture Diagram

