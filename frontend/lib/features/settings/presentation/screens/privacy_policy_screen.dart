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
              'Last Updated: November 2024',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Introduction',
              'AnimalGuardian ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services for livestock management and veterinary care.',
            ),
            _buildSection(
              context,
              '2. Information We Collect',
              'We collect several types of information to provide and improve our services:\n\n'
              'Personal Information:\n'
              '• Name, email address, phone number\n'
              '• Location data (sector, district, coordinates)\n'
              '• Profile pictures and account credentials\n\n'
              'Livestock Information:\n'
              '• Animal details (type, breed, age, health status)\n'
              '• Vaccination and health records\n'
              '• Case reports and medical history\n\n'
              'Usage Data:\n'
              '• App interactions and feature usage\n'
              '• Device information and operating system\n'
              '• Log files and error reports',
            ),
            _buildSection(
              context,
              '3. How We Use Your Information',
              'We use the collected information for the following purposes:\n\n'
              '• To provide veterinary services and connect farmers with veterinarians\n'
              '• To manage case reports and track livestock health\n'
              '• To send notifications about case updates, appointments, and important alerts\n'
              '• To improve our services and develop new features\n'
              '• To analyze usage patterns and optimize user experience\n'
              '• To comply with legal obligations and prevent fraud\n'
              '• To communicate with you about your account and our services',
            ),
            _buildSection(
              context,
              '4. Information Sharing and Disclosure',
              'We do not sell your personal information. We may share your information only in the following circumstances:\n\n'
              '• With veterinarians assigned to your cases (only relevant case information)\n'
              '• With sector veterinarians for case management and coordination\n'
              '• With service providers who assist in operating our platform (under strict confidentiality agreements)\n'
              '• When required by law or to protect our rights and safety\n'
              '• With your explicit consent for any other purpose',
            ),
            _buildSection(
              context,
              '5. Data Security',
              'We implement industry-standard security measures to protect your information:\n\n'
              '• Encrypted data transmission (HTTPS/TLS)\n'
              '• Secure authentication and password protection\n'
              '• Regular security audits and updates\n'
              '• Access controls and user authentication\n\n'
              'However, no method of transmission over the internet or electronic storage is 100% secure. While we strive to protect your data, we cannot guarantee absolute security.',
            ),
            _buildSection(
              context,
              '6. Data Retention',
              'We retain your personal information for as long as necessary to:\n\n'
              '• Provide our services to you\n'
              '• Comply with legal obligations\n'
              '• Resolve disputes and enforce agreements\n\n'
              'Livestock and case records are retained for historical and medical reference purposes. You may request deletion of your account and associated data at any time.',
            ),
            _buildSection(
              context,
              '7. Your Rights and Choices',
              'You have the following rights regarding your personal information:\n\n'
              '• Access: Request a copy of your personal data\n'
              '• Correction: Update or correct inaccurate information\n'
              '• Deletion: Request deletion of your account and data\n'
              '• Portability: Request transfer of your data\n'
              '• Opt-out: Unsubscribe from non-essential communications\n'
              '• Withdraw Consent: Revoke consent for data processing where applicable',
            ),
            _buildSection(
              context,
              '8. Location Data',
              'We collect location information (sector, district) to:\n\n'
              '• Connect you with local veterinarians\n'
              '• Provide location-based services and weather information\n'
              '• Assist in case management and emergency response\n\n'
              'You can control location sharing through your device settings, though some features may require location access.',
            ),
            _buildSection(
              context,
              '9. Children\'s Privacy',
              'Our services are not intended for children under 18 years of age. We do not knowingly collect personal information from children. If you believe we have collected information from a child, please contact us immediately.',
            ),
            _buildSection(
              context,
              '10. Changes to This Privacy Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any material changes by:\n\n'
              '• Posting the new Privacy Policy in the app\n'
              '• Sending you a notification\n'
              '• Updating the "Last Updated" date\n\n'
              'Your continued use of the service after changes constitutes acceptance of the updated policy.',
            ),
            _buildSection(
              context,
              '11. Contact Us',
              'If you have questions, concerns, or requests regarding this Privacy Policy or our data practices, please contact us:\n\n'
              'Email: privacy@animalguardian.com\n'
              'Phone: +250 788 123 456\n'
              'Address: AnimalGuardian Support, Kigali, Rwanda\n\n'
              'We will respond to your inquiry within 30 days.',
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
