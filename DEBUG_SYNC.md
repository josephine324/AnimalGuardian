# 🔍 Debugging Data Synchronization

## Step-by-Step Debugging Process

### 1. Verify Backend Connection

**Test Backend Health:**
```bash
# Open in browser or use curl
https://animalguardian.onrender.com/health/
```

Should return: `{"status": "healthy", ...}`

### 2. Verify Mobile App is Using Deployed Backend

**Check frontend/.env:**
```env
API_BASE_URL=https://animalguardian.onrender.com/api
```

**Test Registration:**
1. Open mobile app (or Flutter web)
2. Open browser DevTools (F12) if on web
3. Go to Network tab
4. Register a new farmer
5. Check the network request:
   - URL should be: `https://animalguardian.onrender.com/api/auth/register/`
   - Status should be: `201 Created`
   - Response should contain: `{"message": "Account created successfully!", "user_id": X}`

### 3. Verify Web Dashboard is Using Deployed Backend

**Check web-dashboard/.env:**
```env
REACT_APP_API_URL=https://animalguardian.onrender.com/api
```

**Test API Call:**
1. Open web dashboard
2. Open browser DevTools (F12)
3. Go to Console tab
4. Go to Farmers page
5. Click "Refresh" button
6. Check console for: `Fetched farmers: X farmers`
7. Go to Network tab
8. Find the request to `/farmers/`
9. Check:
   - URL: `https://animalguardian.onrender.com/api/farmers/`
   - Status: `200 OK`
   - Response should contain array of farmers

### 4. Direct API Test

**Test Farmers Endpoint (requires authentication):**
```javascript
// In browser console on web dashboard (after login)
fetch('https://animalguardian.onrender.com/api/farmers/', {
  headers: {
    'Authorization': 'Bearer ' + localStorage.getItem('authToken'),
    'Content-Type': 'application/json'
  }
})
.then(r => r.json())
.then(data => {
  console.log('Farmers:', data);
  console.log('Count:', Array.isArray(data) ? data.length : (data.results?.length || 0));
});
```

**Test Veterinarians Endpoint:**
```javascript
fetch('https://animalguardian.onrender.com/api/veterinarians/', {
  headers: {
    'Authorization': 'Bearer ' + localStorage.getItem('authToken'),
    'Content-Type': 'application/json'
  }
})
.then(r => r.json())
.then(data => {
  console.log('Veterinarians:', data);
  console.log('Count:', Array.isArray(data) ? data.length : (data.results?.length || 0));
});
```

### 5. Check for Common Issues

#### Issue A: Authentication Token Expired
**Symptoms:** API returns 401 Unauthorized
**Solution:** Logout and login again on web dashboard

#### Issue B: Wrong Backend URL
**Symptoms:** Network errors or wrong data
**Solution:** 
- Verify `.env` files
- Restart both apps after changing `.env`

#### Issue C: Pagination Limiting Results
**Symptoms:** Only seeing first 20 users
**Solution:** Already fixed with `page_size: 1000`

#### Issue D: CORS Errors
**Symptoms:** Network errors in console
**Solution:** Backend should allow all origins in DEBUG mode

#### Issue E: User Not Actually Created
**Symptoms:** Registration succeeds but user doesn't appear
**Solution:** Check backend logs or database directly

### 6. Verify User Creation

**After registering on mobile app:**
1. Note the phone number used
2. On web dashboard, search for that phone number
3. If not found, check:
   - Was registration successful? (Check mobile app response)
   - Is user_type correct? (should be 'farmer' or 'local_vet')
   - Check browser console for errors

### 7. Check Response Format

The API might return data in different formats:

**Format 1 (Array):**
```json
[
  {"id": 1, "phone_number": "0781234567", ...},
  {"id": 2, "phone_number": "0787654321", ...}
]
```

**Format 2 (Paginated):**
```json
{
  "count": 10,
  "next": null,
  "previous": null,
  "results": [
    {"id": 1, ...},
    {"id": 2, ...}
  ]
}
```

The code handles both formats, but verify which one is being returned.

### 8. Manual Database Check (if you have access)

If you have backend access, you can check directly:
```python
# In Django shell or admin
from accounts.models import User
farmers = User.objects.filter(user_type='farmer')
print(f"Total farmers: {farmers.count()}")
for farmer in farmers:
    print(f"- {farmer.phone_number} ({farmer.first_name} {farmer.last_name})")
```

## Quick Test Script

Run this in browser console on web dashboard (after login):

```javascript
async function testSync() {
  console.log('=== Testing Data Synchronization ===');
  
  // Test Farmers
  try {
    const farmersRes = await fetch('https://animalguardian.onrender.com/api/farmers/', {
      headers: {
        'Authorization': 'Bearer ' + localStorage.getItem('authToken'),
        'Content-Type': 'application/json'
      }
    });
    const farmersData = await farmersRes.json();
    const farmers = Array.isArray(farmersData) ? farmersData : (farmersData.results || []);
    console.log('✅ Farmers:', farmers.length, 'found');
    console.log('Farmers list:', farmers.map(f => `${f.first_name} ${f.last_name} (${f.phone_number})`));
  } catch (err) {
    console.error('❌ Farmers Error:', err);
  }
  
  // Test Veterinarians
  try {
    const vetsRes = await fetch('https://animalguardian.onrender.com/api/veterinarians/', {
      headers: {
        'Authorization': 'Bearer ' + localStorage.getItem('authToken'),
        'Content-Type': 'application/json'
      }
    });
    const vetsData = await vetsRes.json();
    const vets = Array.isArray(vetsData) ? vetsData : (vetsData.results || []);
    const localVets = vets.filter(v => v.user_type === 'local_vet');
    console.log('✅ Local Vets:', localVets.length, 'found');
    console.log('Vets list:', localVets.map(v => `${v.first_name} ${v.last_name} (${v.phone_number})`));
  } catch (err) {
    console.error('❌ Veterinarians Error:', err);
  }
  
  console.log('=== Test Complete ===');
}

testSync();
```

## Expected Behavior

1. **Register Farmer on Mobile** → Should appear on Web Dashboard within 30 seconds (or immediately after clicking Refresh)
2. **Register Local Vet on Mobile** → Should appear on Web Dashboard (even if not approved)
3. **Auto-refresh** → Updates every 30 seconds automatically
4. **Manual Refresh** → Updates immediately when button clicked

## Still Not Working?

1. **Check Browser Console** for errors
2. **Check Network Tab** for failed requests
3. **Verify Authentication** - Make sure you're logged in as Sector Vet
4. **Check Backend Logs** - If you have access
5. **Test API Directly** - Use the test script above




