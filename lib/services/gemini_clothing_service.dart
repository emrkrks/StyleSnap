import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/config/app_config.dart';
import '../core/constants/app_constants.dart';
import '../models/clothing_item.dart';

class GeminiClothingService {
  late final GenerativeModel _model;

  GeminiClothingService() {
    final apiKey = AppConfig().geminiApiKey;
    _model = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: AppConstants.aiTemperature,
        topP: AppConstants.aiTopP,
        maxOutputTokens: AppConstants.aiMaxOutputTokens,
      ),
    );
  }

  /// Analyze clothing item from image
  Future<ClothingAnalysisResult> analyzeClothing(File imageFile) async {
    try {
      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();

      // Prepare prompt
      const prompt = '''
Analyze this clothing item and respond with JSON in this exact structure:
{
  "category": "one of: tops, bottoms, dresses, outerwear, shoes, accessories, bags, jewelry",
  "subcategory": "specific type (e.g., t-shirt, jeans, sneakers)",
  "colors": [{"hex": "#RRGGBB", "name": "color name", "percentage": 0-100}],
  "patterns": ["array of patterns like solid, striped, floral, plaid"],
  "materials": ["array of materials like cotton, denim, leather"],
  "seasons": ["array of seasons: spring, summer, fall, winter"],
  "styles": ["array of styles like casual, business, elegant, sporty"],
  "description": "brief one sentence description",
  "confidence": 0.00-1.00
}

Respond ONLY with valid JSON, no markdown or explanations.
''';

      // Create content
      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      // Generate response
      final response = await _model.generateContent(content);
      final responseText = response.text?.trim() ?? '';

      // Clean JSON (remove markdown if present)
      final cleanJson = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Parse JSON
      final Map<String, dynamic> data = json.decode(cleanJson);

      return ClothingAnalysisResult.fromJson(data);
    } catch (e) {
      throw Exception('Error analyzing clothing: $e');
    }
  }

  /// Analyze multiple items in one image
  Future<List<ClothingAnalysisResult>> analyzeMultipleItems(
    File imageFile,
  ) async {
    try {
      final imageBytes = await imageFile.readAsBytes();

      const prompt = '''
Analyze this photograph and detect all clothing items visible.
For each item, provide analysis.

Respond with valid JSON:
{
  "items_count": number,
  "items": [
    {
      "item_number": 1,
      "category": "...",
      "subcategory": "...",
      "colors": [...],
      "patterns": [...],
      "materials": [...],
      "seasons": [...],
      "styles": [...],
      "description": "...",
      "confidence": 0.00-1.00
    }
  ]
}
''';

      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      final response = await _model.generateContent(content);
      final cleanJson =
          response.text
              ?.trim()
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim() ??
          '';

      final Map<String, dynamic> data = json.decode(cleanJson);
      final List<dynamic> itemsJson = data['items'] ?? [];

      return itemsJson
          .map((item) => ClothingAnalysisResult.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Error analyzing multiple items: $e');
    }
  }
}

/// Data model for analysis result
class ClothingAnalysisResult {
  final String category;
  final String subcategory;
  final List<ColorInfo> colors;
  final List<String> patterns;
  final List<String> materials;
  final List<String> seasons;
  final List<String> styles;
  final String description;
  final double confidence;

  ClothingAnalysisResult({
    required this.category,
    required this.subcategory,
    required this.colors,
    required this.patterns,
    required this.materials,
    required this.seasons,
    required this.styles,
    required this.description,
    required this.confidence,
  });

  factory ClothingAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ClothingAnalysisResult(
      category: json['category'] as String,
      subcategory: json['subcategory'] as String,
      colors: (json['colors'] as List)
          .map((c) => ColorInfo.fromJson(c as Map<String, dynamic>))
          .toList(),
      patterns: List<String>.from(json['patterns'] ?? []),
      materials: List<String>.from(json['materials'] ?? []),
      seasons: List<String>.from(json['seasons'] ?? []),
      styles: List<String>.from(json['styles'] ?? []),
      description: json['description'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}
