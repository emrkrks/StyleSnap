import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Service for uploading images to Supabase Storage
class SupabaseStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  /// Upload clothing image to storage
  Future<String> uploadClothingImage(File imageFile) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final fileName = '${_uuid.v4()}.jpg';
      final filePath = '$userId/$fileName';

      // Upload to 'clothing-images' bucket
      await _supabase.storage
          .from('clothing-images')
          .upload(filePath, imageFile);

      // Get public URL
      final publicUrl = _supabase.storage
          .from('clothing-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  /// Upload thumbnail to storage
  Future<String> uploadThumbnail(File thumbnailFile) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final fileName = 'thumb_${_uuid.v4()}.jpg';
      final filePath = '$userId/thumbnails/$fileName';

      await _supabase.storage
          .from('clothing-images')
          .upload(filePath, thumbnailFile);

      final publicUrl = _supabase.storage
          .from('clothing-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Error uploading thumbnail: $e');
    }
  }

  /// Delete image from storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract path from URL
      final uri = Uri.parse(imageUrl);
      final path = uri.pathSegments.skip(2).join('/'); // Skip bucket name

      await _supabase.storage.from('clothing-images').remove([path]);
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}
