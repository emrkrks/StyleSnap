import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/clothing_item.dart';
import '../services/image_preprocessor.dart';
import '../services/gemini_clothing_service.dart';
import '../services/supabase_storage_service.dart';
import '../repositories/clothing_repository.dart';

/// Main orchestrator service for wardrobe scanning pipeline
/// Coordinates: Image → Preprocess → AI Analysis → Storage → Database
class WardrobeScanningService {
  final ImagePreprocessor _preprocessor = ImagePreprocessor();
  final GeminiClothingService _aiService = GeminiClothingService();
  final SupabaseStorageService _storage = SupabaseStorageService();
  final ClothingRepository _repository = ClothingRepository();
  final _uuid = const Uuid();

  /// Process single clothing image through complete pipeline
  Future<ClothingItem> processClothingImage(File originalImage) async {
    try {
      // Step 1: Preprocess image
      final processedImage = await _preprocessor.preprocessImage(originalImage);

      // Step 2: Generate thumbnail
      final thumbnail = await _preprocessor.generateThumbnail(processedImage);

      // Step 3: AI Analysis
      final analysis = await _aiService.analyzeClothing(processedImage);

      // Step 4: Upload images to storage
      final imageUrl = await _storage.uploadClothingImage(processedImage);
      final thumbnailUrl = await _storage.uploadThumbnail(thumbnail);

      // Step 5: Create database entry
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final clothingItem = ClothingItem(
        id: _uuid.v4(),
        userId: userId,
        imageUrl: imageUrl,
        thumbnailUrl: thumbnailUrl,
        category: analysis.category,
        subcategory: analysis.subcategory,
        colors: analysis.colors,
        patterns: analysis.patterns,
        materials: analysis.materials,
        seasons: analysis.seasons,
        styles: analysis.styles,
        aiConfidence: analysis.confidence,
        aiModelVersion: 'gemini-1.5-flash',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Step 6: Save to database
      final savedItem = await _repository.createClothingItem(clothingItem);

      // Cleanup temp files
      await processedImage.delete();
      await thumbnail.delete();

      return savedItem;
    } catch (e) {
      throw Exception('Error in wardrobe scanning pipeline: $e');
    }
  }

  /// Process multiple images (batch upload)
  Future<List<ClothingItem>> processMultipleImages(List<File> images) async {
    final List<ClothingItem> items = [];

    for (final image in images) {
      try {
        final item = await processClothingImage(image);
        items.add(item);
      } catch (e) {
        print('Error processing image: $e');
        // Continue with next image even if one fails
      }
    }

    return items;
  }
}
