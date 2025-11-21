import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/widgets/placeholder_image.dart';
import '../../../../core/services/api_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _selectedUserType = 'farmer';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse name into first_name and last_name
      final nameParts = _nameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Prepare registration data
      // Backend will auto-fill password_confirm from password if not provided
      // Clean phone number (remove spaces/dashes)
      final cleanedPhone = _phoneController.text.trim().replaceAll(RegExp(r'[\s-]'), '');
      final registrationData = {
        'phone_number': cleanedPhone,
        'password': _passwordController.text,
        'user_type': _selectedUserType,
        'first_name': firstName,
        'last_name': lastName.isNotEmpty ? lastName : firstName, // Use first name as last name if not provided
      };

      // Email is optional - only include if provided
      final email = _emailController.text.trim();
      if (email.isNotEmpty) {
        registrationData['email'] = email;
      }

      // Call registration API
      final response = await _apiService.register(registrationData);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show different message based on user type
        String successMessage;
        if (_selectedUserType == 'farmer') {
          successMessage = 'Account created successfully! You can now login.';
        } else {
          successMessage = 'Registration successful! Your account is pending approval from a sector veterinarian. You will receive a notification on your phone number once approved.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
        
        // Navigate to login page after registration
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        String errorMessage = 'Registration failed. Please try again.';
        
        // Handle specific error cases
        if (e.toString().contains('TimeoutException') || e.toString().contains('timeout')) {
          errorMessage = 'Registration is taking longer than expected. Your account may have been created. Please try logging in or contact support.';
        } else if (e.toString().contains('phone_number') && e.toString().contains('already exists')) {
          errorMessage = 'An account with this phone number already exists. Please use a different phone number or try logging in.';
        } else if (e.toString().contains('email') && e.toString().contains('already exists')) {
          errorMessage = 'An account with this email address already exists. Please use a different email or try logging in.';
        } else if (e.toString().contains('username') && e.toString().contains('already exists')) {
          errorMessage = 'An account with this username already exists. Please use a different username.';
        } else if (e.toString().contains('Password must be at least 8 characters')) {
          errorMessage = 'Password must be at least 8 characters long.';
        } else if (e.toString().contains('Password must contain at least one number')) {
          errorMessage = 'Password must contain at least one number.';
        } else if (e.toString().contains('Password must contain at least one letter')) {
          errorMessage = 'Password must contain at least one letter.';
        } else if (e.toString().contains('phone_number')) {
          errorMessage = 'This phone number is already registered.';
        } else if (e.toString().contains('email')) {
          errorMessage = 'This email is already registered.';
        } else if (e.toString().contains('network') || e.toString().contains('connection')) {
          errorMessage = 'Network error. Please check your internet connection and try again.';
        } else if (e.toString().isNotEmpty) {
          errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('TimeoutException after 0:00:60.000000: Future not completed', 'Request timed out. Please try again.');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5), // Show error longer
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Image section (top half)
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                width: double.infinity,
                child: Stack(
                  children: [
                    // Farmer/cow image with placeholder
                    PlaceholderImage(
                      assetPath: 'assets/images/register_farmer.jpg',
                      placeholderIcon: Icons.pets,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    // Back button
                    Positioned(
                      top: 16,
                      left: 16,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.go('/welcome'),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Form section (bottom half)
              Container(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Join the future of livestock management',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Guidance is here. Your livestock\'s health is now in the best hands.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          hintText: 'Enter your name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '0781234567 (10 digits)',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                          helperText: 'Must start with 078, 079, 073, or 072 and be 10 digits',
                        ),
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your phone number';
                          }
                          // Remove any spaces or dashes
                          final cleaned = value.trim().replaceAll(RegExp(r'[\s-]'), '');
                          
                          // Check if it's exactly 10 digits
                          if (cleaned.length != 10) {
                            return 'Phone number must be exactly 10 digits';
                          }
                          
                          // Check if it starts with valid prefix
                          if (!cleaned.startsWith('078') && 
                              !cleaned.startsWith('079') && 
                              !cleaned.startsWith('073') && 
                              !cleaned.startsWith('072')) {
                            return 'Phone number must start with 078, 079, 073, or 072';
                          }
                          
                          // Check if all characters are digits
                          if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
                            return 'Phone number must contain only digits';
                          }
                          
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email (Optional)',
                          hintText: 'Enter your email (optional)',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                          helperText: 'Email is optional. Phone number is required.',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          // Email is optional, but if provided, validate format
                          if (value != null && value.trim().isNotEmpty) {
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Please enter a valid email address';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedUserType,
                        decoration: const InputDecoration(
                          labelText: 'User Type',
                          prefixIcon: Icon(Icons.account_circle),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'farmer', child: Text('Farmer')),
                          DropdownMenuItem(value: 'local_vet', child: Text('Local Veterinarian')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedUserType = value;
                          });
                        },
                      ),
                        const SizedBox(height: 8),
                        if (_selectedUserType == 'local_vet')
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Your registration will require approval from a Sector Veterinarian via the web dashboard. You will receive an email once approved.',
                                    style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_selectedUserType == 'farmer')
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline, color: Colors.green[700], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Farmers can login immediately after registration. No approval needed!',
                                    style: TextStyle(
                                      color: Colors.green[900],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password (min. 8 characters)',
                          prefixIcon: const Icon(Icons.lock),
                          helperText: 'Password must be at least 8 characters and contain both letters and numbers',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          }
                          // Check if password contains at least one letter
                          if (!value.contains(RegExp(r'[a-zA-Z]'))) {
                            return 'Password must contain at least one letter';
                          }
                          // Check if password contains at least one number
                          if (!value.contains(RegExp(r'[0-9]'))) {
                            return 'Password must contain at least one number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: TextEditingController(), // Address field
                        decoration: const InputDecoration(
                          labelText: 'Address/Location',
                          hintText: 'Enter your address',
                          prefixIcon: Icon(Icons.location_on),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

