import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
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
              '1. Information We Collect',
              'We collect information that you provide directly to us, including:\n\n'
              '• Personal information (name, email, phone number)\n'
              '• Livestock information and case reports\n'
              '• Location data for weather and market services\n'
              '• Usage data and app interactions',
            ),
            _buildSection(
              context,
              '2. How We Use Your Information',
              'We use the information we collect to:\n\n'
              '• Provide and improve our services\n'
              '• Connect you with veterinarians\n'
              '• Send notifications and updates\n'
              '• Analyze usage patterns and improve user experience',
            ),
            _buildSection(
              context,
              '3. Data Security',
              'We implement appropriate security measures to protect your personal information. However, no method of transmission over the internet is 100% secure.',
            ),
            _buildSection(
              context,
              '4. Your Rights',
              'You have the right to:\n\n'
              '• Access your personal data\n'
              '• Correct inaccurate data\n'
              '• Request deletion of your data\n'
              '• Opt-out of certain data collection',
            ),
            _buildSection(
              context,
              '5. Contact Us',
              'If you have questions about this Privacy Policy, please contact us at:\n\n'
              'Email: privacy@animalguardian.com\n'
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

