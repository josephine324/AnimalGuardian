"""
Root views for AnimalGuardian API
"""
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods


@require_http_methods(["GET"])
def api_root(request):
    """Root API endpoint that returns API information"""
    return JsonResponse({
        "name": "AnimalGuardian API",
        "version": "1.0.0",
        "description": "Veterinarian and Livestock Management System API",
        "documentation": {
            "api_base": "/api/",
            "admin_panel": "/admin/",
            "endpoints": {
                "authentication": "/api/auth/",
                "livestock": "/api/livestock/",
                "cases": "/api/cases/",
                "dashboard": "/api/dashboard/",
                "weather": "/api/weather/",
                "community": "/api/community/",
                "marketplace": "/api/marketplace/",
                "notifications": "/api/notifications/",
                "files": "/api/files/",
            }
        },
        "status": "active"
    })

