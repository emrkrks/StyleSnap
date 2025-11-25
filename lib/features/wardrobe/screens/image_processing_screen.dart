import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/wardrobe_scanning_service.dart';
import '../../../models/clothing_item.dart';
import 'clothing_review_screen.dart';

/// Screen showing AI processing progress and results
class ImageProcessingScreen extends ConsumerStatefulWidget {
  final File imageFile;
  final List<File>? additionalFiles;

  const ImageProcessingScreen({
    super.key,
    required this.imageFile,
    this.additionalFiles,
  });

  @override
  ConsumerState<ImageProcessingScreen> createState() =>
      _ImageProcessingScreenState();
}

class _ImageProcessingScreenState extends ConsumerState<ImageProcessingScreen> {
  bool _isProcessing = true;
  String _processingStep = 'Analyzing image...';
  ClothingItem? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      final scanningService = WardrobeScanningService();

      setState(() {
        _processingStep = 'Optimizing image...';
      });
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _processingStep = 'Analyzing with AI...';
      });

      final result = await scanningService.processClothingImage(
        widget.imageFile,
      );

      setState(() {
        _processingStep = 'Saving to wardrobe...';
      });
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isProcessing = false;
        _result = result;
      });

      // Navigate to review screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ClothingReviewScreen(clothingItem: result),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing Image'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image preview
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  widget.imageFile,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 48),

              if (_isProcessing) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  _processingStep,
                  style: AppTextStyles.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'This may take a few seconds...',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],

              if (_error != null) ...[
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Processing Failed',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isProcessing = true;
                    });
                    _processImage();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
