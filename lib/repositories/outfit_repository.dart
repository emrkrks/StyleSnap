import '../models/outfit.dart';
import '../core/constants/app_constants.dart';
import '../services/supabase_service.dart';

class OutfitRepository {
  final _supabase = SupabaseService();

  /// Create new outfit
  Future<Outfit> createOutfit(Outfit outfit) async {
    try {
      final response = await _supabase.client
          .from(AppConstants.outfitsTable)
          .insert(outfit.toJson())
          .select()
          .single();

      return Outfit.fromJson(response);
    } catch (e) {
      throw Exception('Error creating outfit: $e');
    }
  }

  /// Get all user's outfits
  Future<List<Outfit>> getUserOutfits() async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return [];

      final response = await _supabase.client
          .from(AppConstants.outfitsTable)
          .select()
          .eq('user_id', userId)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      return (response as List).map((item) => Outfit.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get recent outfits (limited)
  Future<List<Outfit>> getRecentOutfits({int limit = 10}) async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return [];

      final response = await _supabase.client
          .from(AppConstants.outfitsTable)
          .select()
          .eq('user_id', userId)
          .is_('deleted_at', null)
          .order('updated_at', ascending: false)
          .limit(limit);

      return (response as List).map((item) => Outfit.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get favorite outfits
  Future<List<Outfit>> getFavoriteOutfits() async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return [];

      final response = await _supabase.client
          .from(AppConstants.outfitsTable)
          .select()
          .eq('user_id', userId)
          .eq('is_favorite', true)
          .is_('deleted_at', null)
          .order('created_at', ascending: false);

      return (response as List).map((item) => Outfit.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Update outfit
  Future<void> updateOutfit(Outfit outfit) async {
    try {
      await _supabase.client
          .from(AppConstants.outfitsTable)
          .update(outfit.toJson())
          .eq('id', outfit.id);
    } catch (e) {
      throw Exception('Error updating outfit: $e');
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String outfitId, bool isFavorite) async {
    try {
      await _supabase.client
          .from(AppConstants.outfitsTable)
          .update({'is_favorite': !isFavorite})
          .eq('id', outfitId);
    } catch (e) {
      throw Exception('Error toggling favorite: $e');
    }
  }

  /// Increment times worn
  Future<void> incrementWearCount(String outfitId) async {
    try {
      // Get current outfit
      final response = await _supabase.client
          .from(AppConstants.outfitsTable)
          .select()
          .eq('id', outfitId)
          .single();

      final outfit = Outfit.fromJson(response);

      // Update with incremented count
      await _supabase.client
          .from(AppConstants.outfitsTable)
          .update({
            'times_worn': outfit.timesWorn + 1,
            'last_worn_at': DateTime.now().toIso8601String(),
          })
          .eq('id', outfitId);
    } catch (e) {
      throw Exception('Error incrementing wear count: $e');
    }
  }

  /// Soft delete outfit
  Future<void> deleteOutfit(String outfitId) async {
    try {
      await _supabase.client
          .from(AppConstants.outfitsTable)
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', outfitId);
    } catch (e) {
      throw Exception('Error deleting outfit: $e');
    }
  }

  /// Get outfit by ID
  Future<Outfit?> getOutfitById(String outfitId) async {
    try {
      final response = await _supabase.client
          .from(AppConstants.outfitsTable)
          .select()
          .eq('id', outfitId)
          .single();

      return Outfit.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
