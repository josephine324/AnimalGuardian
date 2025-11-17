import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to welcome screen after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/welcome');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32), // Green background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AGRO Logo
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Cow icon
                  Positioned(
                    top: 20,
                    child: Icon(
                      Icons.agriculture,
                      size: 60,
                      color: Colors.brown[700],
                    ),
                  ),
                  // Leaves
                  Positioned(
                    left: 20,
                    top: 30,
                    child: Icon(
                      Icons.eco,
                      size: 30,
                      color: Colors.green[700],
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 30,
                    child: Icon(
                      Icons.eco,
                      size: 30,
                      color: Colors.green[700],
                    ),
                  ),
                  // AGRO text
                  Positioned(
                    bottom: 30,
                    child: Text(
                      'AGRO',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Get Started Button
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/welcome');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

