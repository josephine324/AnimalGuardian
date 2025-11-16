# 👥 AnimalGuardian User Guide - User Types & Platform Access

## 📊 User Types Overview

AnimalGuardian supports **3 main user types** with different access levels and platform assignments:

---

## 1. 👨‍🌾 **FARMERS**

### **Who They Are:**
- Smallholder farmers in Nyagatare District, Rwanda
- Primary beneficiaries of the system
- May or may not have smartphones

### **Platform Access:**
- **Farmers WITH Smartphones** → 📱 **Mobile App (Flutter)**
- **Farmers WITHOUT Smartphones** → 📞 **USSD Service**

### **Functionalities:**

#### **Via Mobile App (Smartphone Users):**
✅ **Case Reporting**
- Report animal health issues with photos/videos
- Describe symptoms in detail
- Track case status in real-time

✅ **Livestock Management**
- Add and manage livestock inventory
- Track individual animal health records
- View vaccination schedules
- Monitor livestock status

✅ **Veterinary Consultation**
- Chat with assigned veterinarians
- Receive expert advice
- Get treatment recommendations

✅ **Health Records**
- View vaccination history
- Track treatment records
- Access health certificates

✅ **Weather Integration**
- Receive weather-based health alerts
- Get preventive care recommendations

✅ **Community Features**
- Connect with other farmers
- Share experiences and tips
- Access community forums

✅ **Market Information**
- View livestock market prices
- Access marketplace features

✅ **Notifications**
- Receive SMS/push notifications
- Get vaccination reminders
- Case status updates

#### **Via USSD Service (Basic Phone Users):**
✅ **Report Animal Disease**
- Dial USSD code to report issues
- Select animal type
- Describe symptoms via menu

✅ **Get Veterinary Advice**
- Access general health tips
- Emergency first aid information
- Vaccination information
- Disease prevention tips

✅ **Check Vaccination Schedule**
- View upcoming vaccinations
- Get reminders via SMS

✅ **Weather Alerts**
- Receive weather warnings
- Get preventive care alerts

✅ **Contact Support**
- Call veterinarian hotline
- Send SMS for support
- Report technical issues

✅ **SMS Commands** (via SMS):
- `STATUS` - Check livestock status
- `VACCINE` - Get vaccination info
- `WEATHER` - Get weather alerts
- `REPORT <symptoms>` - Report disease
- `ADVICE` - Get health advice
- `CONTACT` - Get support info
- `HELP` - View all commands

---

## 2. 🩺 **LOCAL VETERINARIANS**

### **Who They Are:**
- Licensed veterinarians working at local level
- Provide direct veterinary services to farmers
- Field-based professionals

### **Platform Access:**
📱 **Mobile App (Flutter)** - Primary platform

### **Functionalities:**

✅ **Case Management**
- Receive case assignments from sector vets
- View assigned cases in real-time
- Update case status and progress
- Add consultation notes

✅ **Farmer Consultation**
- Chat with farmers via in-app messaging
- Provide expert veterinary advice
- Recommend treatments
- Schedule follow-ups

✅ **Livestock Health Records**
- View farmer's livestock records
- Access vaccination history
- Review treatment history
- Update health records

✅ **Case Reporting**
- Submit case reports to sector vets
- Upload photos/videos of cases
- Document diagnosis and treatment
- Request assistance when needed

✅ **Notifications**
- Receive new case assignments
- Get urgent case alerts
- Vaccination reminders for assigned farmers
- System notifications

✅ **Profile Management**
- Update availability status
- Manage working hours
- Update clinic information
- View performance metrics

### **Limitations:**
❌ **Cannot approve new user registrations** (only Sector Vets can)
❌ **Cannot access web dashboard** (desktop management)
❌ **Cannot view system-wide analytics**

---

## 3. 🏥 **SECTOR VETERINARIANS**

### **Who They Are:**
- Senior veterinarians at sector/district level
- Administrative and supervisory role
- Coordinate multiple local vets

### **Platform Access:**
💻 **Web Dashboard (React.js)** - Primary platform

### **Functionalities:**

✅ **User Management & Approval**
- **Approve/Reject new user registrations**
  - Review farmer registrations
  - Approve local vet registrations
  - Add approval notes
  - Manage user access

✅ **Case Management**
- View all cases in the system
- Assign cases to local veterinarians
- Monitor case progress
- Escalate critical cases
- Resolve cases

✅ **Dashboard & Analytics**
- View comprehensive statistics
  - Total cases (pending, resolved, active)
  - Total farmers, sector vets, local vets
  - Livestock statistics
  - Vaccination schedules
  - Average response times
  - Resolution rates

