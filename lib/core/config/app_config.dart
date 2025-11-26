import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

class AppConfig {
  // Singleton pattern
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // Supabase
  String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Gemini AI
  String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  // RevenueCat
  String get revenueCatApiKeyIOS => dotenv.env['REVENUECAT_API_KEY_IOS'] ?? '';
  String get revenueCatApiKeyAndroid =>
      dotenv.env['REVENUECAT_API_KEY_ANDROID'] ?? '';

  // OpenWeatherMap
  String get openWeatherApiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  // AdMob
  String get adMobAppIdIOS => dotenv.env['ADMOB_APP_ID_IOS'] ?? '';
  String get adMobAppIdAndroid => dotenv.env['ADMOB_APP_ID_ANDROID'] ?? '';
  String get adMobBannerAdUnitIdIOS =>
      dotenv.env['ADMOB_BANNER_AD_UNIT_ID_IOS'] ?? '';
  String get adMobBannerAdUnitIdAndroid =>
      dotenv.env['ADMOB_BANNER_AD_UNIT_ID_ANDROID'] ?? '';

  // Mixpanel
  String get mixpanelToken => dotenv.env['MIXPANEL_TOKEN'] ?? '';

  // Affiliate
  String get trendyolAffiliateId => dotenv.env['TRENDYOL_AFFILIATE_ID'] ?? '';

  // Validation
  bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        geminiApiKey.isNotEmpty;
  }

  String get revenueCatApiKey =>
      Platform.isAndroid ? revenueCatApiKeyAndroid : revenueCatApiKeyIOS;

  String get admobAppId =>
      Platform.isAndroid ? adMobAppIdAndroid : adMobAppIdIOS;
}
