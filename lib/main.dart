import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/style_quiz/screens/style_quiz_screen.dart';
import 'features/auth/screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint(
      'Warning: .env file not found. Please copy .env.example to .env',
    );
  }

  // Initialize Supabase (only if configured)
  final config = AppConfig();
  if (config.supabaseUrl.isNotEmpty && config.supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: config.supabaseUrl,
        anonKey: config.supabaseAnonKey,
      );
      debugPrint('✅ Supabase initialized');
    } catch (e) {
      debugPrint('⚠️ Supabase initialization failed: $e');
    }
  } else {
    debugPrint('⚠️ Supabase not configured. Running in demo mode.');
  }

  runApp(const ProviderScope(child: StyleSnapApp()));
}

class StyleSnapApp extends StatelessWidget {
  const StyleSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StyleSnap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Wait for initial auth state
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user is already authenticated
    final supabase = ref.read(supabaseServiceProvider);
    final currentUser = supabase.currentUser;

    if (currentUser != null) {
      // User is logged in, check onboarding status
      final repository = ref.read(userRepositoryProvider);
      try {
        final userProfile = await repository.getCurrentUser();

        if (userProfile != null && userProfile.onboardingCompleted) {
          // Already completed onboarding, go to home (placeholder: auth screen for now)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          );
        } else {
          // Not completed onboarding, go to quiz
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const StyleQuizScreen()),
          );
        }
      } catch (e) {
        // Error loading profile, go to onboarding
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    } else {
      // Not logged in, go to onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.checkroom_rounded,
                size: 100,
                color: AppColors.white,
              ),
              const SizedBox(height: 24),
              const Text(
                'StyleSnap',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your AI Personal Stylist',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Initializing...',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
