#!/bin/bash

# AnimalGuardian Setup Script
# This script sets up the development environment for the AnimalGuardian project

set -e

echo "🚀 Setting up AnimalGuardian Development Environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_requirements() {
    print_status "Checking system requirements..."
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required but not installed."
        exit 1
    fi
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is required but not installed."
        exit 1
    fi
    
    # Check PostgreSQL
    if ! command -v psql &> /dev/null; then
        print_warning "PostgreSQL is not installed. Please install it manually."
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        print_error "Git is required but not installed."
        exit 1
    fi
    
    print_status "System requirements check completed."
}

# Setup backend
setup_backend() {
    print_status "Setting up Django backend..."
    
    cd backend
    
    # Create virtual environment
    if [ ! -d "venv" ]; then
        print_status "Creating Python virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Install requirements
    print_status "Installing Python dependencies..."
    pip install --upgrade pip
    pip install -r requirements.txt
    
    # Create environment file
    if [ ! -f ".env" ]; then
        print_status "Creating environment file..."
        cat > .env << EOF
# Django Settings
SECRET_KEY=your-secret-key-here
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

# Database
DATABASE_URL=postgresql://username:password@localhost:5432/animalguardian

# Africa's Talking
AFRICASTALKING_USERNAME=your-username
AFRICASTALKING_API_KEY=your-api-key

# Twilio (Backup)
TWILIO_ACCOUNT_SID=your-account-sid
TWILIO_AUTH_TOKEN=your-auth-token

# Email
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password

# Celery
CELERY_BROKER_URL=redis://localhost:6379
CELERY_RESULT_BACKEND=redis://localhost:6379
EOF
        print_warning "Please update the .env file with your actual configuration values."
    fi
    
    # Run migrations
    print_status "Running Django migrations..."
    python manage.py makemigrations
    python manage.py migrate
    
    # Create superuser
    print_status "Creating Django superuser..."
    echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@example.com', 'admin123')" | python manage.py shell
    
    cd ..
    print_status "Backend setup completed."
}

# Setup frontend
setup_frontend() {
    print_status "Setting up React Native frontend..."
    
    cd frontend
    
    # Install dependencies
    print_status "Installing Node.js dependencies..."
    npm install
    
    # Create environment file
    if [ ! -f ".env" ]; then
        print_status "Creating environment file..."
        cat > .env << EOF
# API Configuration
API_BASE_URL=http://localhost:8000/api
API_TIMEOUT=30000

# App Configuration
APP_NAME=AnimalGuardian
APP_VERSION=1.0.0

# Features
ENABLE_PUSH_NOTIFICATIONS=true
ENABLE_LOCATION_SERVICES=true
ENABLE_CAMERA=true
EOF
    fi
    
    # Setup iOS (if on macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_status "Setting up iOS dependencies..."
        cd ios && pod install && cd ..
    fi
    
    cd ..
    print_status "Frontend setup completed."
}

# Setup web dashboard
setup_web_dashboard() {
    print_status "Setting up React web dashboard..."
    
    cd web-dashboard
    
    # Install dependencies
    print_status "Installing Node.js dependencies..."
    npm install
    
    # Create environment file
    if [ ! -f ".env" ]; then
        print_status "Creating environment file..."
        cat > .env << EOF
# API Configuration
REACT_APP_API_BASE_URL=http://localhost:8000/api
REACT_APP_API_TIMEOUT=30000

# App Configuration
REACT_APP_NAME=AnimalGuardian Dashboard
REACT_APP_VERSION=1.0.0
EOF
    fi
    
    cd ..
    print_status "Web dashboard setup completed."
}

# Setup USSD service
setup_ussd_service() {
    print_status "Setting up USSD service..."
    
    cd ussd-service
    
    # Create virtual environment
    if [ ! -d "venv" ]; then
        print_status "Creating Python virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Install requirements
    print_status "Installing Python dependencies..."
    pip install --upgrade pip
    pip install -r requirements.txt
    
    # Create environment file
    if [ ! -f ".env" ]; then
        print_status "Creating environment file..."
        cat > .env << EOF
# Africa's Talking
AFRICASTALKING_USERNAME=your-username
AFRICASTALKING_API_KEY=your-api-key

# Backend API
BACKEND_API_URL=http://localhost:8000/api

# Flask Configuration
FLASK_ENV=development
FLASK_DEBUG=True
EOF
    fi
    
    cd ..
    print_status "USSD service setup completed."
}

# Create database
setup_database() {
    print_status "Setting up PostgreSQL database..."
    
    # Check if PostgreSQL is running
    if ! pg_isready -q; then
        print_warning "PostgreSQL is not running. Please start PostgreSQL service."
        return
    fi
    
    # Create database
    createdb animalguardian 2>/dev/null || print_warning "Database 'animalguardian' already exists or could not be created."
    
    print_status "Database setup completed."
}

# Main setup function
main() {
    print_status "Starting AnimalGuardian project setup..."
    
    # Check requirements
    check_requirements
    
    # Setup database
    setup_database
    
    # Setup backend
    setup_backend
    
    # Setup frontend
    setup_frontend
    
    # Setup web dashboard
    setup_web_dashboard
    
    # Setup USSD service
    setup_ussd_service
    
    print_status "🎉 AnimalGuardian setup completed successfully!"
    print_status ""
    print_status "Next steps:"
    print_status "1. Update environment files with your actual configuration"
    print_status "2. Start PostgreSQL service"
    print_status "3. Run 'python backend/manage.py runserver' to start Django backend"
    print_status "4. Run 'npm start' in frontend/ to start React Native app"
    print_status "5. Run 'npm start' in web-dashboard/ to start web dashboard"
    print_status "6. Run 'python ussd-service/app.py' to start USSD service"
    print_status ""
    print_status "For more information, check the README.md file."
}

# Run main function
main "$@"
