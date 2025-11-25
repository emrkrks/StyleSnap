import '../models/clothing_item.dart';
import '../core/constants/app_constants.dart';
import '../services/supabase_service.dart';

class ClothingRepository {
  final _supabase = SupabaseService();

  /// Create new clothing item
  Future<ClothingItem> createClothingItem(ClothingItem item) async {
    try {
      final response = await _supabase.client
          .from(AppConstants.clothesTable)
          .insert(item.toJson())
          .select()
          .single();

      return ClothingItem.fromJson(response);
    } catch (e) {
      throw Exception('Error creating clothing item: $e');
    }
  }

  /// Get all user's clothing items
  Future<List<ClothingItem>> getUserClothingItems() async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return [];

      final response = await _supabase.client
          .from(AppConstants.clothesTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => ClothingItem.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get clothing items by category
  Future<List<ClothingItem>> getItemsByCategory(String category) async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return [];

      final response = await _supabase.client
          .from(AppConstants.clothesTable)
          .select()
          .eq('user_id', userId)
          .eq('category', category)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => ClothingItem.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get favorite items
  Future<List<ClothingItem>> getFavoriteItems() async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return [];

      final response = await _supabase.client
          .from(AppConstants.clothesTable)
          .select()
          .eq('user_id', userId)
          .eq('favorite', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => ClothingItem.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Search clothing items
  Future<List<ClothingItem>> searchItems(String query) async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return [];

      final response = await _supabase.client
          .from(AppConstants.clothesTable)
          .select()
          .eq('user_id', userId)
          .or(
            'brand.ilike.%$query%,subcategory.ilike.%$query%,notes.ilike.%$query%',
          )
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => ClothingItem.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Update clothing item
  Future<void> updateClothingItem(ClothingItem item) async {
    try {
      await _supabase.client
          .from(AppConstants.clothesTable)
          .update(item.toJson())
          .eq('id', item.id);
    } catch (e) {
      throw Exception('Error updating clothing item: $e');
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String itemId, bool isFavorite) async {
    try {
      await _supabase.client
          .from(AppConstants.clothesTable)
          .update({'favorite': !isFavorite})
          .eq('id', itemId);
    } catch (e) {
      throw Exception('Error toggling favorite: $e');
    }
  }

  /// Soft delete clothing item
  Future<void> deleteClothingItem(String itemId) async {
    try {
      await _supabase.client
          .from(AppConstants.clothesTable)
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', itemId);
    } catch (e) {
      throw Exception('Error deleting clothing item: $e');
    }
  }

  /// Get items by season
  Future<List<ClothingItem>> getItemsBySeason(String season) async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return [];

      final response = await _supabase.client
          .from(AppConstants.clothesTable)
          .select()
          .eq('user_id', userId)
          .contains('seasons', [season])
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => ClothingItem.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get wardrobe statistics
  Future<Map<String, int>> getWardrobeStats() async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return {};

      final items = await getUserClothingItems();

      final stats = <String, int>{};
      for (final category in AppConstants.clothingCategories) {
        stats[category] = items.where((i) => i.category == category).length;
      }

      return stats;
    } catch (e) {
      return {};
    }
  }
}
