import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../core/config/app_config.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;

    // Note: In a real app, you would have different keys for iOS and Android
    // For this MVP, we'll assume the key in AppConfig is valid for the current platform
    // or handle platform specific logic here.
    final apiKey = AppConfig().revenueCatApiKey;

    if (apiKey.isEmpty) {
      print('Warning: RevenueCat API key is empty');
      return;
    }

    configuration = PurchasesConfiguration(apiKey);
    await Purchases.configure(configuration);
    _isInitialized = true;
  }

  Future<CustomerInfo?> getCustomerInfo() async {
    if (!_isInitialized) return null;
    try {
      return await Purchases.getCustomerInfo();
    } on PlatformException catch (e) {
      print('Error getting customer info: $e');
      return null;
    }
  }

  Future<Offerings?> getOfferings() async {
    if (!_isInitialized) return null;
    try {
      return await Purchases.getOfferings();
    } on PlatformException catch (e) {
      print('Error getting offerings: $e');
      return null;
    }
  }

  Future<CustomerInfo?> purchasePackage(Package package) async {
    if (!_isInitialized) return null;
    try {
      return await Purchases.purchasePackage(package);
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        print('Error purchasing package: $e');
      }
      return null;
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    if (!_isInitialized) return null;
    try {
      return await Purchases.restorePurchases();
    } on PlatformException catch (e) {
      print('Error restoring purchases: $e');
      return null;
    }
  }

  Future<void> logIn(String appUserId) async {
    if (!_isInitialized) return;
    try {
      await Purchases.logIn(appUserId);
    } on PlatformException catch (e) {
      print('Error logging in to RevenueCat: $e');
    }
  }

  Future<void> logOut() async {
    if (!_isInitialized) return;
    try {
      await Purchases.logOut();
    } on PlatformException catch (e) {
      print('Error logging out from RevenueCat: $e');
    }
  }
}
