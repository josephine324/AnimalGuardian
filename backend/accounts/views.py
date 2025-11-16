from rest_framework import generics, viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from django.utils import timezone
from datetime import timedelta
import random
from django.conf import settings
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
            # Check if user is verified (phone verification)
            if not user.is_verified:
                return Response({
                    'error': 'Your phone number is not verified. Please verify your phone number first.'
                }, status=status.HTTP_403_FORBIDDEN)
            
            # Check if user is approved by admin/vet
            if not user.is_approved_by_admin:
                return Response({
                    'error': 'Your account is pending approval from an administrator or sector veterinarian. Please wait for approval before logging in.',
                    'pending_approval': True
                }, status=status.HTTP_403_FORBIDDEN)
            
            # Check if user is active
            if not user.is_active:
                return Response({
                    'error': 'Your account has been deactivated. Please contact support.'
                }, status=status.HTTP_403_FORBIDDEN)
            
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

class RequestPasswordResetView(generics.GenericAPIView):
    """Request password reset - sends OTP to phone/email."""
    permission_classes = [AllowAny]
    
    def post(self, request):
        phone_number = request.data.get('phone_number')
        email = request.data.get('email')
        
        if not phone_number and not email:
            return Response({
                'error': 'Phone number or email is required.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            if phone_number:
                user = User.objects.get(phone_number=phone_number)
            else:
                user = User.objects.get(email=email)
        except User.DoesNotExist:
            # Don't reveal if user exists for security
            return Response({
                'message': 'If the account exists, a password reset code has been sent.'
            }, status=status.HTTP_200_OK)
        
        # Generate 6-digit OTP
        otp_code = str(random.randint(100000, 999999))
        user.password_reset_code = otp_code
        user.password_reset_expires_at = timezone.now() + timedelta(minutes=15)
        user.save()
        
        # TODO: Send OTP via SMS/Email using Africa's Talking
        # For now, in development, we'll just return it (remove in production!)
        if settings.DEBUG:
            return Response({
                'message': 'Password reset code sent. Check your phone/email.',
                'otp_code': otp_code  # Remove this in production!
            }, status=status.HTTP_200_OK)
        
        return Response({
            'message': 'Password reset code sent. Check your phone/email.'
        }, status=status.HTTP_200_OK)


class VerifyPasswordResetOTPView(generics.GenericAPIView):
    """Verify password reset OTP."""
    permission_classes = [AllowAny]
    
    def post(self, request):
        phone_number = request.data.get('phone_number')
        email = request.data.get('email')
        otp_code = request.data.get('otp_code')
        
        if not otp_code:
            return Response({
                'error': 'OTP code is required.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            if phone_number:
                user = User.objects.get(phone_number=phone_number)
            elif email:
                user = User.objects.get(email=email)
            else:
                return Response({
                    'error': 'Phone number or email is required.'
                }, status=status.HTTP_400_BAD_REQUEST)
        except User.DoesNotExist:
            return Response({
                'error': 'User not found.'
            }, status=status.HTTP_404_NOT_FOUND)
        
        # Check if OTP is valid and not expired
        if user.password_reset_code != otp_code:
            return Response({
                'error': 'Invalid OTP code.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if user.password_reset_expires_at and user.password_reset_expires_at < timezone.now():
            return Response({
                'error': 'OTP code has expired. Please request a new one.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        return Response({
            'message': 'OTP verified successfully. You can now reset your password.',
            'verified': True
        }, status=status.HTTP_200_OK)


class ResetPasswordView(generics.GenericAPIView):
    """Reset password after OTP verification."""
    permission_classes = [AllowAny]
    
    def post(self, request):
        phone_number = request.data.get('phone_number')
        email = request.data.get('email')
        otp_code = request.data.get('otp_code')
        new_password = request.data.get('new_password')
        password_confirm = request.data.get('password_confirm')
        
        if not new_password or not password_confirm:
            return Response({
                'error': 'New password and confirmation are required.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if new_password != password_confirm:
            return Response({
                'error': 'Passwords do not match.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if len(new_password) < 8:
            return Response({
                'error': 'Password must be at least 8 characters long.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            if phone_number:
                user = User.objects.get(phone_number=phone_number)
            elif email:
                user = User.objects.get(email=email)
            else:
                return Response({
                    'error': 'Phone number or email is required.'
                }, status=status.HTTP_400_BAD_REQUEST)
        except User.DoesNotExist:
            return Response({
                'error': 'User not found.'
            }, status=status.HTTP_404_NOT_FOUND)
        
        # Verify OTP
        if not otp_code or user.password_reset_code != otp_code:
            return Response({
                'error': 'Invalid or missing OTP code.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if user.password_reset_expires_at and user.password_reset_expires_at < timezone.now():
            return Response({
                'error': 'OTP code has expired. Please request a new one.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Reset password
        user.set_password(new_password)
        user.password_reset_code = ''
        user.password_reset_expires_at = None
        user.save()
        
        return Response({
            'message': 'Password reset successfully. You can now login with your new password.'
        }, status=status.HTTP_200_OK)


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
    
    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        """Approve a user (admin or vet only)."""
        user_to_approve = self.get_object()
        approver = request.user
        
        # Check if approver is admin or vet
        if not (approver.is_staff or approver.is_superuser or approver.user_type in ['admin', 'veterinarian']):
            return Response({
                'error': 'You do not have permission to approve users.'
            }, status=status.HTTP_403_FORBIDDEN)
        
        approval_notes = request.data.get('notes', '')
        
        user_to_approve.is_approved_by_admin = True
        user_to_approve.approved_by = approver
        user_to_approve.approved_at = timezone.now()
        user_to_approve.approval_notes = approval_notes
        user_to_approve.save()
        
        return Response({
            'message': f'User {user_to_approve.username} has been approved.',
            'user': UserSerializer(user_to_approve).data
        }, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        """Reject a user (admin or vet only)."""
        user_to_reject = self.get_object()
        approver = request.user
        
        # Check if approver is admin or vet
        if not (approver.is_staff or approver.is_superuser or approver.user_type in ['admin', 'veterinarian']):
            return Response({
                'error': 'You do not have permission to reject users.'
            }, status=status.HTTP_403_FORBIDDEN)
        
        rejection_notes = request.data.get('notes', '')
        
        user_to_reject.is_approved_by_admin = False
        user_to_reject.approved_by = None
        user_to_reject.approved_at = None
        user_to_reject.approval_notes = rejection_notes
        user_to_reject.save()
        
        return Response({
            'message': f'User {user_to_reject.username} has been rejected.',
            'user': UserSerializer(user_to_reject).data
        }, status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['get'])
    def pending_approval(self, request):
        """Get list of users pending approval (admin or vet only)."""
        approver = request.user
        
        # Check if approver is admin or vet
        if not (approver.is_staff or approver.is_superuser or approver.user_type in ['admin', 'veterinarian']):
            return Response({
                'error': 'You do not have permission to view pending approvals.'
            }, status=status.HTTP_403_FORBIDDEN)
        
        pending_users = User.objects.filter(
            is_verified=True,
            is_approved_by_admin=False
        ).order_by('-created_at')
        
        serializer = self.get_serializer(pending_users, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

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
