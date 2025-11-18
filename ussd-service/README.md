# AnimalGuardian USSD Service

USSD/SMS service for farmers with basic phones to access AnimalGuardian functionality.

## Features

### ✅ Fully Working (Backend Integrated)
- **User Verification** - Verifies farmer status, approval, and phone verification
- **Case Reporting (USSD & SMS)** - Creates case reports via USSD menu or SMS commands
- **Backend API Integration** - Fetches farmer data and creates cases in backend

### ✅ Updated (Backend Integrated with Fallback)
- **Vaccination Schedule (USSD)** - Fetches real data from backend, falls back to mock if auth not configured
- **Weather Alerts (USSD)** - Fetches real data from backend, falls back to mock if auth not configured
- **Livestock Status (SMS)** - Fetches real data from backend, falls back to mock if auth not configured
- **Vaccination Info (SMS)** - Fetches real data from backend, falls back to mock if auth not configured
- **Weather Info (SMS)** - Fetches real data from backend, falls back to mock if auth not configured

## Setup

### 1. Install Dependencies

```bash
cd ussd-service
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Configure Environment Variables

Create a `.env` file:

```env
# Africa's Talking API Configuration
AFRICASTALKING_USERNAME=your_africastalking_username
AFRICASTALKING_API_KEY=your_africastalking_api_key

# Backend API Configuration
BACKEND_API_URL=http://localhost:8000/api
# For production: https://animalguardian-backend-production.up.railway.app/api

# USSD Service Authentication (Optional but Recommended)
# Service account credentials for backend API authentication
# If not provided, some features will fall back to mock data
USSD_SERVICE_USERNAME=your_service_phone_number
USSD_SERVICE_PASSWORD=your_service_password

# Server Configuration
PORT=5000
```

### 3. Run Locally

```bash
python app.py
```

Or with gunicorn:
```bash
gunicorn --bind 0.0.0.0:5000 --workers 2 --timeout 120 app:app
```

## Testing

### Test Health Check

```bash
curl http://localhost:5000/health
```

### Test USSD Endpoint

```bash
curl -X POST http://localhost:5000/ussd \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "test_123",
    "phoneNumber": "+250123456789",
    "serviceCode": "*123#",
    "text": ""
  }'
```

### Test SMS Endpoint

```bash
curl -X POST http://localhost:5000/sms \
  -H "Content-Type: application/json" \
  -d '{
    "from": "+250123456789",
    "text": "HELP",
    "date": "2024-01-15T10:00:00Z"
  }'
```

### Run Test Script

```bash
# Install dependencies first
pip install requests python-dotenv

# Run tests
python test_endpoints.py
```

## USSD Menu Flow

```
Step 0: Welcome Menu
├─ 1. Report Animal Disease ✅ (Fully Working)
├─ 2. Get Veterinary Advice ⚠️ (Needs Backend)
├─ 3. Check Vaccination Schedule ✅ (Backend Integrated)
├─ 4. Weather Alerts ✅ (Backend Integrated)
├─ 5. Contact Support ✅ (Working)
└─ 6. Exit ✅ (Working)
```

## SMS Commands

- `HELP` - Show available commands
- `STATUS` - Check livestock status (Backend Integrated)
- `VACCINE` - Get vaccination info (Backend Integrated)
- `WEATHER` - Get weather alerts (Backend Integrated)
- `REPORT <symptoms>` - Report disease (Fully Working)
- `ADVICE` - Get health advice
- `CONTACT` - Get support info

## Deployment

### Railway Deployment

1. **Create New Service in Railway**
   - Connect your GitHub repository
   - Select `ussd-service` directory as root

2. **Set Environment Variables in Railway**
   ```
   AFRICASTALKING_USERNAME=your_username
   AFRICASTALKING_API_KEY=your_api_key
   BACKEND_API_URL=https://animalguardian-backend-production.up.railway.app/api
   USSD_SERVICE_USERNAME=service_phone_number
   USSD_SERVICE_PASSWORD=service_password
   PORT=5000
   ```

3. **Railway will automatically:**
   - Build using Dockerfile
   - Deploy and expose the service
   - Provide a public URL

### Docker Deployment

```bash
# Build image
docker build -t ussd-service .

# Run container
docker run -p 5000:5000 \
  -e AFRICASTALKING_USERNAME=your_username \
  -e AFRICASTALKING_API_KEY=your_api_key \
  -e BACKEND_API_URL=http://localhost:8000/api \
  ussd-service
```

## API Endpoints

- `GET /health` - Health check endpoint
- `POST /ussd` - Handle USSD requests from Africa's Talking
- `POST /sms` - Handle SMS requests from Africa's Talking

## Authentication

The USSD service uses service account credentials (`USSD_SERVICE_USERNAME` and `USSD_SERVICE_PASSWORD`) to authenticate with the backend API. 

**Important:** 
- If authentication is not configured, features will fall back to mock data with a message to check the mobile app
- For full functionality, configure service account credentials in `.env` file

## Notes

- **User Type Restriction:** Only farmers can use USSD service
- **Approval Required:** Farmers must be approved by Sector Vet before using USSD
- **Phone Verification:** Farmers must verify their phone number before using USSD
- **Case Reporting:** All cases from USSD/SMS appear in the same system as mobile app cases

## Troubleshooting

1. **"Auth token not available"** - Configure `USSD_SERVICE_USERNAME` and `USSD_SERVICE_PASSWORD` in `.env`
2. **"Failed to fetch livestock"** - Check backend API URL and ensure backend is running
3. **"Farmer not found"** - Ensure farmer is registered and approved in the system
4. **USSD not responding** - Check Africa's Talking configuration and service code