✅ **Veterinarian Management**
- View all veterinarians (sector & local)
- Assign cases to local vets
- Monitor vet availability
- Track vet performance
- Manage vet assignments

✅ **Farmer Management**
- View all registered farmers
- Access farmer profiles
- View farmer livestock records
- Monitor farmer activity

✅ **Livestock Management**
- View all livestock in the system
- Track livestock health status
- Monitor vaccination schedules
- Generate health reports

✅ **Notifications**
- System-wide notifications
- Case assignment alerts
- User approval requests
- Critical case alerts

✅ **Reports & Analytics**
- Generate system reports
- Disease trend analysis
- Performance metrics
- Export data

### **Special Permissions:**
✅ **Can approve users** (Farmers, Local Vets, Field Officers)
✅ **Can reject users** with notes
✅ **Can view pending approvals**
✅ **Full system access**

---

## 4. 👨‍💼 **ADMINS** (System Administrators)

### **Who They Are:**
- System administrators
- Full system control
- Technical management

### **Platform Access:**
💻 **Web Dashboard (React.js)** + **Django Admin Panel**

### **Functionalities:**
- All Sector Vet functionalities PLUS:
- System configuration
- Database management
- User role management
- System monitoring
- Technical support

---

## 5. 👨‍💻 **FIELD OFFICERS**

### **Who They Are:**
- Agricultural extension officers
- Support staff
- Field coordinators

### **Platform Access:**
📱 **Mobile App (Flutter)** (if needed)

### **Functionalities:**
- View assigned cases
- Support farmers
- Report field observations
- Coordinate with vets

---

## 📱 Platform Summary

| User Type | Mobile App | Web Dashboard | USSD Service |
|-----------|-----------|---------------|--------------|
| **Farmer (Smartphone)** | ✅ Primary | ❌ | ❌ |
| **Farmer (Basic Phone)** | ❌ | ❌ | ✅ Primary |
| **Local Veterinarian** | ✅ Primary | ❌ | ❌ |
| **Sector Veterinarian** | ❌ | ✅ Primary | ❌ |
| **Admin** | ❌ | ✅ Primary | ❌ |
| **Field Officer** | ✅ Optional | ❌ | ❌ |

---

## 🔐 Access Control Summary

### **Who Can Approve Users?**
- ✅ **Sector Veterinarians** - Can approve all user types
- ✅ **Admins** - Can approve all user types
- ❌ **Local Veterinarians** - Cannot approve users
- ❌ **Farmers** - Cannot approve users

### **Who Can View User Approvals?**
- ✅ **Sector Veterinarians** - Can view pending approvals
- ✅ **Admins** - Can view pending approvals
- ❌ **Local Veterinarians** - Cannot view approvals
- ❌ **Farmers** - Cannot view approvals

### **Login Requirements:**
All users must:
1. ✅ Verify phone number (OTP verification)
2. ✅ Be approved by Sector Vet or Admin
3. ✅ Have active account status

---

## 🎯 Your Specification vs Current Implementation

### ✅ **Your Specification:**
- **Sector Veterinarian** → Web Dashboard ✅ **CORRECT**
- **Local Veterinarian** → Mobile App ✅ **CORRECT**
- **Farmers with Smartphone** → Mobile App ✅ **CORRECT**
- **Farmers without Smartphone** → USSD ✅ **CORRECT**

### 📝 **Current Implementation Status:**

✅ **Fully Implemented:**
- Sector Vets use Web Dashboard
- Local Vets use Mobile App (role-based)
- Farmers can use Mobile App
- Farmers can use USSD Service

✅ **User Approval System:**
- Only Sector Vets and Admins can approve users
- Local Vets cannot approve users
- All users need approval before login

✅ **Platform Access:**
- Web Dashboard: Sector Vets + Admins
- Mobile App: Local Vets + Farmers (smartphone)
- USSD: Farmers (basic phone)

---

## 🚀 Next Steps to Align Implementation

The current implementation **matches your specification**! However, you may want to:

1. **Add role-based restrictions in Mobile App:**
   - Show different features for Local Vets vs Farmers
   - Hide admin features from Local Vets

2. **Enhance USSD Service:**
   - Ensure it's fully functional for farmers
   - Add more SMS command options

3. **Test User Flows:**
   - Test farmer registration → approval → login
   - Test local vet registration → approval → mobile app access
   - Test sector vet registration → web dashboard access

---

## 📞 Support & Contact

For questions about user roles or platform access, contact the system administrator.

