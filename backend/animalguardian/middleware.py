"""
Database keep-alive middleware
Pings the database on each request to keep connections alive
"""
from django.db import connection
from django.utils.deprecation import MiddlewareMixin
import logging

logger = logging.getLogger(__name__)

class DatabaseKeepAliveMiddleware(MiddlewareMixin):
    """
    Middleware to keep database connections alive by pinging on each request.
    This prevents the database from going to sleep on platforms like Railway.
    """
    
    def process_request(self, request):
        """Ping database on each request"""
        try:
            # Only ping if using PostgreSQL (not SQLite)
            if connection.vendor == 'postgresql':
                with connection.cursor() as cursor:
                    cursor.execute("SELECT 1")
                    cursor.fetchone()
        except Exception as e:
            logger.warning(f"Database keep-alive ping failed: {e}")
        
        return None

