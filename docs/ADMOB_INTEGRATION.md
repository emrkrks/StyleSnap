# StyleSnap - AdMob Reklam Entegrasyonu

## 💰 Reklam Stratejisi Özeti

**Hedef**: Free tier kullanıcılardan reklam geliri + Premium'a yönlendirme

**Gelir Beklentisi**: $3.50/user/ay (free users)

---

## 📱 Reklam Tipleri ve Yerleşimleri

### 1. Banner Ads (320x50)

**Konumlar**:
- Home Dashboard (alt, bottom navigation üstünde)
- Wardrobe Screen (sayfa altı, sticky)
- Recommendations Screen (liste sonunda)

**Gelir**: ~$0.50/user/ay
**eCPM**: $0.50-1.00

### 2. Interstitial Ads (Tam Ekran)

**Gösterim Zamanları**:
- 5. kıyafet eklendiğinde
- 3. outfit oluşturulduktan sonra
- Shopping ekranına her 3. girişte
- Maksimum: Günde 3-4 gösterim

**Gelir**: ~$1.50/user/ay
**eCPM**: $5-10

### 3. Native Ads (Feed İçi)

**Konumlar**:
- Outfit listesinde her 4 item'den sonra
- Wardrobe grid'inde her 12 item sonra
- Shopping grid'inde

**Gelir**: ~$0.80/user/ay
**eCPM**: $2-4

### 4. Rewarded Video Ads (Ödüllü)

**Ödüller**:
- 1 premium outfit pack (24 saat)
- 1 celebrity style (tek kullanım)
- Reklamsız 1 gün

**Konumlar**:
- Paywall'da "Watch ad for free premium"
- Profile'da "Earn Premium"

**Gelir**: ~$0.70/user/ay
**eCPM**: $15-25 (en yüksek)

---

## 🚀 AdMob Setup (Step by Step)

### Step 1: AdMob Hesabı Oluştur

