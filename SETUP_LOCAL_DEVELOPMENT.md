# Setting Up Local Development with Real Credentials

This guide shows you how to use your **real production credentials** locally without hardcoding anything. The system is fully dynamic and ready for deployment!

## 🎯 Goal

- Use your **real credentials** from production locally
- Everything works **dynamically** (no hardcoded values)
- Code is **ready to push** to production
- Your **real name** appears in the dashboard

## ✅ Option 1: Sync User from Production (Recommended)

If you already have an account on the deployed site, sync it locally:

```bash
cd backend
python sync_user_from_production.py --email "your@email.com" --password "YourPassword"
```

This will:
1. Login to your production API
2. Get your user data
3. Create/update your user in the local database
4. Use the same credentials locally

**Example:**
```bash
python sync_user_from_production.py --email "r.uwitonze@alustudent.com" --password "YourRealPassword"
```

## ✅ Option 2: Register Locally with Same Credentials

You can also register locally using the registration API with your real credentials:

### Via API (using curl or Postman):

```bash
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "your@email.com",
    "phone_number": "0781234567",
    "password": "YourPassword",
    "password_confirm": "YourPassword",
    "first_name": "Your",
    "last_name": "Name",
    "user_type": "sector_vet"
  }'
```

### Via Web Dashboard Registration Page:

1. Go to `http://localhost:3000/signup`
2. Fill in your real details
3. Complete registration
4. Login with your credentials

## ✅ Option 3: Interactive Script

Run the interactive script and enter your real credentials:

```bash
cd backend
python create_user_from_input.py
```

## 🔧 Making User Type Dynamic

After creating your user, if you need to access the web dashboard:

- **Sector Veterinarian** or **Admin**: Can access web dashboard
- **Local Veterinarian** or **Farmer**: Use mobile app

To change user type (e.g., make yourself a sector vet for dashboard access):

```bash
cd backend
python manage.py shell
```

Then run:
```python
from accounts.models import User
user = User.objects.get(email='your@email.com')
user.user_type = 'sector_vet'
user.is_staff = True
user.is_approved_by_admin = True
user.save()
```

## 🚀 What Happens After Setup

1. ✅ Login at `http://localhost:3000/login` with your **real credentials**
2. ✅ Dashboard shows: **"Welcome back, [Your Real Name]!"**
3. ✅ All user info is displayed dynamically
4. ✅ No hardcoded values anywhere
5. ✅ Ready to push to production!

## 📝 Important Notes

- **No Hardcoding**: All user data comes from the database dynamically
- **Production Ready**: The same code works in production
- **Real Credentials**: Use your actual registration details
- **Dynamic Names**: Your real name appears automatically

## 🔍 Verify Everything is Dynamic

After logging in, check:
- Header shows your real name
- Sidebar shows your real name
- User menu shows your real email/phone
- Notifications show your real name
- Everything pulls from `userData` in localStorage (which comes from API)

## 🐛 Troubleshooting

**Issue**: "Invalid credentials"
- Make sure you created the user locally with the script
- Check that email/password match what you used

**Issue**: "Welcome mobile user"
- Clear localStorage: `localStorage.clear()` in browser console
- Logout and login again

**Issue**: Can't access dashboard
- Make sure your user type is `sector_vet` or `admin`
- Check `is_approved_by_admin` is `True`

---

**Everything is now dynamic and production-ready! 🎉**

