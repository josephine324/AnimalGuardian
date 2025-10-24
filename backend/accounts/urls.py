from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'users', views.UserViewSet)
router.register(r'farmers', views.FarmerViewSet)
router.register(r'veterinarians', views.VeterinarianViewSet)

urlpatterns = [
    path('auth/register/', views.RegisterView.as_view(), name='register'),
    path('auth/login/', views.LoginView.as_view(), name='login'),
    path('auth/verify-otp/', views.VerifyOTPView.as_view(), name='verify-otp'),
    path('', include(router.urls)),
]
