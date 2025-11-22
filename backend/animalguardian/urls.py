"""
URL configuration for animalguardian project.
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.http import JsonResponse
from .views import api_root

def health_check(request):
    """Simple health check endpoint that doesn't require database."""
    return JsonResponse({
        'status': 'healthy',
        'service': 'animalguardian-backend',
        'cors_enabled': True,
    })

urlpatterns = [
    path('health/', health_check, name='health-check'),
    path('', api_root, name='api-root'),
    path('admin/', admin.site.urls),
    path('api/', include('accounts.urls')),
    path('api/livestock/', include('livestock.urls')),
    path('api/cases/', include('cases.urls')),
    path('api/', include('notifications.urls')),
    path('api/dashboard/', include('dashboard.urls')),
    path('api/weather/', include('weather.urls')),
    path('api/community/', include('community.urls')),
    path('api/marketplace/', include('marketplace.urls')),
    path('api/files/', include('files.urls')),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
