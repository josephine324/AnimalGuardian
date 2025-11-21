# How to Run the Backend Server

## Option 1: Local Development (Using SQLite)

For local development and testing, follow these steps:

### Step 1: Navigate to Backend Directory
```powershell
cd C:\Users\Administrator\Downloads\AnimalGuardian\backend
```

### Step 2: Activate Virtual Environment
```powershell
# Windows PowerShell:
.\venv\Scripts\Activate.ps1

# Windows CMD:
venv\Scripts\activate

# macOS/Linux:
source venv/bin/activate
```

### Step 3: Ensure SQLite is Used (Unset DATABASE_URL)
```powershell
# In PowerShell, unset the DATABASE_URL environment variable
$env:DATABASE_URL = $null

# Or in CMD:
set DATABASE_URL=

# Or in bash/macOS/Linux:
unset DATABASE_URL
```

### Step 4: Run Database Migrations
```powershell
python manage.py migrate
```

This will:
- Create the SQLite database file (`db.sqlite3`) if it doesn't exist
- Run all pending migrations, including the livestock tag_number fix

### Step 5: (Optional) Create Admin User
```powershell
python manage.py createsuperuser
```

Follow the prompts to create an admin account.

### Step 6: Start the Development Server
```powershell
python manage.py runserver
```

The server will start at: **http://localhost:8000**

- **API Base URL:** http://localhost:8000/api
- **Admin Panel:** http://localhost:8000/admin

---

## Option 2: Production (Railway/PostgreSQL)

If you're running on Railway or have PostgreSQL configured:

### Step 1: Navigate to Backend Directory
```powershell
cd C:\Users\Administrator\Downloads\AnimalGuardian\backend
```

### Step 2: Activate Virtual Environment
```powershell
.\venv\Scripts\Activate.ps1
```

### Step 3: Ensure DATABASE_URL is Set
Make sure your `DATABASE_URL` environment variable is set (Railway sets this automatically).

### Step 4: Run Migrations
```powershell
python manage.py migrate
```

This will run all migrations including the livestock tag_number fix.

### Step 5: Start the Server

**For Development:**
```powershell
python manage.py runserver
```

**For Production (using Gunicorn):**
```powershell
gunicorn animalguardian.wsgi:application --bind 0.0.0.0:8000
```

---

## Troubleshooting

### Issue: "Error loading psycopg2 or psycopg module"

**Solution:** This means Django is trying to use PostgreSQL but the driver isn't installed. For local development:

1. Unset DATABASE_URL:
   ```powershell
   $env:DATABASE_URL = $null
   ```

2. Django will automatically use SQLite (no additional setup needed)

### Issue: Migration Errors

**Solution:** Make sure all migrations are applied:
```powershell
python manage.py migrate
```

### Issue: Port Already in Use

**Solution:** Use a different port:
```powershell
python manage.py runserver 8001
```

---

## Quick Start (Local Development)

```powershell
# 1. Navigate to backend
cd C:\Users\Administrator\Downloads\AnimalGuardian\backend

# 2. Activate virtual environment
.\venv\Scripts\Activate.ps1

# 3. Unset DATABASE_URL to use SQLite
$env:DATABASE_URL = $null

# 4. Run migrations
python manage.py migrate

# 5. Start server
python manage.py runserver
```

The backend will be available at: **http://localhost:8000**

---

## Verify Backend is Running

Open your browser and visit:
- http://localhost:8000/admin (should show login page)
- http://localhost:8000/api (should show API root)

Or test with curl:
```powershell
curl http://localhost:8000/api
```