1. [admob.google.com](https://admob.google.com) git
2. Google hesabınla giriş yap
3. "Get Started" tıkla
4. Ülke seç: **Turkey**
5. Para birimi: **USD** (recommend, global payments)

### Step 2: App Ekle

#### iOS App

1. **Apps** → **Add App** → **iOS**
2. App Store'da yayında mı? → **No** (henüz)
3. App name: **StyleSnap**
4. Platform: **iOS**
5. Oluştur

**App ID** not al: `ca-app-pub-XXXXXXXXXX~YYYYYYYYYY`

#### Android App

1. **Apps** → **Add App** → **Android**
2. Google Play'de yayında mı? → **No**
3. App name: **StyleSnap**
4. Package name: `com.stylesnap.app`
5. Oluştur

**App ID** not al: `ca-app-pub-XXXXXXXXXX~ZZZZZZZZZZ`

### Step 3: Ad Units Oluştur

Her app için 4 ad unit oluşturacağız:

#### iOS Ad Units

1. **Banner Ad**
   - Ad format: **Banner**
   - Ad unit name: `stylesnap_banner_ios`
   - ✅ Oluştur
   - **Ad Unit ID** not al: `ca-app-pub-XXX/1111111111`

2. **Interstitial Ad**
   - Ad format: **Interstitial**
   - Ad unit name: `stylesnap_interstitial_ios`
   - **Ad Unit ID** not al: `ca-app-pub-XXX/2222222222`

3. **Native Ad**
   - Ad format: **Native Advanced**
   - Ad unit name: `stylesnap_native_ios`
   - **Ad Unit ID** not al: `ca-app-pub-XXX/3333333333`

4. **Rewarded Ad**
   - Ad format: **Rewarded**
   - Ad unit name: `stylesnap_rewarded_ios`
   - Reward amount: `1` Premium Day
   - **Ad Unit ID** not al: `ca-app-pub-XXX/4444444444`

#### Android Ad Units (Tekrarla)

Aynı adımları Android app için tekrarla:
- `stylesnap_banner_android`
- `stylesnap_interstitial_android`
- `stylesnap_native_android`
- `stylesnap_rewarded_android`

---

## 📦 Flutter Entegrasyonu

### Step 1: Dependency Ekle

**pubspec.yaml**:
```yaml
dependencies:
  google_mobile_ads: ^5.1.0
```

Çalıştır:
```bash
flutter pub get
```

### Step 2: iOS Konfigürasyonu

**ios/Runner/Info.plist** dosyasına ekle:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXX~YYYYYYYYYY</string>
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
  <!-- Google provides full list -->
</array>
```

**Podfile** güncellemesi:
```bash
cd ios
pod install
```

### Step 3: Android Konfigürasyonu

**android/app/src/main/AndroidManifest.xml**:
```xml
<manifest>
  <application>
    <!-- AdMob App ID -->
    <meta-data
      android:name="com.google.android.gms.ads.APPLICATION_ID"
      android:value="ca-app-pub-XXXXXXXXXX~ZZZZZZZZZZ"/>
  </application>
</manifest>
```

### Step 4: Initialize AdMob

**lib/main.dart**:
```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AdMob
  await MobileAds.instance.initialize();
  
  runApp(const MyApp());
}
```

---

## 💻 Ad Service Implementation

### Ad Service Class

**lib/services/ad_service.dart**:
```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Ad Unit IDs
  static String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-XXX/1111111111'; // iOS Banner
    } else {
      return 'ca-app-pub-XXX/5555555555'; // Android Banner
    }
  }

  static String get interstitialAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-XXX/2222222222';
    } else {
      return 'ca-app-pub-XXX/6666666666';
    }
  }

  static String get rewardedAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-XXX/4444444444';
    } else {
      return 'ca-app-pub-XXX/8888888888';
    }
  }

  // Test Ad IDs (Development)
  static const String testBannerAdUnitId = 
    'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitId = 
    'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedAdUnitId = 
    'ca-app-pub-3940256099942544/5224354917';

  // State
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  
  bool _isBannerAdReady = false;
  bool _isInterstitialAdReady = false;
  bool _isRewardedAdReady = false;

  // Interstitial counter (don't show too often)
  int _interstitialCounter = 0;
  static const int _interstitialThreshold = 3;

  // Banner Ad
  Future<void> loadBannerAd() async {
    _bannerAd = BannerAd(
      adUnitId: kDebugMode ? testBannerAdUnitId : bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdReady = true;
          debugPrint('Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdReady = false;
          ad.dispose();
          debugPrint('Banner ad failed to load: $error');
        },
      ),
    );

    await _bannerAd!.load();
  }

  Widget? getBannerAdWidget() {
    if (_isBannerAdReady && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return null;
  }

  // Interstitial Ad
  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: kDebugMode ? testInterstitialAdUnitId : interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          debugPrint('Interstitial ad loaded');

          // Set full screen content callback
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          debugPrint('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  Future<void> showInterstitialAd({bool force = false}) async {
    if (!force) {
      _interstitialCounter++;
      if (_interstitialCounter < _interstitialThreshold) {
        debugPrint('Interstitial counter: $_interstitialCounter/$_interstitialThreshold');
        return;
      }
    }

    if (_isInterstitialAdReady && _interstitialAd != null) {
      await _interstitialAd!.show();
      _interstitialCounter = 0; // Reset counter
    } else {
      debugPrint('Interstitial ad not ready');
      await loadInterstitialAd(); // Load for next time
    }
  }

  // Rewarded Ad
  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: kDebugMode ? testRewardedAdUnitId : rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          debugPrint('Rewarded ad loaded');

          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd(); // Preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isRewardedAdReady = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdReady = false;
          debugPrint('Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  Future<bool> showRewardedAd({
    required Function(RewardItem) onUserEarnedReward,
  }) async {
    if (_isRewardedAdReady && _rewardedAd != null) {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
          onUserEarnedReward(reward);
        },
      );
      return true;
    } else {
      debugPrint('Rewarded ad not ready');
      await loadRewardedAd();
      return false;
    }
  }

  // Check if ads should be shown (premium user check)
  Future<bool> shouldShowAds() async {
    // TODO: Check RevenueCat subscription status
    // For now, return true
    return true;
  }

  // Dispose
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
```

---

## 🎨 UI Implementation Examples

### 1. Banner Ad Widget

**lib/widgets/banner_ad_widget.dart**:
```dart
import 'package:flutter/material.dart';
import '../services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  final AdService _adService = AdService();
  bool _showAds = true;

  @override
  void initState() {
    super.initState();
    _initAds();
  }

  Future<void> _initAds() async {
    final shouldShow = await _adService.shouldShowAds();
    setState(() => _showAds = shouldShow);
    
    if (_showAds) {
      await _adService.loadBannerAd();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showAds) return const SizedBox.shrink();

    final adWidget = _adService.getBannerAdWidget();
    
    if (adWidget == null) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.grey[100],
      child: SafeArea(
        top: false,
        child: adWidget,
      ),
    );
  }
}
```

**Kullanım** (Home Screen):
```dart
Scaffold(
  body: Column(
    children: [
      Expanded(child: HomeContent()),
      const BannerAdWidget(), // Banner at bottom
    ],
  ),
  bottomNavigationBar: BottomNavigationBar(...),
)
```

### 2. Interstitial Ad Trigger

**Kıyafet eklendiğinde**:
```dart
Future<void> addClothingItem(ClothingItem item) async {
  // Save to database
  await _supabase.from('clothes').insert(item.toJson());
  
  // Increment counter
  final itemCount = await getClothingItemCount();
  
  // Show interstitial after 5th item
  if (itemCount == 5) {
    final adService = AdService();
    await adService.showInterstitialAd();
  }
}
```

**Outfit oluşturulduğunda**:
```dart
Future<void> createOutfit(Outfit outfit) async {
  await _supabase.from('outfits').insert(outfit.toJson());
  
  final outfitCount = await getOutfitCount();
  
  if (outfitCount % 3 == 0) { // Every 3 outfits
    final adService = AdService();
    await adService.showInterstitialAd();
  }
}
```

### 3. Rewarded Ad Button

**lib/widgets/watch_ad_button.dart**:
```dart
import 'package:flutter/material.dart';
import '../services/ad_service.dart';

