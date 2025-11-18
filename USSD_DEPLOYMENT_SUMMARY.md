# USSD Service - Quick Reference

## 📞 USSD Code

**Primary USSD Code: `*384*123#`**

This is the recommended code format for Rwanda. The actual code will be assigned by Africa's Talking after approval.

---

## 🚀 Quick Setup Steps

### 1. Get USSD Code from Africa's Talking
- Sign up at [africastalking.com](https://africastalking.com)
- Request USSD service code
- Get assigned code (e.g., `*384*123#`)

### 2. Deploy USSD Service
```bash
# Deploy to Railway
1. Create new Railway service
2. Point to ussd-service directory
3. Set environment variables
4. Deploy
```

### 3. Configure Africa's Talking
- Set callback URL: `https://your-service-url/ussd`
- Set SMS callback: `https://your-service-url/sms`
- Activate USSD code

### 4. Test
- Dial `*384*123#` from phone
- Test all menu options
- Verify case reporting works

---

## 📋 Environment Variables

```env
AFRICASTALKING_USERNAME=your_username
AFRICASTALKING_API_KEY=your_api_key
BACKEND_API_URL=https://animalguardian-backend-production.up.railway.app/api
USSD_SERVICE_USERNAME=service_phone_number
USSD_SERVICE_PASSWORD=service_password
PORT=5000
```

---

## 📱 USSD Menu

```
*384*123# → Welcome Menu
├─ 1. Report Animal Disease
├─ 2. Get Veterinary Advice
├─ 3. Check Vaccination Schedule
├─ 4. Weather Alerts
├─ 5. Contact Support
└─ 6. Exit
```

---

## 📞 SMS Commands

Send SMS to short code:
- `HELP` - Show commands
- `STATUS` - Livestock status
- `VACCINE` - Vaccination info
- `WEATHER` - Weather alerts
- `REPORT <symptoms>` - Report disease

---

**Full guide:** See `ussd-service/USSD_SETUP_GUIDE.md`

