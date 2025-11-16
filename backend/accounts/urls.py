from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

router = DefaultRouter()
router.register(r'users', views.UserViewSet)
router.register(r'farmers', views.FarmerViewSet)
router.register(r'veterinarians', views.VeterinarianViewSet)

urlpatterns = [
    path('auth/register/', views.RegisterView.as_view(), name='register'),
    path('auth/login/', views.LoginView.as_view(), name='login'),
    path('auth/verify-otp/', views.VerifyOTPView.as_view(), name='verify-otp'),
    path('auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/password-reset/request/', views.RequestPasswordResetView.as_view(), name='request-password-reset'),
    path('auth/password-reset/verify-otp/', views.VerifyPasswordResetOTPView.as_view(), name='verify-password-reset-otp'),
    path('auth/password-reset/reset/', views.ResetPasswordView.as_view(), name='reset-password'),
    path('', include(router.urls)),
]
