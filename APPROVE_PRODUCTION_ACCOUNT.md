# Approve Account on Production

## Status
✅ **Code is already deployed** - All fixes are on production  
⚠️ **Account exists but needs approval** - Account `0780480780` is pending approval

## Quick Steps to Approve

### Option 1: Via Web Dashboard (Recommended)

1. **Login to Production Dashboard**
   - Go to: `https://animalguardian.onrender.com`
   - Login as sector vet/admin

2. **Go to User Approval Page**
   - Click "User Approval" in sidebar (should show badge with pending count)
   - OR go directly to: `https://animalguardian.onrender.com/user-approval`

3. **Approve the Account**
   - Find "Aggy Irakiza" (phone: 0780480780)
   - Click "Approve" button
   - Optionally add approval notes
   - Click confirm

### Option 2: Via Django Admin Panel

1. **Login to Admin Panel**
   - Go to: `https://animalguardian.onrender.com/admin/`
   - Login with admin credentials

2. **Find the User**
   - Go to "Users" section
   - Search for phone number: `0780480780`
   - Click on the user

3. **Approve the Account**
   - Check the box: **"Approved by admin"**
   - Check the box: **"Active"**
   - Click "Save"

### Option 3: Via API (if you have access)

If you have admin/sector vet credentials and API access:

```bash
# First, login to get token
curl -X POST https://animalguardian.onrender.com/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"phone_number":"YOUR_ADMIN_PHONE","password":"YOUR_PASSWORD"}'

# Then approve the user (replace TOKEN and USER_ID)
curl -X POST https://animalguardian.onrender.com/api/users/USER_ID/approve/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"notes":"Approved for testing"}'
```

## After Approval

Once approved, the user can:
- ✅ Login to mobile app
- ✅ Login to web dashboard (if local vet)
- ✅ Receive case assignments
- ✅ Use all app features

## Verify Approval

Test login at:
- Mobile app: Use phone `0780480780` and password
- Production dashboard: Should show account as approved

## Troubleshooting

**If approval page doesn't show the user:**
- Refresh the page (Ctrl+R)
- Check browser console for errors
- Verify you're logged in as sector vet/admin

**If login still fails after approval:**
- Verify account is both "Active" AND "Approved by admin"
- Check that password is correct
- Wait a few minutes for changes to propagate

