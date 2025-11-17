import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('Email Support'),
              subtitle: const Text('support@animalguardian.com'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening email client...')),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Phone Support'),
              subtitle: const Text('+250 788 123 456'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening phone dialer...')),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.chat, color: Colors.orange),
              title: const Text('Live Chat'),
              subtitle: const Text('Available 24/7'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening live chat...')),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ExpansionTile(
            title: const Text('How do I report a case?'),
            children: const [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Go to the Cases tab and tap the + button to report a new case. Fill in the details about your livestock and symptoms.'),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('How do I add livestock?'),
            children: const [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Navigate to Livestock from the menu, then tap the + button to add a new animal. Enter the details and save.'),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('How do I contact a veterinarian?'),
            children: const [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('You can contact veterinarians through the Community tab or by reporting a case. They will be notified and can respond to your case.'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

