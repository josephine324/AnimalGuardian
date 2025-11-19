import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms & Conditions',
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
              '1. Acceptance of Terms',
              'By downloading, installing, accessing, or using the AnimalGuardian mobile application and services, you agree to be bound by these Terms and Conditions ("Terms"). If you do not agree to these Terms, please do not use our services.\n\n'
              'These Terms constitute a legally binding agreement between you and AnimalGuardian. We reserve the right to modify these Terms at any time, and your continued use constitutes acceptance of any changes.',
            ),
            _buildSection(
              context,
              '2. Description of Service',
              'AnimalGuardian is a digital livestock management platform that:\n\n'
              '• Connects farmers with veterinarians for livestock health management\n'
              '• Facilitates case reporting and tracking\n'
              '• Provides livestock record management\n'
              '• Enables communication between farmers and veterinary professionals\n'
              '• Offers community features for knowledge sharing\n\n'
              'The service is designed to support smallholder farmers in managing their livestock health and connecting with veterinary care providers.',
            ),
            _buildSection(
              context,
              '3. User Accounts and Registration',
              'To use certain features, you must register for an account. You agree to:\n\n'
              '• Provide accurate, current, and complete information during registration\n'
              '• Maintain and update your account information promptly\n'
              '• Maintain the security of your account credentials\n'
              '• Accept responsibility for all activities under your account\n'
              '• Notify us immediately of any unauthorized access\n\n'
              'Farmers: Accounts are automatically approved upon registration.\n'
              'Veterinarians: Accounts require approval from sector veterinarians before full access is granted.',
            ),
            _buildSection(
              context,
              '4. Acceptable Use',
              'You agree to use AnimalGuardian only for lawful purposes and in accordance with these Terms. You agree NOT to:\n\n'
              '• Use the service for any illegal or unauthorized purpose\n'
              '• Provide false, misleading, or fraudulent information\n'
              '• Impersonate any person or entity\n'
              '• Interfere with or disrupt the service or servers\n'
              '• Attempt to gain unauthorized access to any part of the service\n'
              '• Use automated systems to access the service without permission\n'
              '• Harass, abuse, or harm other users\n'
              '• Share inappropriate, offensive, or harmful content\n'
              '• Violate any applicable laws or regulations',
            ),
            _buildSection(
              context,
              '5. Veterinary Services Disclaimer',
              'AnimalGuardian is a platform that facilitates connections between farmers and veterinarians. Important disclaimers:\n\n'
              '• AnimalGuardian does not provide veterinary medical advice, diagnosis, or treatment\n'
              '• We do not guarantee the availability, qualifications, or quality of veterinarians\n'
              '• We are not responsible for the accuracy of information provided by veterinarians\n'
              '• Case outcomes and treatment results are not guaranteed\n'
              '• Emergency situations should be handled through direct contact with veterinary professionals\n\n'
              'All veterinary advice and treatment decisions are the sole responsibility of licensed veterinarians and the farmers who choose to follow such advice.',
            ),
            _buildSection(
              context,
              '6. Case Reporting and Management',
              'When reporting cases through AnimalGuardian:\n\n'
              '• You are responsible for providing accurate and complete information\n'
              '• Case reports are reviewed and assigned by sector veterinarians\n'
              '• Response times may vary based on urgency and veterinarian availability\n'
              '• We cannot guarantee immediate response to all cases\n'
              '• For emergency situations, contact veterinary services directly\n\n'
              'Case assignment is at the discretion of sector veterinarians based on availability, location, and case complexity.',
            ),
            _buildSection(
              context,
              '7. Intellectual Property',
              'All content, features, and functionality of AnimalGuardian, including but not limited to:\n\n'
              '• Software, code, and application design\n'
              '• Logos, trademarks, and brand names\n'
              '• Text, graphics, and user interface elements\n\n'
              'Are owned by AnimalGuardian and protected by copyright, trademark, and other intellectual property laws. You may not reproduce, distribute, or create derivative works without our express written permission.',
            ),
            _buildSection(
              context,
              '8. User Content',
              'You retain ownership of content you submit through the service (case reports, livestock information, posts, etc.). By submitting content, you grant AnimalGuardian:\n\n'
              '• A worldwide, non-exclusive, royalty-free license to use, store, and display your content\n'
              '• The right to share relevant information with assigned veterinarians\n'
              '• Permission to use anonymized data for service improvement\n\n'
              'You are responsible for ensuring you have the right to share any content you submit.',
            ),
            _buildSection(
              context,
              '9. Limitation of Liability',
              'TO THE MAXIMUM EXTENT PERMITTED BY LAW:\n\n'
              '• AnimalGuardian is provided "AS IS" and "AS AVAILABLE" without warranties\n'
              '• We do not guarantee uninterrupted, secure, or error-free service\n'
              '• We are not liable for any indirect, incidental, or consequential damages\n'
              '• Our total liability is limited to the amount you paid (if any) for the service\n'
              '• We are not responsible for decisions made based on information from the platform\n\n'
              'Some jurisdictions do not allow the exclusion of certain warranties or limitations of liability, so some of the above may not apply to you.',
            ),
            _buildSection(
              context,
              '10. Indemnification',
              'You agree to indemnify and hold harmless AnimalGuardian, its officers, directors, employees, and agents from any claims, damages, losses, liabilities, and expenses (including legal fees) arising from:\n\n'
              '• Your use of the service\n'
              '• Your violation of these Terms\n'
              '• Your violation of any rights of another party\n'
              '• Content you submit through the service',
            ),
            _buildSection(
              context,
              '11. Termination',
              'We reserve the right to:\n\n'
              '• Suspend or terminate your account at any time for violation of these Terms\n'
              '• Remove or refuse to process any content that violates our policies\n'
              '• Discontinue or modify the service at any time\n\n'
              'You may terminate your account at any time by contacting us or using account deletion features. Upon termination, your right to use the service immediately ceases.',
            ),
            _buildSection(
              context,
              '12. Privacy',
              'Your use of AnimalGuardian is also governed by our Privacy Policy. Please review our Privacy Policy to understand how we collect, use, and protect your information.',
            ),
            _buildSection(
              context,
              '13. Dispute Resolution',
              'Any disputes arising from these Terms or your use of the service shall be resolved through:\n\n'
              '• Good faith negotiation between parties\n'
              '• Mediation if negotiation fails\n'
              '• Binding arbitration in accordance with applicable laws\n\n'
              'These Terms are governed by the laws of Rwanda, without regard to conflict of law principles.',
            ),
            _buildSection(
              context,
              '14. Changes to Terms',
              'We reserve the right to modify these Terms at any time. We will notify users of material changes by:\n\n'
              '• Posting updated Terms in the application\n'
              '• Sending notifications to registered users\n'
              '• Updating the "Last Updated" date\n\n'
              'Your continued use of the service after changes constitutes acceptance of the modified Terms.',
            ),
            _buildSection(
              context,
              '15. Contact Information',
              'If you have questions about these Terms and Conditions, please contact us:\n\n'
              'Email: legal@animalguardian.com\n'
              'Phone: +250 788 123 456\n'
              'Address: AnimalGuardian Legal Department, Kigali, Rwanda\n\n'
              'We will respond to your inquiry within a reasonable timeframe.',
            ),
            _buildSection(
              context,
              '16. Severability',
              'If any provision of these Terms is found to be unenforceable or invalid, that provision shall be limited or eliminated to the minimum extent necessary, and the remaining provisions shall remain in full force and effect.',
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
