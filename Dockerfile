# Use Python 3.11 slim image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file first (for better Docker layer caching)
# Handle both root and backend directory as build context
COPY requirements.txt /app/requirements.txt

# Upgrade pip and install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r /app/requirements.txt

# Copy startup script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Copy all project files to /app
# If Railway uses backend/ as root, this will copy from current directory
COPY . /app/

# Collect static files (allow failure in case static files are not configured)
RUN python manage.py collectstatic --noinput || true

# Expose port
EXPOSE 8000

# Run startup script
CMD ["/app/start.sh"]

