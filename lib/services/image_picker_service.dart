import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Service for capturing images from camera or selecting from gallery
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Capture image from camera
  Future<File?> captureFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Compress to 85% quality
        maxWidth: 1024, // Max dimension
        maxHeight: 1024,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      print('Error capturing from camera: $e');
      return null;
    }
  }

  /// Pick single image from gallery
  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      print('Error picking from gallery: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery (batch upload)
  Future<List<File>> pickMultipleFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultipleImages(
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      return images.map((xfile) => File(xfile.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }
}
