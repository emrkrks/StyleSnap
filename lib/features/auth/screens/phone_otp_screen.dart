import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';
import '../../style_quiz/screens/style_quiz_screen.dart';

class PhoneOTPScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const PhoneOTPScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<PhoneOTPScreen> createState() => _PhoneOTPScreenState();
}

class _PhoneOTPScreenState extends ConsumerState<PhoneOTPScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    // Listen for auth changes
    ref.listenManual(authControllerProvider, (previous, next) {
      if (next.user != null && mounted) {
        // Successfully authenticated, navigate to style quiz
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StyleQuizScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOTPChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    // Check if all fields are filled
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _verifyOTP();
    }
  }

  void _verifyOTP() {
    final otp = _controllers.map((c) => c.text).join();
    ref
        .read(authControllerProvider.notifier)
        .verifyPhoneOTP(widget.phoneNumber, otp);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Title
              Text(
                'Enter verification code',
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'We sent a 6-digit code to\n${widget.phoneNumber}',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) => _buildOTPField(index)),
              ),
              const SizedBox(height: 32),

              // Error Message
              if (authState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    authState.error!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const Spacer(),

              // Loading Indicator
              if (authState.isLoading)
                const Center(child: CircularProgressIndicator()),

              // Resend Code
              if (!authState.isLoading)
                TextButton(
                  onPressed: () {
                    ref
                        .read(authControllerProvider.notifier)
                        .signInWithPhone(widget.phoneNumber);
                  },
                  child: const Text('Resend code'),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPField(int index) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: AppTextStyles.headlineMedium,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.grey100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onChanged: (value) => _onOTPChanged(index, value),
        onTap: () {
          _controllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[index].text.length,
          );
        },
      ),
    );
  }
}
