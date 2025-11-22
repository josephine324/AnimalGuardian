"""
Django settings for AnimalGuardian project.
"""

import os
from pathlib import Path
from decouple import config
import dj_database_url

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = config('SECRET_KEY', default='django-insecure-change-this-in-production')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = config('DEBUG', default=True, cast=bool)

# ALLOWED_HOSTS - Read from environment or use defaults
ALLOWED_HOSTS_STR = config('ALLOWED_HOSTS', default='localhost,127.0.0.1')
ALLOWED_HOSTS = [host.strip() for host in ALLOWED_HOSTS_STR.split(',') if host.strip()]

# Add Render domain automatically (Render sets RENDER_EXTERNAL_HOSTNAME)
RENDER_EXTERNAL_HOSTNAME = config('RENDER_EXTERNAL_HOSTNAME', default=None)
if RENDER_EXTERNAL_HOSTNAME:
    if RENDER_EXTERNAL_HOSTNAME not in ALLOWED_HOSTS:
        ALLOWED_HOSTS.append(RENDER_EXTERNAL_HOSTNAME)

# Add Render wildcard for all Render subdomains
if RENDER_EXTERNAL_HOSTNAME or 'RENDER' in os.environ:
    # Add common Render patterns
    render_patterns = [
        '*.onrender.com',
        'animalguardian.onrender.com',
    ]
    for pattern in render_patterns:
        if pattern not in ALLOWED_HOSTS:
            ALLOWED_HOSTS.append(pattern)

# Application definition
DJANGO_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

THIRD_PARTY_APPS = [
    'rest_framework',
    'rest_framework_simplejwt',
    'corsheaders',
    'drf_spectacular',
]

LOCAL_APPS = [
    'accounts',
    'livestock',
    'cases',
    'notifications',
    'weather',
    'community',
    'marketplace',
]

INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + LOCAL_APPS

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # First - handle CORS early
    'django.middleware.security.SecurityMiddleware',  # Security headers
    'django.middleware.gzip.GZipMiddleware',  # Compress responses (add before CommonMiddleware)
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'animalguardian.middleware.DatabaseKeepAliveMiddleware',  # Keep database alive
]

ROOT_URLCONF = 'animalguardian.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'animalguardian.wsgi.application'

# Database
# For local development, explicitly check environment variable first
# This allows us to override .env file settings
import os
# Check environment variable first - prioritize it over .env file
# If DATABASE_URL is explicitly set to empty string in environment, force SQLite
DATABASE_URL_ENV = os.environ.get('DATABASE_URL')

# Only use .env file if DATABASE_URL is NOT in environment at all
# If it's set to empty string, that means we explicitly want SQLite
if 'DATABASE_URL' in os.environ:
    # Environment variable exists (even if empty) - use it and ignore .env
    DATABASE_URL = DATABASE_URL_ENV.strip() if DATABASE_URL_ENV and DATABASE_URL_ENV.strip() else None
else:
    # Not in environment at all - check .env file (for production/Render)
    # But only if we're not in DEBUG mode (local dev should use SQLite)
    if not DEBUG:
        DATABASE_URL = config('DATABASE_URL', default=None)
    else:
        # In DEBUG mode, default to SQLite if not in environment
        DATABASE_URL = None

# Debug: Print database configuration (only in DEBUG mode)
if DEBUG:
    print(f"[DEBUG] DATABASE_URL from env: {repr(DATABASE_URL_ENV)}")
    print(f"[DEBUG] Final DATABASE_URL: {repr(DATABASE_URL)}")
    print(f"[DEBUG] Using database engine: {'PostgreSQL' if DATABASE_URL and DATABASE_URL.startswith(('postgres://', 'postgresql://', 'postgresql+psycopg2://')) else 'SQLite'}")

