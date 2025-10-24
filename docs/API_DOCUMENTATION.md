# AnimalGuardian API Documentation

## Overview

The AnimalGuardian API provides endpoints for managing livestock health, case reports, veterinary consultations, and farmer communications through a digital platform designed for smallholder farmers in Rwanda.

## Base URL

- **Development**: `http://localhost:8000/api`
- **Production**: `https://api.animalguardian.rw/api`

## Authentication

The API uses JWT (JSON Web Token) authentication. Include the token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

## API Endpoints

### Authentication

#### Register Farmer
```http
POST /auth/register/
```

**Request Body:**
```json
{
  "phone_number": "+250123456789",
  "first_name": "John",
  "last_name": "Doe",
  "password": "securepassword",
  "gender": "M",
  "province": "Eastern",
  "district": "Nyagatare",
  "sector": "Rwimiyaga",
  "preferred_language": "rw"
}
```

#### Login
```http
POST /auth/login/
```

**Request Body:**
```json
{
  "phone_number": "+250123456789",
  "password": "securepassword"
}
```

**Response:**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "phone_number": "+250123456789",
    "first_name": "John",
    "last_name": "Doe",
    "user_type": "farmer"
  }
}
```

#### Verify OTP
```http
POST /auth/verify-otp/
```

**Request Body:**
```json
{
  "phone_number": "+250123456789",
  "otp_code": "123456"
}
```

### Farmers

#### Get Farmer Profile
```http
GET /farmers/profile/
```

#### Update Farmer Profile
```http
PUT /farmers/profile/
```

**Request Body:**
```json
{
  "farm_name": "Doe Family Farm",
  "farm_size": 2.5,
  "farm_size_unit": "hectares",
  "years_of_farming": 5,
  "has_smartphone": true,
  "has_internet_access": false,
  "preferred_communication": "sms"
}
```

#### Get Farmer's Livestock
```http
GET /farmers/livestock/
```

**Query Parameters:**
- `livestock_type`: Filter by livestock type (cattle, goat, sheep, etc.)
- `status`: Filter by status (healthy, sick, pregnant, etc.)
- `page`: Page number for pagination
- `page_size`: Number of items per page

### Livestock Management

#### Add New Livestock
```http
POST /livestock/
```

**Request Body:**
```json
{
  "livestock_type": 1,
  "breed": 2,
  "name": "Bella",
  "tag_number": "AG001",
  "gender": "F",
  "birth_date": "2020-03-15",
  "weight_kg": 450.5,
  "color": "Brown",
  "description": "Healthy adult cow"
}
```

#### Get Livestock Details
```http
GET /livestock/{id}/
```

#### Update Livestock
```http
PUT /livestock/{id}/
```

#### Get Livestock Health Records
```http
GET /livestock/{id}/health-records/
```

#### Add Health Record
```http
POST /livestock/{id}/health-records/
```

**Request Body:**
```json
{
  "check_date": "2024-01-15",
  "check_type": "routine",
  "temperature": 38.5,
  "weight": 455.0,
  "symptoms": "None observed",
  "diagnosis": "Healthy",
  "treatment": "Continue normal care",
  "veterinarian": 2
}
```

#### Get Vaccination Records
```http
GET /livestock/{id}/vaccinations/
```

#### Add Vaccination Record
```http
POST /livestock/{id}/vaccinations/
```

**Request Body:**
```json
{
  "vaccine_name": "Foot and Mouth Disease",
  "vaccine_type": "Inactivated",
  "vaccination_date": "2024-01-15",
  "next_due_date": "2024-07-15",
  "batch_number": "FMD2024001",
  "dosage": "2ml",
  "route": "IM",
  "veterinarian": 2,
  "notes": "No adverse reactions observed"
}
```

### Case Reports

#### Report New Case
```http
POST /cases/reports/
```

**Request Body:**
```json
{
  "livestock": 1,
  "symptoms_observed": "Loss of appetite, lethargy, fever",
  "duration_of_symptoms": "2 days",
  "number_of_affected_animals": 1,
  "suspected_disease": 3,
  "photos": ["https://example.com/photo1.jpg"],
  "videos": ["https://example.com/video1.mp4"],
  "location_notes": "Near the water trough"
}
```

#### Get Case Reports
```http
GET /cases/reports/
```

**Query Parameters:**
- `status`: Filter by status (pending, under_review, diagnosed, etc.)
- `urgency`: Filter by urgency (low, medium, high, urgent)
- `livestock`: Filter by livestock ID
- `reported_after`: Filter cases reported after this date
- `reported_before`: Filter cases reported before this date

#### Get Case Details
```http
GET /cases/reports/{id}/
```

#### Update Case Status
```http
PATCH /cases/reports/{id}/
```

**Request Body:**
```json
{
  "status": "under_review",
  "urgency": "high"
}
```

### Veterinary Consultations

#### Create Consultation
```http
POST /cases/reports/{case_id}/consultations/
```

**Request Body:**
```json
{
  "consultation_type": "initial_review",
  "diagnosis": "Possible bacterial infection",
  "treatment_plan": "Antibiotic treatment for 5 days",
  "medications_prescribed": "Penicillin 2ml daily",
  "dosage_instructions": "Administer 2ml intramuscularly once daily for 5 days",
  "follow_up_required": true,
  "follow_up_date": "2024-01-20",
  "consultation_fee": 5000,
  "veterinarian_notes": "Monitor closely for improvement"
}
```

#### Get Consultations for Case
```http
GET /cases/reports/{case_id}/consultations/
```

#### Add Follow-up Record
```http
POST /consultations/{consultation_id}/follow-ups/
```

**Request Body:**
```json
{
  "follow_up_date": "2024-01-20",
  "follow_up_type": "phone_call",
  "treatment_response": "Significant improvement observed",
  "improvement_observed": true,
  "additional_notes": "Animal is eating well and active"
}
```

### Notifications

#### Get User Notifications
```http
GET /notifications/
```

**Query Parameters:**
- `status`: Filter by status (pending, sent, delivered, read)
- `channel`: Filter by channel (sms, push, email, in_app)
- `unread_only`: Show only unread notifications

#### Mark Notification as Read
```http
PATCH /notifications/{id}/
```

**Request Body:**
```json
{
  "status": "read",
  "read_at": "2024-01-15T10:30:00Z"
}
```

#### Update Notification Preferences
```http
PUT /notifications/preferences/
```

**Request Body:**
```json
{
  "enable_sms": true,
  "enable_push": true,
  "enable_email": false,
  "enable_vaccination_reminders": true,
  "enable_pregnancy_reminders": true,
  "enable_disease_alerts": true,
  "preferred_language": "rw"
}
```

### Outbreak Alerts

#### Get Active Alerts
```http
GET /alerts/outbreaks/
```

#### Get Alert Details
```http
GET /alerts/outbreaks/{id}/
```

### Analytics

#### Get Dashboard Statistics
```http
GET /analytics/dashboard/
```

**Response:**
```json
{
  "total_livestock": 45,
  "healthy_livestock": 42,
  "sick_livestock": 3,
  "pending_cases": 2,
  "resolved_cases": 15,
  "upcoming_vaccinations": 8,
  "recent_activities": [...]
}
```

#### Get Livestock Statistics
```http
GET /analytics/livestock/
```

#### Get Case Statistics
```http
GET /analytics/cases/
```

## Error Responses

### 400 Bad Request
```json
{
  "error": "Validation Error",
  "details": {
    "phone_number": ["This field is required."],
    "password": ["Password must be at least 8 characters."]
  }
}
```

### 401 Unauthorized
```json
{
  "error": "Authentication credentials were not provided."
}
```

### 403 Forbidden
```json
{
  "error": "You do not have permission to perform this action."
}
```

### 404 Not Found
```json
{
  "error": "Not found."
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error."
}
```

## Rate Limiting

The API implements rate limiting to prevent abuse:

- **Authentication endpoints**: 5 requests per minute
- **General endpoints**: 100 requests per hour
- **File upload endpoints**: 10 requests per hour

## File Uploads

### Upload Images/Videos
```http
POST /files/upload/
Content-Type: multipart/form-data
```

**Form Data:**
- `file`: The file to upload
- `type`: File type (image, video, audio)
- `related_object`: Related object type (livestock, case, etc.)
- `related_id`: ID of the related object

**Response:**
```json
{
  "id": 1,
  "filename": "cow_health_check.jpg",
  "file_url": "https://api.animalguardian.rw/media/files/cow_health_check.jpg",
  "file_size": 1024000,
  "content_type": "image/jpeg",
  "uploaded_at": "2024-01-15T10:30:00Z"
}
```

## Webhooks

### Case Status Updates
The API can send webhooks when case statuses change:

**Endpoint**: `POST /webhooks/case-status-update/`

**Payload:**
```json
{
  "event": "case.status.updated",
  "data": {
    "case_id": 123,
    "old_status": "pending",
    "new_status": "under_review",
    "updated_by": 2,
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

## SDKs and Libraries

### JavaScript/React Native
```bash
npm install axios
```

```javascript
import axios from 'axios';

const api = axios.create({
  baseURL: 'https://api.animalguardian.rw/api',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
});
```

### Python
```bash
pip install requests
```

```python
import requests

headers = {
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
}

response = requests.get(
    'https://api.animalguardian.rw/api/farmers/profile/',
    headers=headers
)
```

## Support

For API support and questions:
- **Email**: api-support@animalguardian.rw
- **Documentation**: https://docs.animalguardian.rw
- **Status Page**: https://status.animalguardian.rw
