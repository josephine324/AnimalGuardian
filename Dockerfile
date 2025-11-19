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

# Copy all project files from backend directory to /app
COPY backend/ /app/

# Debug: List contents to verify start.sh was copied
RUN ls -la /app/ | grep -E "(start.sh|manage.py)" || (echo "Files in /app:" && ls -la /app/ | head -30)

# Make startup script executable
RUN chmod +x /app/start.sh

# Upgrade pip and install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r /app/requirements.txt

# Collect static files (allow failure in case static files are not configured)
RUN python manage.py collectstatic --noinput || true

# Expose port
EXPOSE 8000

# Run startup script
CMD ["/app/start.sh"]

