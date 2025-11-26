import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/supabase_service.dart';
import '../../../models/user_model.dart';
import '../../../repositories/user_repository.dart';

// Supabase Service Provider
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// Auth State Stream Provider
final supabaseAuthStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return supabase.authStateChanges;
});

// Auth Session Provider
final authProvider = StreamProvider<Session?>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return supabase.authStateChanges.map((event) => event.session);
});

// Current User Provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return await repository.getCurrentUser();
});

// Auth Controller Provider
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthUIState>((ref) {
      return AuthController(ref);
    });

// Auth UI State (renamed to avoid conflict with Supabase AuthState)
class AuthUIState {
  final bool isLoading;
  final String? error;
  final User? user;

  AuthUIState({this.isLoading = false, this.error, this.user});

  AuthUIState copyWith({bool? isLoading, String? error, User? user}) {
    return AuthUIState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}

// Auth Controller
class AuthController extends StateNotifier<AuthUIState> {
  final Ref ref;

  AuthController(this.ref) : super(AuthUIState());

  Future<void> signInWithPhone(String phone) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.signInWithPhone(phone);

      // Phone OTP sent successfully
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send OTP: ${e.toString()}',
      );
    }
  }

  Future<void> verifyPhoneOTP(String phone, String token) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.verifyPhone(phone, token);

      // Get current user
      final currentUser = supabase.currentUser;
      if (currentUser != null) {
        // Check if user profile exists
        final repository = ref.read(userRepositoryProvider);
        var userProfile = await repository.getCurrentUser();

        // Create profile if doesn't exist
        userProfile ??= await _createUserProfile(currentUser);

        state = state.copyWith(isLoading: false, user: currentUser);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'OTP verification failed: ${e.toString()}',
      );
    }
  }

  Future<void> signInWithOAuth(OAuthProvider provider) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final supabase = ref.read(supabaseServiceProvider);
      final success = await supabase.signInWithOAuth(provider);

      if (success) {
        final currentUser = supabase.currentUser;
        if (currentUser != null) {
          // Check/create user profile
          final repository = ref.read(userRepositoryProvider);
          var userProfile = await repository.getCurrentUser();

          userProfile ??= await _createUserProfile(currentUser);

          state = state.copyWith(isLoading: false, user: currentUser);
        }
      } else {
        state = state.copyWith(isLoading: false, error: 'OAuth sign in failed');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'OAuth error: ${e.toString()}',
      );
    }
  }

  Future<UserModel> _createUserProfile(User user) async {
    final repository = ref.read(userRepositoryProvider);

    final newUser = UserModel(
      id: user.id,
      authId: user.id,
      email: user.email,
      phone: user.phone,
      name:
          user.userMetadata?['full_name'] ??
          user.email?.split('@').first ??
          'User',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await repository.createUser(newUser);
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.signOut();

      state = AuthUIState(); // Reset to initial state
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sign out failed: ${e.toString()}',
      );
    }
  }
}
