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

# Copy all project files to /app
# Railway's build context might be 'backend', so we need to check
# First, try copying from current directory (if build context is backend)
# If that doesn't work, Railway might need to be configured differently
COPY . /app/

# Debug: List contents to verify start.sh was copied
RUN echo "=== Checking for start.sh ===" && \
    if [ -f /app/start.sh ]; then \
        echo "✓ start.sh found"; \
        ls -lh /app/start.sh; \
    else \
        echo "✗ start.sh NOT found"; \
        echo "Files in /app/:"; \
        ls -la /app/ | head -30; \
        echo "Looking for .sh files:"; \
        find /app -name "*.sh" 2>/dev/null || echo "No .sh files found"; \
        exit 1; \
    fi

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

