import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

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

                        // Continue Button
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implement phone auth
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
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
                        _buildSocialButton(
                          'Continue with Apple',
                          Icons.apple,
                          AppColors.black,
                          () {
                            // TODO: Implement Apple Sign In
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildSocialButton(
                          'Continue with Google',
                          Icons.g_mobiledata,
                          const Color(0xFFDB4437),
                          () {
                            // TODO: Implement Google Sign In
                          },
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
    VoidCallback onTap,
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
