from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
import requests
from django.conf import settings


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def weather_current(request):
    """Get current weather information."""
    
    # Default location (Kigali, Rwanda) - can be customized based on user location
    lat = request.query_params.get('lat', '-1.9441')
    lon = request.query_params.get('lon', '30.0619')
    
    # For now, return mock data since we don't have a weather API key
    # In production, integrate with OpenWeatherMap or similar service
    weather_data = {
        'location': {
            'city': 'Kigali',
            'country': 'Rwanda',
            'lat': float(lat),
            'lon': float(lon),
        },
        'current': {
            'temperature': 22,
            'temperature_unit': 'celsius',
            'condition': 'Partly Cloudy',
            'humidity': 65,
            'wind_speed': 8,
            'wind_unit': 'km/h',
            'precipitation': 0,
            'precipitation_unit': 'mm',
        },
        'alerts': [],
        'forecast': {
            'today': {
                'high': 25,
                'low': 18,
                'condition': 'Partly Cloudy',
            },
            'tomorrow': {
                'high': 24,
                'low': 17,
                'condition': 'Sunny',
            },
        },
        'agricultural_advice': {
            'livestock_health': 'Good conditions for livestock. Ensure adequate shade and water.',
            'grazing_conditions': 'Favorable for grazing.',
            'disease_risk': 'Low risk of weather-related diseases.',
        },
    }
    
    return Response(weather_data)

