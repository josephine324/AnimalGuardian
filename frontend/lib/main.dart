import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'shared/presentation/widgets/loading_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/otp_verification_screen.dart';
import 'features/auth/presentation/screens/vet_availability_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/verify_password_reset_otp_screen.dart';
import 'features/auth/presentation/screens/reset_password_screen.dart';
import 'features/home/presentation/screens/dashboard_screen.dart';
import 'features/home/presentation/screens/vet_dashboard_screen.dart';
import 'features/cases/presentation/screens/report_case_screen.dart';
import 'features/livestock/presentation/screens/add_livestock_screen.dart';
import 'features/community/presentation/screens/create_post_screen.dart';
import 'core/models/case_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file (if it exists)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env file not found, use default values from AppConstants
    debugPrint('Warning: .env file not found, using default API URL');
  }
  
  runApp(
    // Wrap in MediaQuery with safe text scaler to prevent assertion errors
    MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.0)),
      child: const ProviderScope(
        child: AnimalGuardianApp(),
      ),
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
        // Ensure text theme uses valid font sizes
        // Text theme will use default, but textScaler in MediaQuery ensures valid scaling
      ),
      builder: (BuildContext context, Widget? child) {
        // Force valid text scaler to prevent assertion errors
        // This fixes text_scaler.dart:87:12 assertion failures
        final mediaQuery = MediaQuery.maybeOf(context);
        final safeMediaQuery = mediaQuery?.copyWith(
          textScaler: const TextScaler.linear(1.0),
        ) ?? const MediaQueryData(textScaler: TextScaler.linear(1.0));
        
        return MediaQuery(
          data: safeMediaQuery,
          child: child ?? const SizedBox.shrink(),
        );
      },
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
        final phoneNumber = state.uri.queryParameters['phone'];
        final email = state.uri.queryParameters['email'];
        final userType = state.uri.queryParameters['user_type'];
        return OTPVerificationScreen(
          phoneNumber: phoneNumber ?? '',
          email: email,
          userType: userType,
        );
      },
    ),
    // Forgot Password routes
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/forgot-password/verify',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final emailOrPhone = extra?['emailOrPhone'] as String? ?? '';
        return VerifyPasswordResetOTPScreen(emailOrPhone: emailOrPhone);
      },
    ),
    GoRoute(
      path: '/forgot-password/reset',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final emailOrPhone = extra?['emailOrPhone'] as String? ?? '';
        final otpCode = extra?['otpCode'] as String? ?? '';
        return ResetPasswordScreen(
          emailOrPhone: emailOrPhone,
          otpCode: otpCode,
        );
      },
    ),
    // Main dashboard with bottom navigation (Farmer)
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    // Vet availability screen (shown after login)
    GoRoute(
      path: '/vet-availability',
      builder: (context, state) => const VetAvailabilityScreen(),
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
      path: '/cases/edit',
      builder: (context, state) {
        final caseReport = state.extra as CaseReport?;
        return ReportCaseScreen(editCase: caseReport);
      },
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

