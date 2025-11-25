import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  // Auth
  @JsonKey(name: 'auth_id')
  final String authId;
  final String? email;
  final String? phone;

  // Profile
  final String name;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  final String? bio;

  // Preferences
  final String? gender;
  @JsonKey(name: 'age_range')
  final String? ageRange;
  @JsonKey(name: 'body_type')
  final String? bodyType;
  @JsonKey(name: 'skin_tone')
  final String? skinTone;

  // Location
  final String? city;
  @JsonKey(name: 'country_code')
  final String? countryCode;
  final String? timezone;

  // Style
  @JsonKey(name: 'style_preferences')
  final List<String> stylePreferences;
  @JsonKey(name: 'favorite_colors')
  final List<String> favoriteColors;

  // Settings
  final String language;
  final String currency;
  @JsonKey(name: 'measurement_unit')
  final String measurementUnit;

  // Onboarding
  @JsonKey(name: 'onboarding_completed')
  final bool onboardingCompleted;
  @JsonKey(name: 'onboarding_step')
  final int onboardingStep;

  // Subscription
  @JsonKey(name: 'subscription_status')
  final String subscriptionStatus;
  @JsonKey(name: 'subscription_expires_at')
  final DateTime? subscriptionExpiresAt;

  // Notifications
  @JsonKey(name: 'notifications_enabled')
  final bool notificationsEnabled;
  @JsonKey(name: 'daily_reminder_time')
  final String dailyReminderTime;

  // Analytics
  @JsonKey(name: 'referral_code')
  final String? referralCode;
  @JsonKey(name: 'referred_by')
  final String? referredBy;
  @JsonKey(name: 'total_referrals')
  final int totalReferrals;

  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  const UserModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.authId,
    this.email,
    this.phone,
    required this.name,
    this.avatarUrl,
    this.bio,
    this.gender,
    this.ageRange,
    this.bodyType,
    this.skinTone,
    this.city,
    this.countryCode,
    this.timezone,
    this.stylePreferences = const [],
    this.favoriteColors = const [],
    this.language = 'en',
    this.currency = 'USD',
    this.measurementUnit = 'metric',
    this.onboardingCompleted = false,
    this.onboardingStep = 0,
    this.subscriptionStatus = 'free',
    this.subscriptionExpiresAt,
    this.notificationsEnabled = true,
    this.dailyReminderTime = '08:00:00',
    this.referralCode,
    this.referredBy,
    this.totalReferrals = 0,
    this.deletedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  bool get isPremium =>
      subscriptionStatus == 'premium' || subscriptionStatus == 'vip';

  bool get hasActiveSubscription {
    if (subscriptionExpiresAt == null) return false;
    return subscriptionExpiresAt!.isAfter(DateTime.now());
  }

  UserModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authId,
    String? email,
    String? phone,
    String? name,
    String? avatarUrl,
    String? bio,
    String? gender,
    String? ageRange,
    String? bodyType,
    String? skinTone,
    String? city,
    String? countryCode,
    String? timezone,
    List<String>? stylePreferences,
    List<String>? favoriteColors,
    String? language,
    String? currency,
    String? measurementUnit,
    bool? onboardingCompleted,
    int? onboardingStep,
    String? subscriptionStatus,
    DateTime? subscriptionExpiresAt,
    bool? notificationsEnabled,
    String? dailyReminderTime,
    String? referralCode,
    String? referredBy,
    int? totalReferrals,
    DateTime? deletedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authId: authId ?? this.authId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      ageRange: ageRange ?? this.ageRange,
      bodyType: bodyType ?? this.bodyType,
      skinTone: skinTone ?? this.skinTone,
      city: city ?? this.city,
      countryCode: countryCode ?? this.countryCode,
      timezone: timezone ?? this.timezone,
      stylePreferences: stylePreferences ?? this.stylePreferences,
      favoriteColors: favoriteColors ?? this.favoriteColors,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
