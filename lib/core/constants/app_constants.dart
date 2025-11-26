class AppConstants {
  // App Info
  static const String appName = 'StyleSnap';
  static const String appTagline = 'Your AI Personal Stylist';
  static const String appVersion = '1.0.0';

  // Database Tables
  static const String usersTable = 'users';
  static const String clothesTable = 'clothes';
  static const String outfitsTable = 'outfits';
  static const String recommendationsTable = 'recommendations';
  static const String purchasesTable = 'purchases';
  static const String affiliateClicksTable = 'affiliate_clicks';
  static const String socialSharesTable = 'social_shares';
  static const String analyticsEventsTable = 'analytics_events';

  // Storage Buckets
  static const String userAvatarsBucket = 'user-avatars';
  static const String clothingImagesBucket = 'clothing-images';
  static const String outfitImagesBucket = 'outfit-images';
  static const String sharedImagesBucket = 'shared-images';

  // Image Sizes
  static const int maxImageDimension = 1024;
  static const int maxFileSizeBytes = 500000; // 500KB
  static const int thumbnailSize = 256;
  static const int imageQuality = 85;

  // AI Model
  static const String geminiModel = 'gemini-1.5-flash';
  static const double aiTemperature = 0.3;
  static const double aiTopP = 0.95;
  static const int aiMaxOutputTokens = 8192;
  static const double minAiConfidence = 0.7;
  static const Duration aiProcessingTimeout = Duration(seconds: 60);

  // Weather API
  static const String weatherApiBaseUrl =
      'https://api.openweathermap.org/data/2.5';

  // Network
  static const Duration networkTimeout = Duration(seconds: 30);

  // Clothing Categories
  static const List<String> clothingCategories = [
    'tops',
    'bottoms',
    'dresses',
    'outerwear',
    'shoes',
    'accessories',
    'bags',
    'jewelry',
  ];

  // Seasons
  static const List<String> seasons = ['spring', 'summer', 'fall', 'winter'];

  // Styles
  static const List<String> styles = [
    'casual',
    'business',
    'elegant',
    'sporty',
    'bohemian',
    'vintage',
    'minimalist',
    'romantic',
  ];

  // RevenueCat Product IDs
  static const String adFreeMonthlyProductId = 'stylesnap_adfree_monthly';
  static const String premiumOutfitsProductId = 'stylesnap_premium_outfits';
  static const String celebrityPackProductId = 'stylesnap_celebrity_pack';
  static const String premiumEntitlementId = 'premium';

  // Affiliate Partners
  static const List<String> affiliatePartners = [
    'trendyol',
    'zara',
    'hm',
    'shein',
    'asos',
  ];

  // Daily Recommendations
  static const int dailyOutfitRecommendations = 3;
  static const int recommendationCacheDurationHours = 24;

  // Weather
  static const String weatherApiBaseUrl =
      'https://api.openweathermap.org/data/2.5';
  static const int weatherCacheDurationMinutes = 30;

  // Social Sharing
  static const String shareWatermarkText = 'StyleSnap';
  static const String shareDeepLinkScheme = 'stylesnap://';
  static const String shareBaseUrl = 'https://stylesnap.app/share';

  // Pagination
  static const int itemsPerPage = 20;
  static const int maxItemsToLoad = 100;

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration aiProcessingTimeout = Duration(seconds: 60);

  // Local Storage Keys
  static const String userIdKey = 'user_id';
  static const String authTokenKey = 'auth_token';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';

  // Supported Languages
  static const List<String> supportedLanguages = ['en', 'tr', 'es'];
  static const String defaultLanguage = 'en';

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Debounce Delays
  static const Duration searchDebounceDelay = Duration(milliseconds: 500);
  static const Duration inputDebounceDelay = Duration(milliseconds: 300);
}
