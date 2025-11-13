import json
import secrets

from django.contrib.auth import authenticate
from rest_framework import generics, viewsets, status, serializers
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken

from .models import User, VeterinarianProfile, FarmerProfile
from .serializers import (
    UserSerializer,
    VeterinarianProfileSerializer,
    FarmerProfileSerializer,
)

class RegisterView(generics.CreateAPIView):
    """Register a new user."""
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [AllowAny]
    
    def create(self, request, *args, **kwargs):
        extra_profile_fields = {}

        if hasattr(request.data, "copy"):
            data = request.data.copy()
        else:
            data = dict(request.data)

        for field in [
            "specialization",
            "license_number",
            "license_type",
            "clinic_name",
            "clinic_address",
            "years_of_experience",
            "working_hours",
            "is_available",
        ]:
            if field in data:
                value = data.pop(field)
                if isinstance(value, list):
                    value = value[0]
                extra_profile_fields[field] = value

        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        if user.user_type == "veterinarian":
            license_number = extra_profile_fields.get("license_number")
            license_type = extra_profile_fields.get("license_type") or "licensed"
            specialization = extra_profile_fields.get("specialization") or "General Practice"
            clinic_name = extra_profile_fields.get("clinic_name") or ""
            clinic_address = extra_profile_fields.get("clinic_address") or ""
            years_of_experience = extra_profile_fields.get("years_of_experience") or 0
            working_hours_data = extra_profile_fields.get("working_hours") or {}
            is_available_raw = extra_profile_fields.get("is_available")
            if isinstance(is_available_raw, str):
                is_available = is_available_raw.lower() in {"true", "1", "yes", "on"}
            elif isinstance(is_available_raw, bool):
                is_available = is_available_raw
            else:
                is_available = True

            if isinstance(working_hours_data, str):
                try:
                    working_hours_data = json.loads(working_hours_data)
                except json.JSONDecodeError:
                    working_hours_data = {}

            base_license = (license_number or f"VET-{user.id:04d}").upper()
            candidate_license = base_license
            attempts = 0
            while VeterinarianProfile.objects.filter(license_number=candidate_license).exists():
                attempts += 1
                candidate_license = f"{base_license}-{secrets.token_hex(2).upper()}"
                if attempts > 10:
                    raise serializers.ValidationError({"license_number": "Unable to generate unique license number."})

            VeterinarianProfile.objects.create(
                user=user,
                license_number=candidate_license,
                license_type=license_type,
                specialization=specialization,
                clinic_name=clinic_name,
                clinic_address=clinic_address,
                years_of_experience=int(years_of_experience) if str(years_of_experience).isdigit() else 0,
                working_hours=working_hours_data if isinstance(working_hours_data, dict) else {},
                is_available=is_available,
            )
            user.is_active = is_available
            user.save(update_fields=["is_active"])
        return Response({
            'message': 'User created successfully. Please verify your phone number.',
            'user_id': user.id
        }, status=status.HTTP_201_CREATED)

class LoginView(generics.GenericAPIView):
    """Login user with phone number, email, or username and password."""
    permission_classes = [AllowAny]
    
    def post(self, request):
        phone_number = request.data.get('phone_number')
        email = request.data.get('email')
        password = request.data.get('password')
        
        if not password:
            return Response({
                'error': 'Password is required.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Try to authenticate with phone number first, then email
        user = None
        if phone_number:
            user = authenticate(username=phone_number, password=password)
        elif email:
            user_obj = (
                User.objects.filter(email=email)
                .order_by("-id")
                .first()
            )
            if user_obj:
                user = authenticate(username=user_obj.phone_number, password=password)
        
        if user:
            refresh = RefreshToken.for_user(user)
            return Response({
                'access': str(refresh.access_token),
                'refresh': str(refresh),
                'user': UserSerializer(user).data
            })
        else:
            return Response({
                'error': 'Invalid credentials.'
            }, status=status.HTTP_401_UNAUTHORIZED)

class VerifyOTPView(generics.GenericAPIView):
    """Verify OTP for phone number."""
    permission_classes = [AllowAny]
    
    def post(self, request):
        phone_number = request.data.get('phone_number')
        otp_code = request.data.get('otp_code')
        
        # Simple OTP verification (in production, use proper OTP service)
        if otp_code == '123456':  # Default OTP for development
            try:
                user = User.objects.get(phone_number=phone_number)
                user.is_verified = True
                user.save()
                return Response({
                    'message': 'Phone number verified successfully.'
                })
            except User.DoesNotExist:
                return Response({
                    'error': 'User not found.'
                }, status=status.HTTP_404_NOT_FOUND)
        else:
            return Response({
                'error': 'Invalid OTP code.'
            }, status=status.HTTP_400_BAD_REQUEST)

class UserViewSet(viewsets.ModelViewSet):
    """ViewSet for User model."""
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    
    @action(detail=False, methods=['get'])
    def profile(self, request):
        """Get current user profile."""
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)

class FarmerViewSet(viewsets.ModelViewSet):
    """ViewSet for Farmer profiles."""
    queryset = FarmerProfile.objects.all()
    serializer_class = FarmerProfileSerializer
    permission_classes = [IsAuthenticated]
    
    @action(detail=False, methods=['get'])
    def profile(self, request):
        """Get farmer profile."""
        try:
            profile = request.user.farmer_profile
            serializer = self.get_serializer(profile)
            return Response(serializer.data)
        except FarmerProfile.DoesNotExist:
            return Response({
                'error': 'Farmer profile not found.'
            }, status=status.HTTP_404_NOT_FOUND)

class VeterinarianViewSet(viewsets.ModelViewSet):
    """ViewSet for Veterinarian profiles."""
    queryset = VeterinarianProfile.objects.select_related("user").all()
    serializer_class = VeterinarianProfileSerializer
    permission_classes = [IsAuthenticated]
    
    @action(detail=False, methods=['get'])
    def profile(self, request):
        """Get veterinarian profile."""
        try:
            profile = request.user.vet_profile
            serializer = self.get_serializer(profile)
            return Response(serializer.data)
        except VeterinarianProfile.DoesNotExist:
            return Response({
                'error': 'Veterinarian profile not found.'
            }, status=status.HTTP_404_NOT_FOUND)

    @action(detail=True, methods=["post"], url_path="set_status")
    def set_status(self, request, pk=None):
        """Update veterinarian availability status."""
        profile = self.get_object()
        is_available = request.data.get("is_available")
        if is_available is None:
            return Response(
                {"error": "is_available flag is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if isinstance(is_available, str):
            normalized = is_available.lower()
            if normalized in {"true", "1", "yes", "on"}:
                is_available_bool = True
            elif normalized in {"false", "0", "no", "off"}:
                is_available_bool = False
            else:
                return Response(
                    {"error": "Invalid is_available value."},
                    status=status.HTTP_400_BAD_REQUEST,
                )
        else:
            is_available_bool = bool(is_available)

        profile.is_available = is_available_bool
        profile.save(update_fields=["is_available", "updated_at"])

        profile.user.is_active = is_available_bool
        profile.user.save(update_fields=["is_active"])

        serializer = self.get_serializer(profile)
        return Response(serializer.data)
