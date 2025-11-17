import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last Updated: January 2024',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Acceptance of Terms',
              'By accessing and using AnimalGuardian, you accept and agree to be bound by these Terms of Service.',
            ),
            _buildSection(
              context,
              '2. Use of Service',
              'You agree to:\n\n'
              '• Use the service only for lawful purposes\n'
              '• Provide accurate and truthful information\n'
              '• Not misuse or abuse the platform\n'
              '• Respect other users and veterinarians',
            ),
            _buildSection(
              context,
              '3. User Accounts',
              'You are responsible for:\n\n'
              '• Maintaining the security of your account\n'
              '• All activities under your account\n'
              '• Keeping your information up to date',
            ),
            _buildSection(
              context,
              '4. Veterinary Services',
              'AnimalGuardian connects you with veterinarians but does not guarantee:\n\n'
              '• The availability of veterinarians\n'
              '• The quality of veterinary advice\n'
              '• Response times or outcomes',
            ),
            _buildSection(
              context,
              '5. Limitation of Liability',
              'AnimalGuardian is provided "as is" without warranties. We are not liable for any damages arising from the use of our service.',
            ),
            _buildSection(
              context,
              '6. Changes to Terms',
              'We reserve the right to modify these terms at any time. Continued use of the service constitutes acceptance of modified terms.',
            ),
            _buildSection(
              context,
              '7. Contact Information',
              'For questions about these Terms, contact us at:\n\n'
              'Email: legal@animalguardian.com\n'
              'Phone: +250 788 123 456',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

