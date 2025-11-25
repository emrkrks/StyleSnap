import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../core/constants/app_constants.dart';

class ImagePreprocessor {
  /// Optimize image for AI processing
  /// - Resize to max dimension
  /// - Compress to target file size
  /// - Convert to JPEG
  Future<File> preprocessImage(File originalFile) async {
    try {
      // Read image
      final bytes = await originalFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if needed (maintain aspect ratio)
      if (image.width > AppConstants.maxImageDimension ||
          image.height > AppConstants.maxImageDimension) {
        image = img.copyResize(
          image,
          width: image.width > image.height
              ? AppConstants.maxImageDimension
              : null,
          height: image.height > image.width
              ? AppConstants.maxImageDimension
              : null,
          interpolation: img.Interpolation.linear,
        );
      }

      // Compress to JPEG
      final compressedBytes = img.encodeJpg(
        image,
        quality: AppConstants.imageQuality,
      );

      // Check file size, compress more if needed
      List<int> finalBytes = compressedBytes;
      int quality = AppConstants.imageQuality;

      while (finalBytes.length > AppConstants.maxFileSizeBytes &&
          quality > 50) {
        quality -= 10;
        finalBytes = img.encodeJpg(image, quality: quality);
      }

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/compressed_$timestamp.jpg');
      await tempFile.writeAsBytes(finalBytes);

      return tempFile;
    } catch (e) {
      throw Exception('Error preprocessing image: $e');
    }
  }

  /// Generate thumbnail
  Future<File> generateThumbnail(File originalFile) async {
    try {
      final bytes = await originalFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize to thumbnail size
      final thumbnail = img.copyResize(
        image,
        width: AppConstants.thumbnailSize,
        height: AppConstants.thumbnailSize,
        interpolation: img.Interpolation.linear,
      );

      final thumbnailBytes = img.encodeJpg(
        thumbnail,
        quality: AppConstants.imageQuality,
      );

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final thumbFile = File('${tempDir.path}/thumb_$timestamp.jpg');
      await thumbFile.writeAsBytes(thumbnailBytes);

      return thumbFile;
    } catch (e) {
      throw Exception('Error generating thumbnail: $e');
    }
  }

  /// Validate image quality
  bool isImageQualityAcceptable(File imageFile) {
    // Check if file exists and is readable
    if (!imageFile.existsSync()) return false;

    // Check file size (min 10KB, max 10MB)
    final size = imageFile.lengthSync();
    if (size < 10000 || size > 10000000) return false;

    return true;
  }
}
