import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/home/screens/main_screen.dart';
import 'features/onboarding/screens/splash_screen.dart';
import 'services/subscription_service.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  // Initialize Monetization Services
  try {
    await SubscriptionService().init();
    await AdService().init();
    debugPrint('✅ Monetization services initialized');
  } catch (e) {
    debugPrint('⚠️ Monetization initialization failed: $e');
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
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider);

    return session.when(
      data: (session) {
        if (session != null) {
          return const MainScreen();
        } else {
          return const AuthScreen();
        }
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}
