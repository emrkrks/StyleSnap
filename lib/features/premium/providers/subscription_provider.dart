import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../services/subscription_service.dart';
import '../../../core/constants/app_constants.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  final service = ref.watch(subscriptionServiceProvider);
  return await service.getOfferings();
});

class SubscriptionNotifier extends StateNotifier<CustomerInfo?> {
  final SubscriptionService _service;

  SubscriptionNotifier(this._service) : super(null) {
    _init();
  }

  Future<void> _init() async {
    await _service.init();
    state = await _service.getCustomerInfo();

    // Listen for updates
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      state = customerInfo;
    });
  }

  Future<void> refresh() async {
    state = await _service.getCustomerInfo();
  }

  Future<bool> purchasePackage(Package package) async {
    final customerInfo = await _service.purchasePackage(package);
    if (customerInfo != null) {
      state = customerInfo;
      return true;
    }
    return false;
  }

  Future<bool> restorePurchases() async {
    final customerInfo = await _service.restorePurchases();
    if (customerInfo != null) {
      state = customerInfo;
      return true;
    }
    return false;
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, CustomerInfo?>((ref) {
      final service = ref.watch(subscriptionServiceProvider);
      return SubscriptionNotifier(service);
    });

final isPremiumProvider = Provider<bool>((ref) {
  final customerInfo = ref.watch(subscriptionProvider);
  if (customerInfo == null) return false;

  // Check for specific entitlement
  final entitlement =
      customerInfo.entitlements.all[AppConstants.premiumEntitlementId];
  return entitlement?.isActive ?? false;
});
