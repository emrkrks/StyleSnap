import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // Auth helpers
  User? get currentUser => client.auth.currentUser;
  String? get currentUserId => currentUser?.id;
  bool get isAuthenticated => currentUser != null;

  // Stream for auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Phone authentication
  Future<void> signInWithPhone(String phone) async {
    await client.auth.signInWithOtp(phone: phone);
  }

  Future<void> verifyPhone(String phone, String token) async {
    await client.auth.verifyOTP(phone: phone, token: token, type: OtpType.sms);
  }

  // OAuth (Apple, Google)
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      final response = await client.auth.signInWithOAuth(provider);
      return response;
    } catch (e) {
      return false;
    }
  }

  // Query helpers - returns SupabaseQueryBuilder directly
  SupabaseQueryBuilder from(String table) => client.from(table);

  // Storage helpers
  SupabaseStorageClient get storage => client.storage;

  Future<String> uploadFile({
    required String bucket,
    required String path,
    required String filePath,
  }) async {
    await storage.from(bucket).upload(path, File(filePath));
    return storage.from(bucket).getPublicUrl(path);
  }

  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await storage.from(bucket).remove([path]);
  }

  String getPublicUrl({required String bucket, required String path}) {
    return storage.from(bucket).getPublicUrl(path);
  }
}