# Only use PostgreSQL if DATABASE_URL is set and looks like a valid database URL
# For local development, set DATABASE_URL='' in environment to use SQLite
if DATABASE_URL and DATABASE_URL.startswith(('postgres://', 'postgresql://', 'postgresql+psycopg2://')):
    # Use PostgreSQL from DATABASE_URL (Render provides this)
    # Use parse() instead of config() to avoid reading from .env file
    DATABASES = {
        'default': dj_database_url.parse(DATABASE_URL, conn_max_age=600)
    }
    
    # Database connection pooling settings for PostgreSQL (optimized for Render)
    if DATABASES['default'].get('ENGINE') == 'django.db.backends.postgresql':
        DATABASES['default']['OPTIONS'] = {
            'connect_timeout': 10,
            'options': '-c statement_timeout=30000',  # 30 second statement timeout
            # Connection pool settings
            'connect_timeout': 10,
            'keepalives': 1,
            'keepalives_idle': 30,
            'keepalives_interval': 10,
            'keepalives_count': 5,
        }
        # Keep connections alive longer (reduces connection overhead)
        DATABASES['default']['CONN_MAX_AGE'] = 600  # 10 minutes
        # Connection pool size (Render free tier can handle this)
        DATABASES['default']['ATOMIC_REQUESTS'] = False  # Disable for better performance
else:
    # Fallback to SQLite for local development
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'db.sqlite3',
        }
    }

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
        'OPTIONS': {
            'min_length': 8,
        }
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'Africa/Kigali'
USE_I18N = True
USE_TZ = True

# Static files (CSS, JavaScript, Images)
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_DIRS = [
    BASE_DIR / 'static',
] if (BASE_DIR / 'static').exists() else []

# Media files
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# Default primary key field type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Custom User Model
AUTH_USER_MODEL = 'accounts.User'

# REST Framework Configuration
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
    # Performance optimizations
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',  # Only JSON (faster than BrowsableAPIRenderer)
    ],
    'DEFAULT_PARSER_CLASSES': [
        'rest_framework.parsers.JSONParser',
        'rest_framework.parsers.FormParser',
        'rest_framework.parsers.MultiPartParser',
    ],
}

# JWT Configuration
from datetime import timedelta
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(hours=24),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
}

# CORS Configuration
# Allow localhost on any port for development
# Note: Origins must not have trailing slashes or paths
CORS_ALLOWED_ORIGINS = [
    "https://animalguards.netlify.app",  # Production frontend (Netlify)
]

# Allow CORS from environment variable (for Render/production)
CORS_ALLOWED_ORIGINS_ENV = config('CORS_ALLOWED_ORIGINS', default='')
if CORS_ALLOWED_ORIGINS_ENV:
    # Strip trailing slashes from origins (CORS doesn't allow paths in origins)
    origins = [origin.strip().rstrip('/') for origin in CORS_ALLOWED_ORIGINS_ENV.split(',')]
    CORS_ALLOWED_ORIGINS.extend(origins)

# For development, allow localhost on any port using regex patterns
# django-cors-headers supports CORS_ALLOWED_ORIGIN_REGEXES
import re
CORS_ALLOWED_ORIGIN_REGEXES = [
    re.compile(r'^http://localhost:\d+$'),
    re.compile(r'^http://127\.0\.0\.1:\d+$'),
    re.compile(r'^http://192\.168\.\d+\.\d+:\d+$'),  # Local network IPs
    re.compile(r'^http://10\.\d+\.\d+\.\d+:\d+$'),  # Private network IPs
]

# Allow all origins in development (set via environment variable)
# For local development, allow all origins to prevent CORS issues
if DEBUG:
    # In debug mode, allow all origins for easier local development
    # Force to True in debug mode regardless of environment variable
    CORS_ALLOW_ALL_ORIGINS = True
