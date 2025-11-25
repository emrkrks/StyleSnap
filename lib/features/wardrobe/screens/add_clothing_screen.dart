import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/image_picker_service.dart';
import 'image_processing_screen.dart';

/// Entry screen for adding clothing items
class AddClothingScreen extends ConsumerWidget {
  const AddClothingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Clothing Item'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.checkroom_rounded,
              size: 120,
              color: AppColors.primary,
            ),
            const SizedBox(height: 32),
            Text('Add to Your Wardrobe', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Take a photo or choose from gallery to analyze and add clothing items to your wardrobe',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),
            _BuildActionButton(
              icon: Icons.camera_alt,
              label: 'Take Photo',
              color: AppColors.primary,
              onPressed: () => _handleCameraCapture(context),
            ),
            const SizedBox(height: 16),
            _BuildActionButton(
              icon: Icons.photo_library,
              label: 'Choose from Gallery',
              color: AppColors.secondary,
              onPressed: () => _handleGalleryPicker(context),
            ),
            const SizedBox(height: 16),
            _BuildActionButton(
              icon: Icons.photo_library_outlined,
              label: 'Select Multiple',
              color: AppColors.grey600,
              onPressed: () => _handleMultiplePicker(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCameraCapture(BuildContext context) async {
    final imagePicker = ImagePickerService();
    final file = await imagePicker.captureFromCamera();

    if (file != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageProcessingScreen(imageFile: file),
        ),
      );
    }
  }

  Future<void> _handleGalleryPicker(BuildContext context) async {
    final imagePicker = ImagePickerService();
    final file = await imagePicker.pickFromGallery();

    if (file != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageProcessingScreen(imageFile: file),
        ),
      );
    }
  }

  Future<void> _handleMultiplePicker(BuildContext context) async {
    final imagePicker = ImagePickerService();
    final files = await imagePicker.pickMultipleFromGallery();

    if (files.isNotEmpty && context.mounted) {
      // Process first image, then batch process others
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageProcessingScreen(
            imageFile: files.first,
            additionalFiles: files.skip(1).toList(),
          ),
        ),
      );
    }
  }
}

class _BuildActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _BuildActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