class WatchAdForPremiumButton extends StatelessWidget {
  final String rewardType; // 'outfit_pack', 'celebrity_style', 'ad_free_day'
  final VoidCallback onRewardEarned;

  const WatchAdForPremiumButton({
    Key? key,
    required this.rewardType,
    required this.onRewardEarned,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final adService = AdService();
        final success = await adService.showRewardedAd(
          onUserEarnedReward: (reward) {
            // Grant reward to user
            _grantReward(context);
            onRewardEarned();
          },
        );

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ad not ready, try again soon')),
          );
        }
      },
      icon: const Icon(Icons.play_circle_outline),
      label: const Text('Watch Ad for Free Premium'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  Future<void> _grantReward(BuildContext context) async {
    switch (rewardType) {
      case 'outfit_pack':
        // Unlock premium outfit pack for 24 hours
        await unlockPremiumOutfitPack();
        break;
      case 'celebrity_style':
        // Unlock one celebrity style
        await unlockCelebrityStyle();
        break;
      case 'ad_free_day':
        // Grant ad-free for 24 hours
        await grantAdFreeDay();
        break;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reward unlocked! Enjoy 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
```

**Paywall'da kullanım**:
```dart
Column(
  children: [
    // Premium subscription options
    PremiumPlanCard(),
    
    const SizedBox(height: 16),
    const Divider(),
    const Text('Or'),
    
    // Watch ad option
    WatchAdForPremiumButton(
      rewardType: 'ad_free_day',
      onRewardEarned: () {
        // Close paywall
        Navigator.pop(context);
      },
    ),
  ],
)
```

---

## 🎯 Ad Frequency & UX Best Practices

### Interstitial Rules

**DO**:
- ✅ Göster: Natural transition points (kaydetme sonrası, ekran değişimi)
- ✅ Maksimum günde 3-4
- ✅ İlk açılışta gösterme (kötü UX)
- ✅ Critical action'lardan önce gösterme

**DON'T**:
- ❌ Back button'a basarken
- ❌ Loading ekranında
- ❌ Her sayfa geçişinde

### Banner Placement

**Best Practices**:
- Alt kısımda (bottom navigation üstünde)
- Sticky (scroll'da görünür kal)
- Content'i örtme
- Close button yok (always-on banner)

### Native Ad Integration

**Seamless Integration**:
- Feed içinde doğal görünsün
- "Sponsored" label ekle (zorunlu)
- Aynı card design kullan
- Every 4-5 item'de bir göster

---

## 📊 Analytics & Tracking

### Revenue Tracking

**Mixpanel Events**:
```dart
void trackAdImpression(String adType) {
  mixpanel.track('Ad Impression', properties: {
    'ad_type': adType, // banner, interstitial, native, rewarded
    'user_id': currentUserId,
    'is_premium': false,
    'timestamp': DateTime.now().toIso8601String(),
  });
}

void trackAdClick(String adType) {
  mixpanel.track('Ad Clicked', properties: {
    'ad_type': adType,
    'user_id': currentUserId,
  });
}

void trackAdRevenue(String adType, double revenue) {
  mixpanel.track('Ad Revenue', properties: {
    'ad_type': adType,
    'revenue_usd': revenue,
    'user_id': currentUserId,
  });
}
```

### AdMob Mediation (Advanced)

Gelir optimize etmek için birden fazla ad network:

**Partners**:
- Facebook Audience Network
- Unity Ads
- AppLovin
- Vungle

**Setup**: AdMob dashboard → Mediation → Add ad sources

**Benefit**: 30-50% revenue increase (competitive bidding)

---

## 💰 Revenue Optimization

### eCPM Optimization Tips

1. **Geographic Targeting**
   - US/UK/CA: $5-10 eCPM
   - TR/ES: $1-3 eCPM
   - Tier 3 countries: $0.50-1 eCPM

2. **Ad Placement Testing**
   - A/B test banner positions
   - Test interstitial frequency
   - Optimize native ad density

3. **Ad Formats Priority**
   - Rewarded: Highest eCPM ($15-25)
   - Interstitial: Medium ($5-10)
   - Banner: Lowest ($0.50-1)
   - Strategy: Push rewarded ads

4. **Seasonal Optimization**
   - Ekim-Aralık: En yüksek eCPM (Tatil alışverişi)
   - Ocak-Mart: Düşük eCPM
   - Fashion weeks: Spike (partner ile)

---

## 🚀 Testing

### Test Ads (Development)

AdMob provides test ad units:

**Always use in development**:
```dart
static String get bannerAdUnitId {
  if (kDebugMode) {
    return 'ca-app-pub-3940256099942544/6300978111'; // Test ad
  }
  return 'ca-app-pub-YOUR-REAL-ID/1111111111'; // Production
}
```

**Test Devices**:
```dart
final testDevices = <String>[
  'YOUR_DEVICE_ID', // Add your test device
];

MobileAds.instance.updateRequestConfiguration(
  RequestConfiguration(testDeviceIds: testDevices),
);
```

### Pre-Launch Checklist

Before publishing:
- [ ] Replace test ad IDs with real ad IDs
- [ ] Test on real devices (not emulator)
- [ ] Verify premium users see NO ads
- [ ] Test all 4 ad types
- [ ] Check ad frequency limits
- [ ] Verify GDPR consent (EU users)
- [ ] Test revenue tracking (analytics)

---

## 📋 AdMob Policy Compliance

### Must Follow

1. **No accidental clicks**
   - Ad too close to buttons ❌
   - Minumum 50dp spacing ✅

2. **No incentivized clicks**
   - "Click this ad" ❌
   - Rewarded ads only for video completion ✅

3. **No ad placement**
   - On splash screen ❌
   - On empty/error screens ❌
   - During active gameplay/interaction ❌

4. **Content policy**
   - No adult content ✅
   - No violence ✅
   - Family-safe ✅ (StyleSnap is safe)

### GDPR Compliance (EU Users)

Use **User Messaging Platform (UMP)**:

```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> requestConsent() async {
  final params = ConsentRequestParameters();
  
  ConsentInformation.instance.requestConsentInfoUpdate(
    params,
    () async {
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        _loadConsentForm();
      }
    },
    (error) {
      debugPrint('Consent error: $error');
    },
  );
}

void _loadConsentForm() {
  ConsentForm.loadConsentForm(
    (consentForm) {
      if (ConsentInformation.instance.getConsentStatus() == 
          ConsentStatus.required) {
        consentForm.show((formError) {
          // User made choice
        });
      }
    },
    (formError) {
      debugPrint('Form error: $formError');
    },
  );
}
```

Call `requestConsent()` in `main()` before initializing ads.

---

## 📈 Expected Revenue (10K Users)

| User Type | Count | Revenue/User | Total |
|-----------|-------|--------------|-------|
| Free (ads) | 7,000 | $3.50/mo | $24,500 |
| Premium | 3,000 | $0 ads | $0 |
| **Total Ad Revenue** | - | - | **$24,500/mo** |

---

## ✅ Implementation Checklist

### Week 11 (Monetization Week)

- [ ] Create AdMob account
- [ ] Add iOS app to AdMob
- [ ] Add Android app to AdMob
- [ ] Create 4 ad units (iOS)
- [ ] Create 4 ad units (Android)
- [ ] Add `google_mobile_ads` dependency
- [ ] Configure iOS (Info.plist)
- [ ] Configure Android (AndroidManifest.xml)
- [ ] Implement `AdService` class
- [ ] Create banner ad widget
- [ ] Add interstitial triggers
- [ ] Implement rewarded ad flow
- [ ] Add premium check (no ads for paid users)
- [ ] Implement GDPR consent (EU)
- [ ] Test all ad types
- [ ] Setup analytics tracking
- [ ] Enable AdMob mediation (optional)
- [ ] Submit for AdMob review

### Testing

- [ ] Test banner ads on all screens
- [ ] Test interstitial frequency
- [ ] Test rewarded ad rewards grant
- [ ] Verify premium users see no ads
- [ ] Test on slow network
- [ ] Test ad loading errors (graceful fallback)
- [ ] Verify GDPR consent flow (VPN to EU)

---

## 🎯 Success Metrics

**Month 1** (10K users, 70% free):
- Ad impressions: 500K/month
- Click-through rate: 1-2%
- Revenue: $10K-15K

**Month 3** (50K users):
- Ad revenue: $50K-70K/month
- Premium conversion: 20-30%
- Total revenue: $100K+/month

---

## 🔗 Resources

- [AdMob Dashboard](https://admob.google.com)
- [Flutter AdMob Plugin](https://pub.dev/packages/google_mobile_ads)
- [AdMob Policy Center](https://support.google.com/admob/answer/6128543)
- [AdMob Best Practices](https://support.google.com/admob/answer/6128877)
- [Test Ad Units](https://developers.google.com/admob/flutter/test-ads)

---

**Last Updated**: November 2025
**Plugin Version**: google_mobile_ads ^5.1.0
**Estimated Setup Time**: 4-6 hours
