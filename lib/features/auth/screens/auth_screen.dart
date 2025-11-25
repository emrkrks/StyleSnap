import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';
import 'phone_otp_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => AuthScreenState();
}

class AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    // Send OTP
    ref.read(authControllerProvider.notifier).signInWithPhone(phone);

    // Navigate to OTP screen
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PhoneOTPScreen(phoneNumber: phone)),
    );
  }

  // TODO: Uncomment when Apple Developer account is configured
  // void _handleAppleSignIn() {
  //   ref
  //       .read(authControllerProvider.notifier)
  //       .signInWithOAuth(OAuthProvider.apple);
  // }

  void _handleGoogleSignIn() {
    ref
        .read(authControllerProvider.notifier)
        .signInWithOAuth(OAuthProvider.google);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  const Icon(
                    Icons.checkroom_rounded,
                    size: 80,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'StyleSnap',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your AI Personal Stylist',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Auth Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tab Selector
                        Row(
                          children: [
                            Expanded(
                              child: _buildTabButton(
                                'Sign In',
                                _isLogin,
                                () => setState(() => _isLogin = true),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTabButton(
                                'Sign Up',
                                !_isLogin,
                                () => setState(() => _isLogin = false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Phone Number Input
                        TextField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            hintText: '+90 5XX XXX XX XX',
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),

                        // Error Message
                        if (authState.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              authState.error!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Continue Button
                        ElevatedButton(
                          onPressed: authState.isLoading
                              ? null
                              : _handleContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: AppColors.grey300)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: AppColors.grey500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: AppColors.grey300)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Social Login Buttons
                        // TODO: Enable Apple Sign-In after configuring Apple Developer account
                        // _buildSocialButton(
                        //   'Continue with Apple',
                        //   Icons.apple,
                        //   AppColors.black,
                        //   authState.isLoading ? null : _handleAppleSignIn,
                        // ),
                        // const SizedBox(height: 12),
                        _buildSocialButton(
                          'Continue with Google',
                          Icons.g_mobiledata,
                          const Color(0xFFDB4437),
                          authState.isLoading ? null : _handleGoogleSignIn,
                        ),
                        const SizedBox(height: 24),

                        // Terms
                        Text(
                          'By continuing, you agree to our Terms of Service and Privacy Policy',
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.white : AppColors.grey600,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color),
      label: Text(text, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: AppColors.grey300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
