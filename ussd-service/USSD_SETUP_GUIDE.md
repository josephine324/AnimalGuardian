# USSD Service Setup Guide - AnimalGuardian

Complete guide to set up and deploy the USSD service for farmers with basic phones.

## 📞 USSD Code

**Recommended USSD Code: `*384*123#`**

This format (`*384*123#`) is commonly used in Rwanda:
- `*384` - Service provider prefix (can vary by country)
- `*123` - Your service identifier
- `#` - End marker

**Alternative formats:**
- `*123#` - Simple format (may conflict with other services)
- `*384*AG#` - Using "AG" for AnimalGuardian
- `*384*1#` - Short format

**Note:** The actual USSD code depends on:
1. Your Africa's Talking account configuration
2. Available codes in your country (Rwanda)
3. Approval from telecom providers

---

## 🚀 Step-by-Step Setup Guide

### Step 1: Create Africa's Talking Account

1. **Sign Up:**
   - Go to [https://africastalking.com](https://africastalking.com)
   - Click "Sign Up" or "Get Started"
   - Create an account (use your organization email)

2. **Verify Account:**
   - Verify your email address
   - Complete profile information
   - Add payment method (if required)

3. **Get API Credentials:**
   - Go to Dashboard → Settings → API Key
   - Copy your **Username** and **API Key**
   - Save these securely (you'll need them later)

---

### Step 2: Request USSD Service Code

1. **Contact Africa's Talking Support:**
   - Email: support@africastalking.com
   - Subject: "USSD Service Code Request for AnimalGuardian"
   
2. **Provide Information:**
   ```
   Service Name: AnimalGuardian
   Purpose: Livestock health management for farmers
   Country: Rwanda
   Target Users: Smallholder farmers in Nyagatare District
   Expected Volume: [Your estimate]
   Preferred Code: *384*123# (or suggest alternatives)
   ```

3. **Wait for Approval:**
   - Africa's Talking will review your request
   - They may suggest alternative codes
   - Approval typically takes 1-3 business days

4. **Get Your USSD Code:**
   - Once approved, you'll receive:
     - USSD Service Code (e.g., `*384*123#`)
     - Service configuration details
     - Testing instructions

---

### Step 3: Deploy USSD Service

#### Option A: Deploy to Railway (Recommended)

1. **Create Railway Account:**
   - Go to [https://railway.app](https://railway.app)
   - Sign up with GitHub

2. **Create New Service:**
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose your AnimalGuardian repository
   - Select `ussd-service` directory as root

3. **Configure Environment Variables:**
   In Railway dashboard, add these variables:
   ```
   AFRICASTALKING_USERNAME=your_africastalking_username
   AFRICASTALKING_API_KEY=your_africastalking_api_key
   BACKEND_API_URL=https://animalguardian-backend-production.up.railway.app/api
   USSD_SERVICE_USERNAME=service_account_phone
   USSD_SERVICE_PASSWORD=service_account_password
   PORT=5000
   ```

4. **Deploy:**
   - Railway will automatically build and deploy
   - Wait for deployment to complete
   - Copy the public URL (e.g., `https://ussd-service-production.up.railway.app`)

#### Option B: Deploy to Other Platform

**Heroku:**
```bash
heroku create animalguardian-ussd
heroku config:set AFRICASTALKING_USERNAME=your_username
heroku config:set AFRICASTALKING_API_KEY=your_api_key
heroku config:set BACKEND_API_URL=https://animalguardian-backend-production.up.railway.app/api
git push heroku main
```

**VPS/Server:**
```bash
# Install dependencies
pip install -r requirements.txt

# Run with gunicorn
gunicorn --bind 0.0.0.0:5000 --workers 2 app:app

# Or use systemd service
sudo systemctl start ussd-service
```

---

### Step 4: Configure Africa's Talking USSD

1. **Login to Africa's Talking Dashboard:**
   - Go to [https://account.africastalking.com](https://account.africastalking.com)
   - Navigate to **USSD** section

2. **Create USSD Application:**
   - Click "Create USSD Application"
   - Fill in details:
     ```
     Application Name: AnimalGuardian
     Service Code: *384*123# (or your assigned code)
     Callback URL: https://your-ussd-service-url.railway.app/ussd
     ```

3. **Set Callback URL:**
   - This is your deployed USSD service endpoint
   - Format: `https://your-service-url/ussd`
   - Must be HTTPS (Africa's Talking requires SSL)

4. **Save Configuration:**
   - Click "Save" or "Create"
   - Note the Service Code assigned

---

### Step 5: Configure SMS (Optional but Recommended)

1. **Enable SMS Service:**
   - In Africa's Talking Dashboard → SMS
   - Enable SMS service for your account

2. **Set SMS Callback URL:**
   ```
   Callback URL: https://your-ussd-service-url.railway.app/sms
   ```

3. **Configure Short Code (if available):**
   - Request a short code for SMS commands
   - Format: `12345` (5-digit number)
   - Users can send SMS to this number

---

### Step 6: Test USSD Service

#### Test Health Check:
```bash
curl https://your-ussd-service-url.railway.app/health
```

Expected response:
```json
{
  "status": "healthy",
  "service": "AnimalGuardian USSD Service",
  "timestamp": "2024-01-15T10:00:00"
}
```

#### Test USSD Endpoint:
```bash
curl -X POST https://your-ussd-service-url.railway.app/ussd \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "test_session_123",
    "phoneNumber": "+250123456789",
    "serviceCode": "*384*123#",
    "text": ""
  }'
```

Expected response:
```json
{
  "sessionId": "test_session_123",
  "response": "CON Welcome to AnimalGuardian!\n1. Report Animal Disease\n2. Get Veterinary Advice\n..."
}
```

#### Test with Real Phone:
1. Dial the USSD code: `*384*123#`
2. You should see the welcome menu
3. Navigate through options
4. Test case reporting

---

### Step 7: Create Service Account (For Backend Authentication)

To enable full backend integration, create a service account:

1. **Register Service Account:**
   - Use mobile app or backend admin
   - Phone: `+250XXXXXXXXX` (dedicated service number)
   - User Type: `farmer` (or create special service account type)
   - Password: Strong password

2. **Approve Service Account:**
   - Login to web dashboard as Sector Vet
   - Approve the service account

3. **Add to Environment Variables:**
   ```
   USSD_SERVICE_USERNAME=+250XXXXXXXXX
   USSD_SERVICE_PASSWORD=your_strong_password
   ```

---

## 📋 USSD Code Format

### Recommended: `*384*123#`

**Format Breakdown:**
- `*` - Start marker
- `384` - Service provider prefix (Rwanda)
- `*` - Separator
- `123` - Your service identifier
- `#` - End marker

### Alternative Codes:
- `*123#` - Simple (may conflict)
- `*384*AG#` - With "AG" identifier
- `*384*1#` - Short format
- `*384*VET#` - Veterinary identifier

**Note:** Final code depends on Africa's Talking approval and availability.

---

## 🔧 Configuration Checklist

- [ ] Africa's Talking account created
- [ ] API credentials obtained (Username & API Key)
- [ ] USSD service code requested and approved
- [ ] USSD service deployed (Railway/Heroku/VPS)
- [ ] Environment variables configured
- [ ] Callback URL set in Africa's Talking dashboard
- [ ] Service account created and approved
- [ ] Health check endpoint working
- [ ] USSD endpoint tested
- [ ] Real phone test completed

---

## 📱 User Instructions

### For Farmers:

**To Access AnimalGuardian via USSD:**
1. Dial: `*384*123#` (or your assigned code)
2. Follow the menu prompts
3. Select options using numbers (1, 2, 3, etc.)
4. Enter text when prompted
5. Press `#` to confirm

**Available Features:**
- Report animal disease
- Check vaccination schedule
- Get weather alerts
- Contact support

**SMS Commands:**
Send SMS to short code (if configured):
- `HELP` - Show commands
- `STATUS` - Check livestock status
- `VACCINE` - Get vaccination info
- `WEATHER` - Get weather alerts
- `REPORT <symptoms>` - Report disease

---

## 🐛 Troubleshooting

### USSD Not Responding:
1. Check if service is deployed and running
2. Verify callback URL is correct and accessible
3. Check Africa's Talking dashboard for errors
4. Verify USSD code is active

### "Service Unavailable":
1. Check backend API URL is correct
2. Verify backend is running
3. Check service account credentials
4. Review logs in Railway/Heroku

### Authentication Errors:
1. Verify `USSD_SERVICE_USERNAME` and `USSD_SERVICE_PASSWORD`
2. Ensure service account is approved
3. Check backend API is accessible

### SMS Not Working:
1. Verify SMS service is enabled in Africa's Talking
2. Check SMS callback URL is set
3. Verify short code is configured
4. Check account balance (if required)

---

## 📞 Support Contacts

**Africa's Talking Support:**
- Email: support@africastalking.com
- Phone: +254 20 529 9000
- Website: https://africastalking.com/support

**AnimalGuardian Support:**
- Email: support@animalguardian.rw
- Phone: +250 XXX XXX XXX

---

## 🔐 Security Notes

1. **Never commit credentials to Git:**
   - Use environment variables
   - Use `.env` file (add to `.gitignore`)

2. **Use HTTPS:**
   - Africa's Talking requires HTTPS for callbacks
   - Railway/Heroku provide SSL automatically

3. **Protect Service Account:**
   - Use strong password
   - Rotate credentials periodically
   - Monitor for unauthorized access

4. **Rate Limiting:**
   - Consider implementing rate limiting
   - Monitor for abuse

---

## 📊 Monitoring

**Monitor USSD Service:**
- Railway/Heroku logs
- Africa's Talking dashboard analytics
- Backend API logs
- Error tracking (Sentry, etc.)

**Key Metrics:**
- Number of USSD sessions
- Successful case reports
- Error rates
- Response times

---

## ✅ Next Steps

1. **Request USSD Code** from Africa's Talking
2. **Deploy Service** to Railway/Heroku
3. **Configure Callback URL** in Africa's Talking
4. **Test Thoroughly** with real phones
5. **Create Service Account** for backend auth
6. **Monitor and Optimize** based on usage

---

## 📝 Example USSD Flow

```
User dials: *384*123#

Step 0: Welcome Menu
CON Welcome to AnimalGuardian!
1. Report Animal Disease
2. Get Veterinary Advice
3. Check Vaccination Schedule
4. Weather Alerts
5. Contact Support
6. Exit

User selects: 1

Step 1: Select Animal Type
CON Report Animal Disease
Please select animal type:
1. Cattle
2. Goat
3. Sheep
4. Pig
5. Chicken
6. Other

User selects: 1

Step 2: Describe Symptoms
CON Report Disease - Cattle
Please describe symptoms:
(Text your response)

User enters: Loss of appetite, lethargy

Step 3: Case Created
END Thank you for reporting!
A veterinarian will contact you shortly.
Reference: AG2024001
```

---

**Ready to set up? Start with Step 1: Create Africa's Talking Account!**

