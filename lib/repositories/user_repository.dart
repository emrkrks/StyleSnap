import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import '../services/supabase_service.dart';

class UserRepository {
  final _supabase = SupabaseService();

  /// Get current user profile
  Future<UserModel?> getCurrentUser() async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return null;

      final response = await _supabase.client
          .from(AppConstants.usersTable)
          .select()
          .eq('auth_id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Create user profile
  Future<UserModel> createUser(UserModel user) async {
    try {
      final response = await _supabase.client
          .from(AppConstants.usersTable)
          .insert(user.toJson())
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  /// Update user profile
  Future<void> updateUser(UserModel user) async {
    try {
      await _supabase.client
          .from(AppConstants.usersTable)
          .update(user.toJson())
          .eq('id', user.id);
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  /// Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    final user = await getCurrentUser();
    return user?.onboardingCompleted ?? false;
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return;

      await _supabase.client
          .from(AppConstants.usersTable)
          .update({
            'onboarding_completed': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('auth_id', userId);
    } catch (e) {
      throw Exception('Error completing onboarding: $e');
    }
  }

  /// Update subscription status
  Future<void> updateSubscriptionStatus({
    required String status,
    DateTime? expiresAt,
  }) async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return;

      await _supabase.client
          .from(AppConstants.usersTable)
          .update({
            'subscription_status': status,
            'subscription_expires_at': expiresAt?.toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('auth_id', userId);
    } catch (e) {
      throw Exception('Error updating subscription: $e');
    }
  }

  /// Delete user account (soft delete)
  Future<void> deleteUser() async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return;

      await _supabase.client
          .from(AppConstants.usersTable)
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('auth_id', userId);
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }
}
