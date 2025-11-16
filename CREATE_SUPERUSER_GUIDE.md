# Create Superuser on Railway

## Option 1: Using Railway CLI (Recommended)

1. **Install Railway CLI** (if not already installed):
   ```bash
   npm i -g @railway/cli
   ```

2. **Login to Railway**:
   ```bash
   railway login
   ```

3. **Link to your project**:
   ```bash
   railway link
   ```
   Select your project and service when prompted.

4. **Run the create superuser script**:
   ```bash
   railway run python backend/create_superuser.py
   ```
   
   When prompted, enter a password for the superuser.

## Option 2: Using Railway Dashboard

1. Go to Railway → `animalguardian-backend` service
2. Click "Deployments" tab
3. Click on the latest deployment
4. Click "View Logs" or use the terminal option
5. Run:
   ```bash
   python manage.py shell
   ```
   
   Then in the Python shell:
   ```python
   from accounts.models import User
   user = User.objects.create_superuser(
       phone_number='+250780570632',
       username='admin',
       email='mutesijosephine324@gmail.com',
       password='your-password-here',
       user_type='admin',
       is_verified=True,
   )
   print(f'Superuser created: {user.phone_number}')
   ```

## Option 3: Using Django createsuperuser command

Run this command via Railway CLI:
```bash
railway run python manage.py createsuperuser
```

When prompted:
- **Phone number**: `+250780570632`
- **Username**: `admin`
- **Email**: `mutesijosephine324@gmail.com`
- **Password**: (enter your desired password)

## After Creating Superuser

You can now login to the admin panel at:
- URL: `https://animalguardian-backend-production-b5a8.up.railway.app/admin/`
- Phone number: `+250780570632`
- Password: (the password you set)

