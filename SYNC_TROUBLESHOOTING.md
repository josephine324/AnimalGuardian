# 🔄 Data Synchronization Troubleshooting Guide

## Issue: Farmers and Local Vets Created on Mobile App Not Showing on Web Dashboard

### ✅ What I've Fixed

1. **Added Pagination Support**: Both Farmers and Veterinarians pages now fetch with `page_size: 1000` to ensure all users are retrieved
2. **Added Manual Refresh Buttons**: Both pages now have refresh buttons to manually reload data
3. **Added Console Logging**: Added debug logs to track how many users are being fetched
4. **Improved Error Handling**: Better error messages and logging for debugging

### 🔍 How to Verify Data Synchronization

#### Step 1: Verify Mobile App is Using Deployed Backend

1. Check the `.env` file in `frontend/` directory:
   ```env
   API_BASE_URL=https://animalguardian.onrender.com/api
   ```

2. When registering a new user on mobile app, check the browser console (if running on web) or check network requests to confirm it's calling `https://animalguardian.onrender.com/api/auth/register/`

#### Step 2: Verify Web Dashboard is Using Deployed Backend

1. Check the `.env` file in `web-dashboard/` directory:
   ```env
   REACT_APP_API_URL=https://animalguardian.onrender.com/api
   ```

2. Open browser console (F12) on the web dashboard
3. Check Network tab to see API calls - they should go to `https://animalguardian.onrender.com/api`

#### Step 3: Test Data Flow

1. **Create a Farmer on Mobile App**:
   - Register a new farmer account
   - Note the phone number used

2. **Check Web Dashboard**:
   - Go to Farmers page
   - Click the "Refresh" button (top right)
   - Check browser console for: `Fetched farmers: X farmers`
   - Search for the phone number you used

3. **Create a Local Vet on Mobile App**:
   - Register a new local veterinarian account
   - Note the phone number used

4. **Check Web Dashboard**:
   - Go to Veterinarians page
   - Click the "Refresh" button (top right)
   - Check browser console for: `Fetched veterinarians: X local vets`
   - Search for the phone number you used

### 🐛 Common Issues and Solutions

#### Issue 1: Data Not Appearing After Registration

**Possible Causes:**
- Auto-refresh interval (30 seconds) hasn't triggered yet
- Browser cache
- API pagination limiting results

**Solutions:**
1. Click the "Refresh" button manually
2. Wait for auto-refresh (30 seconds)
3. Clear browser cache and reload
4. Check browser console for errors

#### Issue 2: API Returns Empty Array

**Check:**
1. Open browser console (F12)
2. Go to Network tab
3. Find the API call to `/farmers/` or `/veterinarians/`
4. Check the response - it should contain data

**If empty:**
- Verify the user was actually created on the backend
- Check if there are any filters applied
- Verify authentication token is valid

#### Issue 3: Only Some Users Appearing

**Possible Causes:**
- Pagination - default page size might be 20
- Approval status filtering (shouldn't apply to farmers)

**Solutions:**
- The fix I applied sets `page_size: 1000` to fetch all users
- Check if there are any client-side filters applied

### 🔧 Debugging Steps

1. **Check Browser Console**:
   ```javascript
   // You should see logs like:
   // "Fetched farmers: 5 farmers"
   // "Fetched veterinarians: 3 local vets"
   ```

2. **Check Network Requests**:
   - Open DevTools (F12)
   - Go to Network tab
   - Filter by "farmers" or "veterinarians"
   - Check the request URL and response

3. **Verify Backend API Directly**:
   - Open: `https://animalguardian.onrender.com/api/farmers/`
   - You should see JSON data (if authenticated)
   - Or use: `https://animalguardian.onrender.com/api/veterinarians/`

4. **Check API Response Format**:
   ```json
   {
     "results": [...],
     "count": 10,
     "next": null,
     "previous": null
   }
   ```
   OR
   ```json
   [...]
   ```

### 📝 Manual Testing Checklist

- [ ] Mobile app `.env` file points to deployed backend
- [ ] Web dashboard `.env` file points to deployed backend
- [ ] Created a farmer account on mobile app
- [ ] Clicked "Refresh" on Farmers page
- [ ] Farmer appears in the list
- [ ] Created a local vet account on mobile app
- [ ] Clicked "Refresh" on Veterinarians page
- [ ] Local vet appears in the list
- [ ] Auto-refresh (30 seconds) works correctly

### 🚀 Quick Fixes

If data still doesn't sync:

1. **Hard Refresh Web Dashboard**:
   - Press `Ctrl + Shift + R` (Windows) or `Cmd + Shift + R` (Mac)
   - This clears cache and reloads

2. **Restart Web Dashboard**:
   ```powershell
   cd web-dashboard
   npm start
   ```

3. **Check Backend Health**:
   - Visit: https://animalguardian.onrender.com/health/
   - Should return: `{"status": "healthy", ...}`

4. **Verify Authentication**:
   - Make sure you're logged in as a Sector Veterinarian
   - Check that your auth token is valid

### 📞 Still Having Issues?

If data still doesn't synchronize:

1. Check browser console for errors
2. Check Network tab for failed API requests
3. Verify both apps are using the same backend URL
4. Check if the backend is actually receiving the registration requests
5. Verify the user was created in the backend database

---

**Note**: The auto-refresh happens every 30 seconds. For immediate updates, use the "Refresh" button.

