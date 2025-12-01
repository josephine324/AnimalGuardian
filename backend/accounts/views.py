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
import threading
from django.conf import settings
from .models import User, VeterinarianProfile, FarmerProfile, OTPVerification
from .serializers import UserSerializer, VeterinarianProfileSerializer, FarmerProfileSerializer

logger = logging.getLogger(__name__)

class RegisterView(generics.CreateAPIView):
    """Register a new user."""
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [AllowAny]
    
    def create(self, request, *args, **kwargs):
        # Check for duplicate accounts before attempting to create
        phone_number = request.data.get('phone_number')
        email = request.data.get('email')
        
        if phone_number:
            # Clean phone number (remove spaces, dashes, etc.) for duplicate check
            import re
            cleaned_phone = re.sub(r'[^\d]', '', str(phone_number))
            
            # Check for duplicates with cleaned phone number
            if User.objects.filter(phone_number=cleaned_phone).exists():
                return Response({
                    'error': 'An account with this phone number already exists. Please use a different phone number or try logging in.',
                    'phone_number': ['An account with this phone number already exists.']
                }, status=status.HTTP_400_BAD_REQUEST)
        
        # Only check for duplicate email if email is provided and not empty
        # Handle both None and empty string cases
        # Skip email check entirely if email is not in request data or is empty
        request_data = request.data.copy()
        if 'email' in request_data:
            email_value = request_data.get('email')
            if email_value is not None:
                cleaned_email = str(email_value).strip() if email_value else ''
                if cleaned_email:  # Only check if email is not empty after stripping
                    if User.objects.filter(email=cleaned_email).exists():
                        return Response({
                            'error': 'An account with this email address already exists. Please use a different email or try logging in.',
                            'email': ['An account with this email address already exists.']
                        }, status=status.HTTP_400_BAD_REQUEST)
                else:
                    # Remove empty email from request data - set to None explicitly
                    # This prevents empty string from being passed to serializer
                    request_data['email'] = None
        else:
            # If email is not in request, explicitly set to None
            request_data['email'] = None
        
        serializer = self.get_serializer(data=request_data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        # Auto-verify users (no email verification needed)
        user.is_verified = True
        
        # Auto-approve farmers and sector vets - they can login immediately
        # Local vets still need approval from sector vet
        if user.user_type in ['farmer', 'sector_vet', 'admin']:
            user.is_approved_by_admin = True
            user.save()
            return Response({
                'message': 'Account created successfully! You can now login.',
                'user_id': user.id
            }, status=status.HTTP_201_CREATED)
        else:
            # Local vets need approval
            user.save()
            return Response({
                'message': 'User created successfully. Your account is pending approval from a sector veterinarian. You will receive a notification on your phone number once approved.',
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
                    # Clean phone number (remove spaces, dashes, etc.) for authentication
                    import re
                    cleaned_phone = re.sub(r'[^\d]', '', str(phone_number))
                    logger.info(f'Login attempt with phone: {phone_number} (cleaned: {cleaned_phone})')
                    user = authenticate(username=cleaned_phone, password=password)
                    if not user:
                        # If authenticate fails, try to find user and check password directly
                        user_obj = User.objects.filter(phone_number=cleaned_phone).first()
                        if user_obj and user_obj.check_password(password):
                            logger.info(f'Password check passed for phone: {cleaned_phone}, using user object directly')
                            user = user_obj
                except Exception as e:
                    logger.error(f'Error authenticating with phone number: {str(e)}', exc_info=True)
            elif email:
                try:
                    # Use filter().first() to avoid MultipleObjectsReturned exception
                    # Load full user object for proper password checking
                    user_obj = User.objects.filter(email=email).first()
                    if user_obj:
                        logger.info(f'Login attempt for email: {email}, found user: {user_obj.id}, phone: {user_obj.phone_number}, active: {user_obj.is_active}')
                        if user_obj.phone_number:
                            # Try authenticate first (standard Django way)
                            user = authenticate(username=user_obj.phone_number, password=password)
                            if not user:
                                # If authenticate fails, check password directly
                                # This handles cases where authenticate() might fail due to backend issues
                                if user_obj.check_password(password):
                                    logger.info(f'Password check passed for email: {email}, using user object directly')
                                    user = user_obj
                                else:
                                    logger.warning(f'Authentication failed for email: {email}, phone: {user_obj.phone_number} - password incorrect')
                        else:
                            logger.warning(f'User with email {email} found but has no phone_number set')
                    else:
                        logger.warning(f'No user found with email: {email}')
                except Exception as e:
                    logger.error(f'Error during email authentication: {str(e)}', exc_info=True)
            
            if user:
                # Only local vets need approval from sector vet/admin
                # Farmers can login immediately after registration
                if user.user_type == 'local_vet' and not user.is_approved_by_admin:
                    return Response({
                        'error': 'Your account is pending approval from a sector veterinarian. Please wait for approval before logging in. You will receive an email once approved.',
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
    """Verify OTP for phone number or email."""
    permission_classes = [AllowAny]
    
    def post(self, request):
        phone_number = request.data.get('phone_number')
        email = request.data.get('email')
        otp_code = request.data.get('otp_code')
        
        if not otp_code:
            return Response({
                'error': 'OTP code is required.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Get user by phone_number or email
        try:
            if email:
                user = User.objects.get(email=email)
            elif phone_number:
                user = User.objects.get(phone_number=phone_number)
            else:
                return Response({
                    'error': 'Phone number or email is required.'
                }, status=status.HTTP_400_BAD_REQUEST)
        except User.DoesNotExist:
            return Response({
                'error': 'User not found.'
            }, status=status.HTTP_404_NOT_FOUND)
        
        # Check OTP from OTPVerification model
        # For farmers and local vets, OTP is sent via email, but stored with phone_number or email
        try:
            # Try to find OTP by phone_number first, then by email (if phone_number is actually email)
            otp_verification = OTPVerification.objects.filter(
                phone_number=user.phone_number,
                otp_code=otp_code,
                is_used=False
            ).order_by('-created_at').first()
            
            # If not found and user has email, try searching by email (in case phone_number field contains email)
            if not otp_verification and user.email:
                otp_verification = OTPVerification.objects.filter(
                    phone_number=user.email,
                    otp_code=otp_code,
                    is_used=False
                ).order_by('-created_at').first()
            
            # Also accept hardcoded OTP for development
            if otp_code == '123456' or (otp_verification and otp_verification.expires_at > timezone.now()):
                user.is_verified = True
                user.save()
                
                # Mark OTP as used if it exists
                if otp_verification:
                    otp_verification.is_used = True
                    otp_verification.save()
                
                # Generate tokens for automatic login
                try:
                    refresh = RefreshToken.for_user(user)
                    user_data = UserSerializer(user).data
                    
                    return Response({
                        'message': 'Verification successful.',
                        'access': str(refresh.access_token),
                        'refresh': str(refresh),
                        'user': user_data
                    })
                except Exception as e:
                    logger.error(f'Error generating tokens: {str(e)}', exc_info=True)
                return Response({
                        'message': 'Verification successful. Please login.'
                })
            else:
                return Response({
                    'error': 'Invalid or expired OTP code.'
                }, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            logger.error(f'Error verifying OTP: {str(e)}', exc_info=True)
            return Response({
                'error': 'An error occurred during verification.'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

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
                # Clean phone number (remove +, spaces, etc.) for lookup
                import re
                cleaned_phone = re.sub(r'[^\d]', '', str(phone_number))
                # Remove country code if present (250 for Rwanda)
                if cleaned_phone.startswith('250'):
                    cleaned_phone = cleaned_phone[3:]
                # Ensure it starts with 0 if it's a local number
                if not cleaned_phone.startswith('0') and len(cleaned_phone) == 9:
                    cleaned_phone = '0' + cleaned_phone
                # Try to find user with cleaned phone number
                user = User.objects.get(phone_number=cleaned_phone)
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
                # Always send password reset code to email if user has email
                # This ensures notifications are sent via email
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
                else:
                    # If user has no email, log a warning
                    logger.warning(f'User {user.id} ({phone_number}) has no email address. Cannot send password reset code.')
                    # Still return success for security (don't reveal if user exists)
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
                # Clean phone number (remove +, spaces, etc.) for lookup
                import re
                cleaned_phone = re.sub(r'[^\d]', '', str(phone_number))
                # Remove country code if present (250 for Rwanda)
                if cleaned_phone.startswith('250'):
                    cleaned_phone = cleaned_phone[3:]
                # Ensure it starts with 0 if it's a local number
                if not cleaned_phone.startswith('0') and len(cleaned_phone) == 9:
                    cleaned_phone = '0' + cleaned_phone
                # Try to find user with cleaned phone number
                user = User.objects.get(phone_number=cleaned_phone)
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
                # Clean phone number (remove +, spaces, etc.) for lookup
                import re
                cleaned_phone = re.sub(r'[^\d]', '', str(phone_number))
                # Remove country code if present (250 for Rwanda)
                if cleaned_phone.startswith('250'):
                    cleaned_phone = cleaned_phone[3:]
                # Ensure it starts with 0 if it's a local number
                if not cleaned_phone.startswith('0') and len(cleaned_phone) == 9:
                    cleaned_phone = '0' + cleaned_phone
                # Try to find user with cleaned phone number
                user = User.objects.get(phone_number=cleaned_phone)
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
        
        # Send confirmation email after successful password reset
        from django.core.mail import send_mail
        try:
            if user.email:
                subject = 'AnimalGuardian - Password Reset Successful'
                message = f'''
Hello {user.get_full_name() or user.username},

Your password has been successfully reset for your AnimalGuardian account.

If you did not make this change, please contact support immediately.

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
            # Log the error but don't fail the password reset
            logger.error(f'Error sending password reset confirmation email: {str(e)}')
        
        return Response({
            'message': 'Password reset successfully. You can now login with your new password.'
        }, status=status.HTTP_200_OK)


class ChangePasswordView(generics.GenericAPIView):
    """Change password for authenticated user."""
    permission_classes = [IsAuthenticated]
    
    def post(self, request):
        current_password = request.data.get('current_password')
        new_password = request.data.get('new_password')
        password_confirm = request.data.get('password_confirm')
        
        if not all([current_password, new_password]):
            return Response({
                'error': 'Current password and new password are required.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if password_confirm and new_password != password_confirm:
            return Response({
                'error': 'New password and confirmation do not match.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        user = request.user
        
        # Verify current password
        if not user.check_password(current_password):
            return Response({
                'error': 'Current password is incorrect.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Validate new password
        try:
            from django.contrib.auth.password_validation import validate_password
            validate_password(new_password, user)
        except Exception as e:
            return Response({
                'error': str(e)
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Set new password
        user.set_password(new_password)
        user.save()
        
        return Response({
            'message': 'Password changed successfully.'
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
        
        # Send approval email to user
        def send_approval_email():
            """Send approval email in background thread."""
            try:
                from django.core.mail import send_mail
                user_type_name = 'Local Veterinarian' if user_to_approve.user_type == 'local_vet' else 'Farmer'
                subject = 'AnimalGuardian - Account Approved'
                message = f'''
Hello {user_to_approve.get_full_name() or user_to_approve.username},

Great news! Your {user_type_name} account on AnimalGuardian has been approved by a Sector Veterinarian.

You can now log in to the AnimalGuardian mobile app and start using all the features.

Login with your registered email/phone number and password.

Best regards,
AnimalGuardian Team
'''
                if user_to_approve.email:
                    send_mail(
                        subject=subject,
                        message=message,
                        from_email=settings.DEFAULT_FROM_EMAIL,
                        recipient_list=[user_to_approve.email],
                        fail_silently=True,  # Don't fail the request if email fails
                    )
                    logger.info(f'Approval email sent to {user_to_approve.email} for user {user_to_approve.id} (type: {user_to_approve.user_type})')
            except Exception as e:
                logger.error(f'Error sending approval email: {str(e)}', exc_info=True)
        
        # Send approval email in background thread
        if user_to_approve.email:
            email_thread = threading.Thread(target=send_approval_email)
            email_thread.daemon = True
            email_thread.start()
            logger.info(f'Approval email sending initiated for {user_to_approve.email} (user {user_to_approve.id})')
        
        return Response({
            'message': f'User {user_to_approve.username} has been approved. Approval email sent.',
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
            is_approved_by_admin=False,
            user_type__in=['farmer', 'local_vet']
        ).order_by('-created_at')
        
        serializer = self.get_serializer(pending_users, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

class FarmerViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for Farmer users (returns users with farmer profiles)."""
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Return users who are farmers, optionally filtered by approval status."""
        # Use select_related for any ForeignKey relationships if needed
        # For now, User model doesn't have ForeignKeys in this context, but keep optimized
        queryset = User.objects.filter(user_type='farmer').select_related('approved_by')
        
        # Filter by approval status if provided in query params
        is_approved = self.request.query_params.get('is_approved_by_admin')
        if is_approved is not None:
            # Convert string to boolean
            is_approved_bool = is_approved.lower() in ('true', '1', 'yes')
            queryset = queryset.filter(is_approved_by_admin=is_approved_bool)
        
        return queryset.order_by('-created_at')
    
    def list(self, request, *args, **kwargs):
        """List all farmers with their profiles."""
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)
    
    def retrieve(self, request, *args, **kwargs):
        """Retrieve a specific farmer."""
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def profile(self, request):
        """Get current user's farmer profile."""
        try:
            profile = request.user.farmer_profile
            serializer = FarmerProfileSerializer(profile)
            return Response(serializer.data)
        except FarmerProfile.DoesNotExist:
            return Response({
                'error': 'Farmer profile not found.'
            }, status=status.HTTP_404_NOT_FOUND)

class VeterinarianViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for Veterinarian users (returns users with vet profiles)."""
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Return users who are local veterinarians only.
        Sector vets should NOT appear in this list - they only access the dashboard.
        Local vets can be shown regardless of approval status so sector vets can approve them.
        """
        # Use select_related for approved_by relationship
        # Only return local_vet users - sector vets are not shown here
        queryset = User.objects.filter(
            user_type='local_vet'
        ).select_related('approved_by')
        
        return queryset.order_by('-created_at')
    
    def list(self, request, *args, **kwargs):
        """List all veterinarians with their profiles."""
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)
    
    def retrieve(self, request, *args, **kwargs):
        """Retrieve a specific veterinarian."""
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def profile(self, request):
        """Get current user's veterinarian profile."""
        try:
            profile = request.user.vet_profile
            serializer = VeterinarianProfileSerializer(profile)
            return Response(serializer.data)
        except VeterinarianProfile.DoesNotExist:
            return Response({
                'error': 'Veterinarian profile not found.'
            }, status=status.HTTP_404_NOT_FOUND)
    
    @action(detail=False, methods=['post'])
    def create_missing_profiles(self, request):
        """Create VeterinarianProfile for all veterinarians that don't have one (admin only)."""
        if not (request.user.is_staff or request.user.is_superuser or request.user.user_type == 'admin'):
            return Response({
                'error': 'Only administrators can create missing profiles.'
            }, status=status.HTTP_403_FORBIDDEN)
        
        import secrets
        vets = User.objects.filter(user_type__in=['local_vet', 'sector_vet'])
        created_count = 0
        skipped_count = 0
        
        for vet in vets:
            try:
                # Check if profile already exists
                if hasattr(vet, 'vet_profile'):
                    skipped_count += 1
                    continue
                
                # Generate a unique license number
                license_number = f'VET-{vet.id}-{secrets.token_hex(4).upper()}'
                while VeterinarianProfile.objects.filter(license_number=license_number).exists():
                    license_number = f'VET-{vet.id}-{secrets.token_hex(4).upper()}'
                
                # Create profile
                VeterinarianProfile.objects.create(
                    user=vet,
                    license_number=license_number,
                    license_type='licensed',
                    specialization='General Practice',
                    is_available=True
                )
                created_count += 1
            except Exception as e:
                logger.error(f'Error creating profile for {vet.email}: {str(e)}', exc_info=True)
        
        return Response({
            'message': f'Created {created_count} profiles, skipped {skipped_count} existing profiles.',
            'created': created_count,
            'skipped': skipped_count,
            'total': vets.count()
        }, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['post'])
    def toggle_availability(self, request, pk=None):
        """Toggle online/offline status for local veterinarians."""
        user = self.get_object()  # Get the user, not the profile
        requesting_user = request.user
        
        # Only the veterinarian themselves can toggle their availability
        if user != requesting_user:
            return Response({
                'error': 'You can only change your own availability status.'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Only veterinarians (local_vet or sector_vet) can toggle availability
        if requesting_user.user_type not in ['local_vet', 'sector_vet']:
            return Response({
                'error': 'Only veterinarians can toggle their availability status.'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Get or create veterinarian profile
        try:
            profile = user.vet_profile
        except VeterinarianProfile.DoesNotExist:
            # Create a basic profile if it doesn't exist
            profile = VeterinarianProfile.objects.create(
                user=user,
                license_number=f'VET-{user.id}',
                license_type='licensed',
                is_available=False  # Start as offline - vet must set themselves to online via app
            )
        
        # Store old availability status
        old_availability = profile.is_available
        
        # Toggle availability
        profile.is_available = not profile.is_available
        profile.save()
        
        # CRITICAL: Always ensure the user account stays active - NEVER deactivate
        # Offline status (is_available=False) should ONLY affect:
        # - Visibility in sector vet's available vets list
        # - Ability to receive NEW case assignments
        # It should NOT affect:
        # - Login capability (is_active must always be True)
        # - Access to existing cases
        # - Normal app functionality
        user.is_active = True  # Always keep account active
        user.save(update_fields=['is_active'])
        
        # Send notification to sector veterinarians when local vet goes online
        if user.user_type == 'local_vet' and not old_availability and profile.is_available:
            self._notify_sector_vets_local_vet_online(user, profile)
        
        return Response({
            'message': f'You are now {"online" if profile.is_available else "offline"}',
            'is_available': profile.is_available,
            'user': UserSerializer(user).data
        }, status=status.HTTP_200_OK)
    
    def _notify_sector_vets_local_vet_online(self, local_vet, profile):
        """Notify sector veterinarians when a local veterinarian goes online."""
        from notifications.models import Notification
        from django.core.mail import send_mail
        from django.conf import settings
        from django.db.models import Q
        import threading
        
        # Get all sector veterinarians and admins
        from django.db.models import Q
        sector_vets = User.objects.filter(
            (Q(user_type__in=['sector_vet', 'admin']) & Q(is_approved_by_admin=True)) |
            (Q(is_staff=True) & Q(is_superuser=False))
        ).distinct()
        
        vet_name = local_vet.get_full_name() or local_vet.username
        vet_location = f"{local_vet.district or 'Unknown District'}"
        if local_vet.sector:
            vet_location += f", {local_vet.sector}"
        
        # Send in-app notifications to all sector vets
        notifications = []
        for sector_vet in sector_vets:
            notification = Notification(
                recipient=sector_vet,
                channel='in_app',
                title='Local Veterinarian Online',
                message=f'{vet_name} ({local_vet.phone_number}) is now online. Location: {vet_location}',
                status='sent',
                sent_at=timezone.now()
            )
            notifications.append(notification)
        
        # Bulk create notifications
        if notifications:
            Notification.objects.bulk_create(notifications)
        
        # Send email notifications (in background thread)
        def send_email_notifications():
            for sector_vet in sector_vets:
                try:
                    if sector_vet.email:
                        subject = 'AnimalGuardian - Local Veterinarian Online'
                        message = f'''
Hello {sector_vet.get_full_name() or sector_vet.username},

A local veterinarian in your area is now online and available for case assignments.

Veterinarian Details:
- Name: {vet_name}
- Phone: {local_vet.phone_number}
- Location: {vet_location}
- License: {profile.license_number}

You can now assign cases to this veterinarian through the web dashboard.

Best regards,
AnimalGuardian Team
'''
                        send_mail(
                            subject=subject,
                            message=message,
                            from_email=settings.DEFAULT_FROM_EMAIL,
                            recipient_list=[sector_vet.email],
                            fail_silently=True,
                        )
                        logger.info(f'Local vet online notification email sent to sector vet {sector_vet.email}')
                except Exception as e:
                    logger.error(f'Error sending local vet online notification email to {sector_vet.email}: {str(e)}', exc_info=True)
        
        # Send emails in background thread
        email_thread = threading.Thread(target=send_email_notifications)
        email_thread.daemon = True
        email_thread.start()