else:
    # In production, check environment variable first
    # Default to True if explicitly set, otherwise use specific origins
    allow_all_env = os.environ.get('CORS_ALLOW_ALL_ORIGINS') or config('CORS_ALLOW_ALL_ORIGINS', default='')
    if allow_all_env and allow_all_env.lower() in ('true', '1', 'yes'):
        CORS_ALLOW_ALL_ORIGINS = True
        print("CORS: Allowing all origins (CORS_ALLOW_ALL_ORIGINS=true)")
    else:
        # Default to allowing all origins in production to prevent CORS issues
        # This can be restricted later by setting CORS_ALLOW_ALL_ORIGINS=false
        # and using specific origins
        CORS_ALLOW_ALL_ORIGINS = True  # Changed: Default to True for easier deployment
        print("CORS: Allowing all origins by default (set CORS_ALLOW_ALL_ORIGINS=false to restrict)")
        # Still ensure production frontend is in allowed origins as backup
        if 'https://animalguards.netlify.app' not in CORS_ALLOWED_ORIGINS:
            CORS_ALLOWED_ORIGINS.append('https://animalguards.netlify.app')
        print(f"CORS: Allowed origins (backup): {CORS_ALLOWED_ORIGINS}")
        print(f"CORS: Allowed origin regexes: {[str(r.pattern) for r in CORS_ALLOWED_ORIGIN_REGEXES]}")

CORS_ALLOW_CREDENTIALS = True

# Additional CORS settings for preflight requests
CORS_ALLOW_METHODS = [
    'DELETE',
    'GET',
    'OPTIONS',
    'PATCH',
    'POST',
    'PUT',
]

CORS_ALLOW_HEADERS = [
    'accept',
    'accept-encoding',
    'authorization',
    'content-type',
    'dnt',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
]

# Add Netlify domain to regex patterns as well (if not already present)
netlify_pattern = re.compile(r'^https://.*\.netlify\.app$')
if netlify_pattern not in CORS_ALLOWED_ORIGIN_REGEXES:
    CORS_ALLOWED_ORIGIN_REGEXES.append(netlify_pattern)

# API Documentation
SPECTACULAR_SETTINGS = {
    'TITLE': 'AnimalGuardian API',
    'DESCRIPTION': 'Digital Livestock Support System API',
    'VERSION': '1.0.0',
}

# Africa's Talking Configuration
AFRICASTALKING_USERNAME = config('AFRICASTALKING_USERNAME', default='')
AFRICASTALKING_API_KEY = config('AFRICASTALKING_API_KEY', default='')

# Twilio Configuration (backup)
TWILIO_ACCOUNT_SID = config('TWILIO_ACCOUNT_SID', default='')
TWILIO_AUTH_TOKEN = config('TWILIO_AUTH_TOKEN', default='')

# Celery Configuration
CELERY_BROKER_URL = config('CELERY_BROKER_URL', default='redis://localhost:6379')
CELERY_RESULT_BACKEND = config('CELERY_RESULT_BACKEND', default='redis://localhost:6379')

# Email Configuration
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = config('EMAIL_HOST', default='smtp.gmail.com')
EMAIL_PORT = config('EMAIL_PORT', default=587, cast=int)
EMAIL_USE_TLS = config('EMAIL_USE_TLS', default=True, cast=bool)
EMAIL_HOST_USER = config('EMAIL_HOST_USER', default='')
EMAIL_HOST_PASSWORD = config('EMAIL_HOST_PASSWORD', default='')
DEFAULT_FROM_EMAIL = config('DEFAULT_FROM_EMAIL', default='mutesijosephine324@gmail.com')

# Caching Configuration (in-memory cache for Render free tier)
# Using local memory cache - fast and no external dependencies
# For production with Redis, change to: 'django.core.cache.backends.redis.RedisCache'
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'unique-snowflake',
        'OPTIONS': {
            'MAX_ENTRIES': 1000,  # Maximum number of entries in cache
            'CULL_FREQUENCY': 3,  # Fraction of entries culled when MAX_ENTRIES is reached
        },
        'TIMEOUT': 300,  # 5 minutes default timeout
    }
}

# Cache settings for frequently accessed data
CACHE_TTL = {
    'dashboard_stats': 60,  # Cache dashboard stats for 1 minute
    'user_profile': 300,  # Cache user profiles for 5 minutes
    'livestock_types': 3600,  # Cache livestock types for 1 hour (rarely changes)
}

# Logging Configuration
# Use console logging for Render (stdout/stderr are captured automatically)
# File logging is not used in production to avoid FileNotFoundError
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
        'django.db.backends': {
            'handlers': ['console'],
            'level': 'WARNING',  # Reduce database query logging (too verbose)
            'propagate': False,
        },
    },
}
