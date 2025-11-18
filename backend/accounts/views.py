from rest_framework import generics, viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from django.utils import timezone
from datetime import timedelta
import random
import logging
import traceback
from django.conf import settings
from .models import User, VeterinarianProfile, FarmerProfile
from .serializers import UserSerializer, VeterinarianProfileSerializer, FarmerProfileSerializer

logger = logging.getLogger(__name__)

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
        try:
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
                try:
                    user = authenticate(username=phone_number, password=password)
                except Exception as e:
                    logger.error(f'Error authenticating with phone number: {str(e)}', exc_info=True)
            elif email:
                try:
                    # Use filter().first() to avoid MultipleObjectsReturned exception
                    user_obj = User.objects.filter(email=email).first()
                    if user_obj:
                        logger.info(f'Login attempt for email: {email}, found user: {user_obj.id}, phone: {user_obj.phone_number}, active: {user_obj.is_active}')
                        if user_obj.phone_number:
                            user = authenticate(username=user_obj.phone_number, password=password)
                            if not user:
                                logger.warning(f'Authentication failed for email: {email}, phone: {user_obj.phone_number}')
                                # Check if password is correct but authentication still failed
                                if user_obj.check_password(password):
                                    logger.warning(f'Password check passed but authenticate() returned None for user: {user_obj.id}')
                        else:
                            logger.warning(f'User with email {email} found but has no phone_number set')
                    else:
                        logger.warning(f'No user found with email: {email}')
                except Exception as e:
                    logger.error(f'Error during email authentication: {str(e)}', exc_info=True)
            
            if user:
                # Check if user is verified (phone verification) - only for farmers
                if user.user_type == 'farmer' and not user.is_verified:
                    return Response({
                        'error': 'Your phone number is not verified. Please verify your phone number first.'
                    }, status=status.HTTP_403_FORBIDDEN)
                
                # Check if farmer is approved by sector vet/admin (only farmers need approval)
                if user.user_type == 'farmer' and not user.is_approved_by_admin:
                    return Response({
                        'error': 'Your account is pending approval from a sector veterinarian. Please wait for approval before logging in.',
                        'pending_approval': True
                    }, status=status.HTTP_403_FORBIDDEN)
                
                # Check if user is active
                if not user.is_active:
                    return Response({
                        'error': 'Your account has been deactivated. Please contact support.'
                    }, status=status.HTTP_403_FORBIDDEN)
                
                try:
                    refresh = RefreshToken.for_user(user)
                except Exception as e:
                    logger.error(f'Error generating refresh token: {str(e)}', exc_info=True)
                    return Response({
                        'error': 'An error occurred during authentication. Please try again.'
                    }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                
                # Determine redirect based on user type
                redirect_to = 'admin_dashboard'
                if user.user_type in ['local_vet', 'sector_vet']:
                    redirect_to = 'vet_dashboard'
                elif user.user_type == 'farmer':
                    redirect_to = 'farmer_dashboard'
                
                try:
                    user_data = UserSerializer(user).data
                except Exception as e:
                    logger.error(f'Error serializing user data: {str(e)}', exc_info=True)
                    return Response({
                        'error': 'An error occurred while processing your request. Please try again.'
                    }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                
                return Response({
                    'access': str(refresh.access_token),
                    'refresh': str(refresh),
                    'user': user_data,
                    'redirect_to': redirect_to
                })
            else:
                return Response({
                    'error': 'Invalid credentials.'
                }, status=status.HTTP_401_UNAUTHORIZED)
        except Exception as e:
            # Catch any unexpected errors and return a proper error response
            error_traceback = traceback.format_exc()
            logger.error(f'Unexpected error in LoginView: {str(e)}\n{error_traceback}')
            
            # In DEBUG mode, include more details
            error_message = 'An unexpected error occurred. Please try again later.'
            if settings.DEBUG:
                error_message = f'Error: {str(e)}'
            
            return Response({
                'error': error_message
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

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
        user.password_reset_token = otp_code
        user.password_reset_expires_at = timezone.now() + timedelta(minutes=15)
        user.save()
        
        # Send OTP via Email or SMS
        from django.core.mail import send_mail
        
        try:
            if email:
                # Send email with OTP code
                subject = 'AnimalGuardian - Password Reset Code'
                message = f'''
Hello {user.get_full_name() or user.username},

You have requested to reset your password for your AnimalGuardian account.

Your password reset code is: {otp_code}

This code will expire in 15 minutes.

If you did not request this password reset, please ignore this email.

Best regards,
AnimalGuardian Team
'''
                send_mail(
                    subject=subject,
                    message=message,
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    recipient_list=[user.email],
                    fail_silently=False,
                )
            elif phone_number:
                # Send SMS via Africa's Talking (if configured)
                # TODO: Implement SMS sending using Africa's Talking API
                # For now, email will be used if available
                if user.email:
                    subject = 'AnimalGuardian - Password Reset Code'
                    message = f'''
Hello {user.get_full_name() or user.username},

You have requested to reset your password using phone number {phone_number}.

Your password reset code is: {otp_code}

This code will expire in 15 minutes.

If you did not request this password reset, please ignore this message.

Best regards,
AnimalGuardian Team
'''
                    send_mail(
                        subject=subject,
                        message=message,
                        from_email=settings.DEFAULT_FROM_EMAIL,
                        recipient_list=[user.email],
                        fail_silently=False,
                    )
        except Exception as e:
            # Log the error but don't expose it to user for security
            logger.error(f'Error sending password reset email/SMS: {str(e)}')
            # Still return success message for security (don't reveal if email failed)
        
        return Response({
            'message': 'Password reset code sent. Please check your email or phone for the 6-digit code.'
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
        if user.password_reset_token != otp_code:
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
        if not otp_code or user.password_reset_token != otp_code:
            return Response({
                'error': 'Invalid or missing OTP code.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if user.password_reset_expires_at and user.password_reset_expires_at < timezone.now():
            return Response({
                'error': 'OTP code has expired. Please request a new one.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Reset password
        user.set_password(new_password)
        user.password_reset_token = ''
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
        
        # Check if approver is admin or sector vet (only sector vets can approve)
        if not (approver.is_staff or approver.is_superuser or approver.user_type in ['admin', 'sector_vet']):
            return Response({
                'error': 'You do not have permission to approve users. Only administrators and sector veterinarians can approve users.'
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
        """Reject a user (admin or sector vet only)."""
        user_to_reject = self.get_object()
        approver = request.user
        
        # Check if approver is admin or sector vet (only sector vets can reject)
        if not (approver.is_staff or approver.is_superuser or approver.user_type in ['admin', 'sector_vet']):
            return Response({
                'error': 'You do not have permission to reject users. Only administrators and sector veterinarians can reject users.'
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
        """Get list of users pending approval (admin or sector vet only)."""
        approver = request.user
        
        # Check if approver is admin or sector vet (only sector vets can view pending approvals)
        if not (approver.is_staff or approver.is_superuser or approver.user_type in ['admin', 'sector_vet']):
            return Response({
                'error': 'You do not have permission to view pending approvals. Only administrators and sector veterinarians can view pending approvals.'
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
    
    @action(detail=True, methods=['post'])
    def toggle_availability(self, request, pk=None):
        """Toggle online/offline status for local veterinarians."""
        profile = self.get_object()
        user = request.user
        
        # Only the veterinarian themselves can toggle their availability
        if profile.user != user:
            return Response({
                'error': 'You can only change your own availability status.'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Only local vets can toggle availability
        if user.user_type != 'local_vet':
            return Response({
                'error': 'Only local veterinarians can toggle their availability status.'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Toggle availability
        profile.is_available = not profile.is_available
        profile.save()
        
        # Update user active status to match
        user.is_active = profile.is_available
        user.save(update_fields=['is_active'])
        
        return Response({
            'message': f'You are now {"online" if profile.is_available else "offline"}',
            'is_available': profile.is_available,
            'profile': self.get_serializer(profile).data
        }, status=status.HTTP_200_OK)
