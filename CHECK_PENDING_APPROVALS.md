# Troubleshooting: Local Vet Not Showing in Pending Approvals

## Issue
You created a local vet account via the mobile app, but it's not appearing in the sector vet dashboard's "User Approval" page.

## Common Causes & Solutions

### 1. **Different API Environments**
The mobile app and dashboard might be pointing to different APIs:

- **Mobile App**: Check if it's using:
  - Local: `http://localhost:8000/api`
  - Production: `https://animalguardian.onrender.com/api`

- **Web Dashboard**: Check if it's using:
  - Local: `http://localhost:8000/api`
  - Production: `https://animalguardian.onrender.com/api`

**Solution**: Ensure both are pointing to the same API.

### 2. **Account Created on Production**
If you created the account on production but are checking the local dashboard:

**Solution**: 
- Go to production dashboard: `https://animalguardian.onrender.com`
- OR create the account on local backend

### 3. **Dashboard Not Refreshing**
The dashboard might need a manual refresh.

**Solution**: 
- Click the "Refresh" button on the User Approval page
- OR reload the browser page (Ctrl+R or F5)
- OR check the browser console for errors

### 4. **Account Already Approved**
The account might have been auto-approved somehow.

**Check**: 
- Verify the account's `is_approved_by_admin` status in the database
- Check if any scripts auto-approved it

### 5. **Filter Issues**
The query filters for:
- `is_approved_by_admin = False`
- `user_type IN ['farmer', 'local_vet']`
- `is_verified = True`

**Solution**: Verify the account meets all these criteria.

## Quick Check Script

Run this to check pending approvals:

```bash
cd backend
python manage.py shell
```

Then:
```python
from accounts.models import User
pending = User.objects.filter(
    is_approved_by_admin=False,
    user_type__in=['farmer', 'local_vet'],
    is_verified=True
)
print(f'Pending approvals: {pending.count()}')
for u in pending:
    print(f'  - {u.get_full_name()} ({u.phone_number})')
```

## Next Steps

1. Verify which API the mobile app is using
2. Verify which API the dashboard is using
3. Check if account was created on production or local
4. Manually refresh the dashboard page
5. Check browser console for API errors

