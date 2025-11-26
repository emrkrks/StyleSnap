import '../models/outfit_recommendation.dart';
import '../core/constants/app_constants.dart';
import '../services/supabase_service.dart';
import 'dart:convert';

class RecommendationRepository {
  final _supabase = SupabaseService();

  /// Save daily recommendations to database
  Future<void> saveDailyRecommendations(
    List<OutfitRecommendation> recommendations,
  ) async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      final records = recommendations.map((rec) {
        return {
          'user_id': userId,
          'outfit_name': rec.outfitName,
          'occasion': rec.occasion,
          'items': json.encode(rec.items.map((i) => i.toJson()).toList()),
          'style_description': rec.styleDescription,
          'style_score': rec.styleScore,
          'weather_appropriateness': rec.weatherAppropriateness,
          'styling_tips': rec.stylingTips,
          'missing_items': json.encode(
            rec.missingItems.map((m) => m.toJson()).toList(),
          ),
          'created_at': now.toIso8601String(),
          'valid_until': now.add(const Duration(hours: 24)).toIso8601String(),
        };
      }).toList();

      await _supabase.client
          .from(AppConstants.recommendationsTable)
          .insert(records);
    } catch (e) {
      throw Exception('Error saving recommendations: $e');
    }
  }

  /// Get today's cached recommendations
  Future<List<OutfitRecommendation>> getTodayRecommendations() async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return [];

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final response = await _supabase.client
          .from(AppConstants.recommendationsTable)
          .select()
          .eq('user_id', userId)
          .gte('created_at', startOfDay.toIso8601String())
          .gte('valid_until', now.toIso8601String())
          .order('created_at', ascending: false)
          .limit(3);

      if (response.isEmpty) return [];

      return (response as List).map((item) {
        return OutfitRecommendation(
          outfitName: item['outfit_name'] as String,
          occasion: item['occasion'] as String,
          items: (json.decode(item['items'] as String) as List)
              .map((i) => RecommendedItem.fromJson(i))
              .toList(),
          styleDescription: item['style_description'] as String,
          styleScore: (item['style_score'] as num).toDouble(),
          weatherAppropriateness: (item['weather_appropriateness'] as num)
              .toDouble(),
          stylingTips: (item['styling_tips'] as List)
              .map((t) => t as String)
              .toList(),
          missingItems: (json.decode(item['missing_items'] as String) as List)
              .map((m) => MissingItem.fromJson(m))
              .toList(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get recommendation history (past 7 days)
  Future<List<OutfitRecommendation>> getRecommendationHistory() async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return [];

      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final response = await _supabase.client
          .from(AppConstants.recommendationsTable)
          .select()
          .eq('user_id', userId)
          .gte('created_at', sevenDaysAgo.toIso8601String())
          .order('created_at', ascending: false);

      return (response as List).map((item) {
        return OutfitRecommendation(
          outfitName: item['outfit_name'] as String,
          occasion: item['occasion'] as String,
          items: (json.decode(item['items'] as String) as List)
              .map((i) => RecommendedItem.fromJson(i))
              .toList(),
          styleDescription: item['style_description'] as String,
          styleScore: (item['style_score'] as num).toDouble(),
          weatherAppropriateness: (item['weather_appropriateness'] as num)
              .toDouble(),
          stylingTips: (item['styling_tips'] as List)
              .map((t) => t as String)
              .toList(),
          missingItems: (json.decode(item['missing_items'] as String) as List)
              .map((m) => MissingItem.fromJson(m))
              .toList(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Clear old recommendations (> 7 days)
  Future<void> cleanOldRecommendations() async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return;

      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      await _supabase.client
          .from(AppConstants.recommendationsTable)
          .delete()
          .eq('user_id', userId)
          .lt('created_at', sevenDaysAgo.toIso8601String());
    } catch (e) {
      // Silently fail - cleaning is not critical
    }
  }
}
