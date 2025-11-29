import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/api_service.dart';

class VetAvailabilityScreen extends StatefulWidget {
  const VetAvailabilityScreen({super.key});

  @override
  State<VetAvailabilityScreen> createState() => _VetAvailabilityScreenState();
}

class _VetAvailabilityScreenState extends State<VetAvailabilityScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool? _currentAvailability;

  @override
  void initState() {
    super.initState();
    _loadCurrentAvailability();
  }

  Future<void> _loadCurrentAvailability() async {
    try {
      final user = await _apiService.getCurrentUser();
      setState(() {
        _currentAvailability =
            user['veterinarian_profile']?['is_available'] ?? true;
      });
    } catch (e) {
      // Default to true if we can't load
      setState(() {
        _currentAvailability = true;
      });
    }
  }

  Future<void> _setAvailability(bool isOnline) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.toggleAvailability(isOnline);

      if (mounted) {
        setState(() {
          _currentAvailability = isOnline;
          _isLoading = false;
        });

        // Navigate to vet dashboard
        context.go('/vet-dashboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update availability: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Icon(
                Icons.medical_services,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Set Your Availability',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Choose whether you are available to receive case assignments. You can change this anytime from your profile.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Online Button
              ElevatedButton(
                onPressed: _isLoading ? null : () => _setAvailability(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Go Online',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Offline Button
              ElevatedButton(
                onPressed: _isLoading ? null : () => _setAvailability(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cancel,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Go Offline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Info text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'When online, you will receive case assignments. When offline, you will not receive new cases.',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
