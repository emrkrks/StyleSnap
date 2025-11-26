import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import '../models/outfit_recommendation.dart';
import '../models/clothing_item.dart';
import '../models/weather_data.dart';
import '../models/user_model.dart';
import '../core/config/app_config.dart';
import '../core/constants/app_constants.dart';

class GeminiOutfitService {
  late final GenerativeModel _model;

  GeminiOutfitService() {
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

  /// Generate 3 outfit recommendations based on context
  Future<List<OutfitRecommendation>> generateOutfitRecommendations({
    required List<ClothingItem> wardrobe,
    required WeatherData weather,
    required String occasion,
    required String season,
    required UserModel user,
  }) async {
    if (wardrobe.isEmpty) {
      throw Exception('Cannot generate recommendations for empty wardrobe');
    }

    // Convert wardrobe to simplified JSON for AI
    final wardrobeJson = wardrobe.map((item) {
      return {
        'id': item.id,
        'category': item.category,
        'subcategory': item.subcategory,
        'colors': item.colors.map((c) => c.name).toList(),
        'patterns': item.patterns,
        'materials': item.materials,
        'seasons': item.seasons,
        'styles': item.styles,
      };
    }).toList();

    final userStyles = user.preferredStyles.isNotEmpty
        ? user.preferredStyles.join(', ')
        : 'versatile, casual';

    final prompt =
        '''
Create 3 outfit recommendations for the user based on the following context:

USER WARDROBE:
${json.encode(wardrobeJson)}

CONTEXT:
- Weather: ${weather.condition}, ${weather.temperature.toStringAsFixed(0)}°C
- Occasion: $occasion
- Season: $season
- User's preferred styles: $userStyles

You MUST respond ONLY with valid JSON matching this EXACT structure:
{
  "recommendations": [
    {
      "outfit_name": "creative descriptive name",
      "occasion": "specific occasion",
      "items": [
        {
          "item_id": "uuid from wardrobe",
          "category": "category",
          "reason": "why this item works"
        }
      ],
      "style_description": "2-3 sentence description of the overall look",
      "style_score": 0.85,
      "weather_appropriateness": 0.90,
      "styling_tips": ["tip 1", "tip 2", "tip 3"],
      "missing_items": [
        {
          "category": "what's missing",
          "description": "specific suggestion",
          "priority": "high/medium/low"
        }
      ]
    }
  ]
}

Requirements:
- Each outfit must have at least 3 items from the wardrobe
- Items should complement each other in color and style
- Consider weather appropriateness
- Scores should be realistic (0.70-1.00 range)
- Provide practical styling advice
- Only identify gaps if truly missing for the outfit
- Use ONLY item IDs from the provided wardrobe
''';

    try {
      final response = await _model
          .generateContent([Content.text(prompt)])
          .timeout(AppConstants.aiProcessingTimeout);

      final jsonText = response.text?.trim() ?? '';
      final cleanJson = _extractJson(jsonText);

      final Map<String, dynamic> data = json.decode(cleanJson);
      final List<dynamic> recs = data['recommendations'];

      if (recs.isEmpty) {
        throw Exception('AI returned no recommendations');
      }

      final recommendations = recs
          .map((rec) => OutfitRecommendation.fromJson(rec))
          .toList();

      // Validate that all item IDs exist in wardrobe
      final wardrobeIds = wardrobe.map((item) => item.id).toSet();
      for (final rec in recommendations) {
        for (final item in rec.items) {
          if (!wardrobeIds.contains(item.itemId)) {
            throw Exception('AI returned invalid item ID: ${item.itemId}');
          }
        }
      }

      return recommendations.take(3).toList();
    } on FormatException catch (e) {
      throw Exception('Failed to parse AI response as JSON: $e');
    } catch (e) {
      throw Exception('Failed to generate outfit recommendations: $e');
    }
  }

  /// Get current season from date
  static String getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) {
      return 'spring';
    } else if (month >= 6 && month <= 8) {
      return 'summer';
    } else if (month >= 9 && month <= 11) {
      return 'fall';
    } else {
      return 'winter';
    }
  }

  /// Extract JSON object from text using Regex
  String _extractJson(String text) {
    try {
      // Find the first '{' and the last '}'
      final startIndex = text.indexOf('{');
      final endIndex = text.lastIndexOf('}');

      if (startIndex == -1 || endIndex == -1 || startIndex > endIndex) {
        // If no JSON object found, try to clean markdown and return
        return text.replaceAll('```json', '').replaceAll('```', '').trim();
      }

      return text.substring(startIndex, endIndex + 1);
    } catch (e) {
      return text;
    }
  }
}
