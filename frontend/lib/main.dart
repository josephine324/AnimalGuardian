import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'shared/presentation/widgets/loading_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/otp_verification_screen.dart';
import 'features/home/presentation/screens/dashboard_screen.dart';
import 'features/home/presentation/screens/vet_dashboard_screen.dart';
import 'features/cases/presentation/screens/report_case_screen.dart';
import 'features/livestock/presentation/screens/add_livestock_screen.dart';
import 'features/community/presentation/screens/create_post_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AnimalGuardianApp(),
    ),
  );
}

class AnimalGuardianApp extends StatelessWidget {
  const AnimalGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AnimalGuardian',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Green color
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      routerConfig: _router,
    );
  }
}

// Router configuration with all routes
final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash screen
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    // Onboarding
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const OnboardingScreen(),
    ),
    // Welcome/Home screen
    GoRoute(
      path: '/',
      builder: (context, state) => const _WelcomeScreen(),
    ),
    // Auth routes
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/otp-verify',
      builder: (context, state) {
        final phoneNumber = state.uri.queryParameters['phone'] ?? '+250********';
        final userType = state.uri.queryParameters['user_type'];
        return OTPVerificationScreen(phoneNumber: phoneNumber, userType: userType);
      },
    ),
    // Main dashboard with bottom navigation (Farmer)
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    // Vet dashboard with bottom navigation
    GoRoute(
      path: '/vet-dashboard',
      builder: (context, state) => const VetDashboardScreen(),
    ),
    // Feature routes
    GoRoute(
      path: '/cases/report',
      builder: (context, state) => const ReportCaseScreen(),
    ),
    GoRoute(
      path: '/livestock/add',
      builder: (context, state) => const AddLivestockScreen(),
    ),
    GoRoute(
      path: '/community/create',
      builder: (context, state) => const CreatePostScreen(),
    ),
    // Loading screen
    GoRoute(
      path: '/loading',
      builder: (context, state) => const LoadingScreen(),
    ),
  ],
);

// Welcome Screen (Landing page)
class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Digital Livestock Support System',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'For Smallholder Farmers',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/login');
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Login'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.push('/register');
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Register'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

