# StyleSnap - RevenueCat Integration Guide

## 💰 Overview

Complete implementation guide for in-app purchases and subscriptions using RevenueCat.

**Subscription Tiers**:
1. **Ad-Free**: $4.99/month
2. **Premium Outfit Pack**: $1.99 (one-time or monthly)
3. **Celebrity Style Pack**: $2.99 (one-time)

---

## 🚀 Step 1: RevenueCat Account Setup

### Create Account

1. Go to [revenuecat.com](https://www.revenuecat.com)
2. Sign up (free tier: $2,500/month tracked revenue)
3. Create new project: **StyleSnap**

### Add Apps

#### iOS App

1 **Projects** → **Apps** → **Add new app**
2. Platform: **iOS**
3. App name: **StyleSnap**  
4. Bundle ID: `com.stylesnap.app` (must match Xcode)
5. Click **Create**

#### Android App

1. **Add new app**
2. Platform: **Android**
3. App name: **StyleSnap**
4. Package name: `com.stylesnap.app` (must match build.gradle)
5. Click **Create**

### Get API Keys

1. **Project Settings** → **API Keys**
2. Copy **Public SDK key**: `appl_xxxxxxxxxxxxx`
3. Save securely (add to `.env` file)

---

## 📦 Step 2: Configure In-App Products

### iOS - App Store Connect

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. **My Apps** → **StyleSnap** → **In-App Purchases**
3. Click **+** to create new

#### Product 1: Ad-Free Subscription

- **Type**: Auto-Renewable Subscription
- **Reference Name**: Ad-Free Monthly
- **Product ID**: `stylesnap_adfree_monthly`
- **Subscription Group**: StyleSnap Premium
- **Subscription Duration**: 1 Month
- **Price**: $4.99 (Tier 5)
- **Localized Description**:
  - EN: "Remove all ads and enjoy StyleSnap ad-free"
  - TR: "Tüm reklamları kaldır, StyleSnap'i reklamsız kullan"
  - ES: "Elimina todos los anuncios y disfruta sin publicidad"

#### Product 2: Premium Outfit Pack

- **Type**: Auto-Renewable Subscription (or Non-Consumable)
- **Product ID**: `stylesnap_premium_outfits`
- **Subscription Duration**: 1 Month
- **Price**: $1.99 (Tier 1)

#### Product 3: Celebrity Style Pack

- **Type**: Non-Consumable
- **Product ID**: `stylesnap_celebrity_pack`
- **Price**: $2.99 (Tier 3)

**Save all products**

### Android - Google Play Console

1. Go to [play.google.com/console](https://play.google.com/console)
2. **StyleSnap** → **Monetize** → **Products** → **Subscriptions**
3. **Create subscription**

#### Product 1: Ad-Free

- **Product ID**: `stylesnap_adfree_monthly`
- **Name**: Ad-Free Monthly
- **Description**: "Remove all ads"
- **Base plan**: Monthly
- **Price**: $4.99
- **Grace period**: 3 days
- **Free trial**: 7 days (optional)

#### Product 2: Premium Outfits

- **Product ID**: `stylesnap_premium_outfits`
- **Price**: $1.99/month

#### Product 3: Celebrity Pack (In-app product)

- Go to **In-app products**
- **Product ID**: `stylesnap_celebrity_pack`
- **Price**: $2.99
- **Type**: Non-consumable

**Activate all products**

---

## 🔗 Step 3: Link RevenueCat to Store

### iOS Connection

1. In RevenueCat: **Apps** → **iOS App** → **Service Credentials**
2. **App Store Connect API Key**:
   - Go to App Store Connect → **Users and Access** → **Keys**
   - Create new API Key (Admin role)
   - Download `.p8` file
   - Note Issuer ID and Key ID
3. Upload to RevenueCat:
   - Upload `.p8` file
   - Enter Issuer ID
   - Enter Key ID
   - **Save**

### Android Connection

1. In RevenueCat: **Apps** → **Android App** → **Service Credentials**
2. **Google Play Service Credentials**:
   - Go to Google Play Console → **Setup** → **API access**
   - Link to Google Cloud project
   - Create Service Account
   - Grant "Admin" permission
   - Download JSON key
3. Upload JSON to RevenueCat
4. **Save**

---

## 📝 Step 4: Create Entitlements

**Entitlements** = Features users get with purchases

### Create Entitlement: "premium"

1. RevenueCat Dashboard → **Entitlements**
2. **Create New Entitlement**
3. Identifier: `premium`
4. Description: "Full premium access"

### Attach Products

1. Click on `premium` entitlement
2. **Attach Products**:
   - ✅ `stylesnap_adfree_monthly` (iOS + Android)
   - ✅ `stylesnap_premium_outfits` (iOS + Android)
   - ✅ `stylesnap_celebrity_pack` (iOS + Android)
3. **Save**

**Result**: Any of these 3 purchases → Premium access

---

## 📦 Step 5: Create Offerings

**Offerings** = Grouped products to show in paywall

### Create Offering: "default"

1. **Offerings** → **Create Offering**
2. Identifer: `default`
3. Description: "Default paywall"
4. **Add Packages**:

#### Package 1: Monthly Ad-Free

- Identifier: `monthly_adfree`
- Product: `stylesnap_adfree_monthly`
- Display name: "Ad-Free Experience"

#### Package 2: Outfit Pack

- Identifier: `outfit_pack`
- Product: `stylesnap_premium_outfits`
- Display name: "Premium Outfits"

#### Package 3: Celebrity Pack

- Identifier: `celebrity_pack`
- Product: `stylesnap_celebrity_pack`
- Display name: "Celebrity Styles"

**Make "default" offering current** ✅

---

## 💻 Step 6: Flutter Integration

### Add Dependency

**pubspec.yaml**:
```yaml
dependencies:
  purchases_flutter: ^6.29.2
```

```bash
flutter pub get
```

### iOS Configuration

**ios/Runner/Info.plist**:
```xml
<key>SKAdNetworkItems</key>
<array>
  <!-- RevenueCat SKAdNetwork IDs -->
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
</array>
```

### Android Configuration

No additional config needed for Android.

---

## 🔧 Step 7: RevenueCat Service Implementation

**lib/services/revenue_service.dart**:
```dart
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/foundation.dart';

class RevenueService {
  static final RevenueService _instance = RevenueService._internal();
  factory RevenueService() => _instance;
  RevenueService._internal();

  static const String _apiKey = 'YOUR_REVENUECAT_PUBLIC_KEY';
  
  bool _isInitialized = false;

  /// Initialize RevenueCat
  Future<void> initialize(String userId) async {
    if (_isInitialized) return;

    try {
      await Purchases.setLogLevel(
        kDebugMode ? LogLevel.debug : LogLevel.info,
      );

      PurchasesConfiguration configuration;
      
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        configuration = PurchasesConfiguration(_apiKey);
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        configuration = PurchasesConfiguration(_apiKey);
      } else {
        throw UnsupportedError('Platform not supported');
      }

      await Purchases.configure(configuration);
      
      // Set user ID (from Supabase auth)
      await Purchases.logIn(userId);
      
      _isInitialized = true;
      debugPrint('RevenueCat initialized for user: $userId');
      
    } catch (e) {
      debugPrint('Error initializing RevenueCat: $e');
      rethrow;
    }
  }

  /// Get available offerings
  Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings;
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
      return null;
    }
  }

  /// Purchase a package
  Future<bool> purchasePackage(Package package) async {
    try {
      final purchaserInfo = await Purchases.purchasePackage(package);
      
      // Check if user now has premium
      final isPremium = purchaserInfo.entitlements.active.containsKey('premium');
      
      debugPrint('Purchase successful. Premium: $isPremium');
      return isPremium;
      
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      
      if (errorCode ==  PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('User cancelled purchase');
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        debugPrint('Payment pending');
      } else {
        debugPrint('Purchase error: ${e.message}');
      }
      
      return false;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    try {
      final purchaserInfo = await Purchases.restorePurchases();
      final isPremium = purchaserInfo.entitlements.active.containsKey('premium');
      
      debugPrint('Restore successful. Premium: $isPremium');
      return isPremium;
      
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return false;
    }
  }

  /// Check if user has premium
  Future<bool> isPremiumUser() async {
    try {
      final purchaserInfo = await Purchases.getCustomerInfo();
      return purchaserInfo.entitlements.active.containsKey('premium');
    } catch (e) {
      debugPrint('Error checking premium status: $e');
      return false;
    }
  }

  /// Get customer info stream
  Stream<CustomerInfo> get customerInfoStream {
    return Purchases.getCustomerInfoStream();
  }

  /// Log out user (on app logout)
  Future<void> logOut() async {
    try {
      await Purchases.logOut();
      _isInitialized = false;
    } catch (e) {
      debugPrint('Error logging out from RevenueCat: $e');
    }
  }
}
```

---

## 🎨 Step 8: Paywall UI Implementation

**lib/features/paywall/screens/paywall_screen.dart**:
```dart
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({Key? key}) : super(key: key);

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final RevenueService _revenueService = RevenueService();
  
  Offerings? _offerings;
  bool _isLoading = true;
  Package? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    final offerings = await _revenueService.getOfferings();
    setState(() {
      _offerings = offerings;
      _isLoading = false;
      
      // Pre-select monthly ad-free
      _selectedPackage = offerings?.current?.monthly;
    });
  }

  Future<void> _purchase() async {
    if (_selectedPackage == null) return;

    setState(() => _isLoading = true);

    final success = await _revenueService.purchasePackage(_selectedPackage!);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Welcome to Premium!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildPaywallContent(),
      ),
    );
  }

  Widget _buildPaywallContent() {
    if (_offerings == null || _offerings!.current == null) {
      return const Center(
        child: Text('No offerings available'),
      );
    }

    final currentOffering = _offerings!.current!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          const SizedBox(height: 20),

          // Header
          const Text(
            'Upgrade to Premium',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Unlock all features and enjoy ad-free experience',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 32),

          // Features list
          _buildFeature('✨ Ad-free experience'),
          _buildFeature('🎨 Unlimited outfit generations'),
          _buildFeature('⭐ Celebrity style packs'),
          _buildFeature('📊 Advanced analytics'),
          _buildFeature('🚀 Priority AI processing'),
          _buildFeature('💎 Premium outfit templates'),

          const SizedBox(height: 32),

          // Packages
          ...currentOffering.availablePackages.map(
            (package) => _buildPackageCard(package),
          ),

          const SizedBox(height: 24),

          // Purchase button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _purchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _selectedPackage == null
                    ? 'Select a plan'
                    : 'Subscribe for ${_selectedPackage!.storeProduct.priceString}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Restore purchases
          TextButton(
            onPressed: _restorePurchases,
            child: const Text('Restore Purchases'),
          ),

          const SizedBox(height: 8),

          // Terms
          const Text(
            'Subscription automatically renews unless cancelled. '
            'See Terms of Service and Privacy Policy.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildPackageCard(Package package) {
    final isSelected = _selectedPackage?.identifier == package.identifier;
    final product = package.storeProduct;

    String title = '';
    String subtitle = '';

    // Customize based on package identifier
    if (package.identifier == 'monthly_adfree') {
      title = 'Ad-Free Experience';
      subtitle = 'Remove all ads';
    } else if (package.identifier == 'outfit_pack') {
      title = 'Premium Outfits';
      subtitle = 'Weekly curated looks';
    } else if (package.identifier == 'celebrity_pack') {
      title = 'Celebrity Styles';
      subtitle = 'Copy looks from Bella Hadid & more';
    }

    return GestureDetector(
      onTap: () {
        setState(() => _selectedPackage = package);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? const Color(0xFF8B5CF6).withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            // Radio button
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey,
            ),

            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Price
            Text(
              product.priceString,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);

    final success = await _revenueService.restorePurchases();

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Purchases restored!'
                : 'No purchases found',
          ),
          backgroundColor: success ? Colors.green : Colors.orange,
        ),
      );

      if (success) {
        Navigator.pop(context);
      }
    }
  }
}
```

---

## 🔐 Step 9: Premium Access Control

### Premium Check Widget

**lib/widgets/premium_gate.dart**:
```dart
import 'package:flutter/material.dart';

class PremiumGate extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const PremiumGate({
    Key? key,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: RevenueService().isPremiumUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final isPremium = snapshot.data!;

        if (isPremium) {
          return child;
        } else {
          return fallback ?? _buildUpgradePrompt(context);
        }
      },
    );
  }

  Widget _buildUpgradePrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Premium Feature',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upgrade to unlock this feature',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PaywallScreen(),
                ),
              );
            },
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
}
```

### Usage Example

**Celebrity Style Feature**:
```dart
class CelebrityStyleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Celebrity Styles')),
      body: PremiumGate(
        child: CelebrityStyleList(), // Premium content
      ),
    );
  }
}
```

---

## 📊 Step 10: Analytics Integration

Track subscription events in Supabase:

**lib/services/subscription_tracking_service.dart**:
```dart
class SubscriptionTrackingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> trackPurchase(CustomerInfo customerInfo) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      for (final entitlement in customerInfo.entitlements.active.values) {
        await _supabase.from('purchases').insert({
          'user_id': userId,
          'purchase_type': 'subscription',
          'product_id': entitlement.productIdentifier,
          'price_usd': _extractPrice(entitlement),
          'provider': entitlement.store == Store.appStore ? 'apple' : 'google',
          'status': 'active',
          'subscription_start_date': entitlement.latestPurchaseDate,
          'subscription_end_date': entitlement.expirationDate,
        });
      }

      // Update user subscription status
      await _supabase.from('users').update({
        'subscription_status': 'premium',
        'subscription_expires_at': customerInfo.entitlements.active.values.first.expirationDate,
      }).eq('id', userId);

    } catch (e) {
      print('Error tracking purchase: $e');
    }
  }

  double _extractPrice(EntitlementInfo entitlement) {
    // Parse price from product identifier
    // This is simplified - actual implementation needs RevenueCat product fetch
    final productId = entitlement.productIdentifier;
    
    if (productId.contains('adfree')) return 4.99;
    if (productId.contains('outfits')) return 1.99;
    if (productId.contains('celebrity')) return 2.99;
    
    return 0.0;
  }
}
```

---

## 🧪 Step 11: Testing

### Test in Sandbox

**iOS**:
1. Xcode → **Signing & Capabilities** → Use development team
2. Create sandbox test user in App Store Connect
3. Sign out of App Store on device
4. Run app → Attempt purchase
5. Sign in with sandbox account

**Android**:
1. Add test Gmail account in Play Console
2. Use internal testing track
3. Install app from Play Store (internal test)
4. Attempt purchase
5. Use test card

### RevenueCat Test Mode

RevenueCat automatically detects sandbox:
- iOS: Sandbox purchases tracked separately
- Android: License testing mode

Check purchases in RevenueCat dashboard under **Customers**.

---

## ✅ Pre-Launch Checklist

- [ ] RevenueCat account created
- [ ] iOS app linked to App Store Connect
- [ ] Android app linked to Google Play
- [ ] All 3 products created in stores
- [ ] Products linked to `premium` entitlement
- [ ] Default offering configured
- [ ] Flutter SDK integrated
- [ ] API keys in `.env` file
- [ ] Paywall UI implemented
- [ ] Premium gates added to features
- [ ] Restore purchases working
- [ ] Sandbox testing successful (iOS)
- [ ] Sandbox testing successful (Android)
- [ ] Analytics tracking implemented
- [ ] Webhooks configured (optional)

---

## 💰 Revenue Projections

**Month 1** (10K users):
- Free: 7,000 users
- Paid: 3,000 users (30% conversion)
- Revenue: 3,000 × $4.99 = **$14,970/month**

**Month 3** (50K users):
- Paid: 15,000 users
- Revenue: **$74,850/month**

**RevenueCat Fees**:
- Free tier: Up to $2, 500 tracked revenue
- Pro tier: $250/month for $10K tracked revenue
- Enterprise: Custom pricing

---

## 🐛 Common Issues

### Issue 1: "Product not found"

**Solution**: Ensure products are approved in stores and wait 24 hours for propagation

### Issue 2: "Purchase cancelled" immediately

**Solution**: Check sandbox account is signed in on device

### Issue 3: Subscription not restoring

**Solution**: Verify same Apple ID/Google account used for original purchase

---

## 🔗 Resources

- [RevenueCat Dashboard](https://app.revenuecat.com)
- [RevenueCat Flutter SDK](https://pub.dev/packages/purchases_flutter)
- [RevenueCat Docs](https://docs.revenuecat.com/)
- [App Store Connect](https://appstoreconnect.apple.com)
- [Google Play Console](https://play.google.com/console)

---

**Implementation Week**: Week 11 (from timeline)
**Estimated Time**: 2-3 days
**Critical for Revenue**: ✅ Yes
