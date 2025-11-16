from rest_framework import generics, viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from .models import User, VeterinarianProfile, FarmerProfile
from .serializers import UserSerializer, VeterinarianProfileSerializer, FarmerProfileSerializer

class RegisterView(generics.CreateAPIView):
    """Register a new user."""
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [AllowAny]
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
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
            try:
                user_obj = User.objects.get(email=email)
                user = authenticate(username=user_obj.phone_number, password=password)
            except User.DoesNotExist:
                pass
        
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
    queryset = VeterinarianProfile.objects.all()
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
