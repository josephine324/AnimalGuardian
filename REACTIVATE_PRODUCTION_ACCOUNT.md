# Reactivate Local Vet Account in Production

## Problem

When a local vet goes offline, their account was getting deactivated in the production database. We've fixed the code to prevent this, but **existing deactivated accounts need to be manually reactivated**.

## Solutions

### Option 1: Via Django Admin Panel (Easiest)

1. Login to production admin panel: `https://animalguardian.onrender.com/admin/`
2. Go to **Users** section
3. Find the local vet account (search by phone number or email)
4. Click on the user
5. Check the **Active** checkbox
6. Save

### Option 2: Via Django Management Command

If you have SSH access to production server:

```bash
python manage.py reactivate_local_vets
```

### Option 3: Via Django Shell (Production)

```bash
python manage.py shell
```

Then run:
```python
from accounts.models import User
user = User.objects.get(phone_number='0780555261')  # Replace with actual phone
user.is_active = True
user.save()
print("Account reactivated!")
```

### Option 4: Via API (If you have admin access)

1. Login as admin/sector vet
2. Use the user update endpoint to reactivate

## After Reactivation

✅ The account will be active  
✅ Local vet can login normally  
✅ Going offline will NOT deactivate the account (code fix prevents this)  
✅ Offline status only affects task assignment visibility  

## Prevention

The code fix we deployed ensures:
- `user.is_active = True` is **always** set when toggling availability
- Account **never** gets deactivated when going offline
- Only `is_available` field controls offline status (for task assignments)

---

**The fix is deployed, but you need to manually reactivate existing deactivated accounts in production.**

