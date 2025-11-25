# StyleSnap - Social Sharing Implementation

## 📱 Overview

Complete implementation guide for one-tap social sharing to Instagram and TikTok with watermarked images for viral growth.

**Goal**: 20% of users share monthly → K-factor 1.2 → Viral growth

---

## 📦 Required Packages

**pubspec.yaml**:
```yaml
dependencies:
  share_plus: ^9.0.0
  path_provider: ^2.1.2
  image: ^4.1.7
  flutter_cache_manager: ^3.3.1
```

---

## 🎨 Step 1: Watermark Generation

### WatermarkService

**lib/services/watermark_service.dart**:
```dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class WatermarkService {
  /// Add watermark to outfit image
  Future<File> addWatermark(
    File sourceImage, {
    WatermarkPosition position = WatermarkPosition.bottomRight,
    double opacity = 0.8,
  }) async {
    try {
      // Load source image
      final sourceBytes = await sourceImage.readAsBytes();
      img.Image? image = img.decodeImage(sourceBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Load watermark logo (from assets)
      final logoData = await rootBundle.load('assets/images/watermark_logo.png');
      final logoBytes = logoData.buffer.asUint8List();
      img.Image? logo = img.decodeImage(logoBytes);

      if (logo == null) {
        throw Exception('Failed to load watermark logo');
      }

      // Resize logo (10% of image width)
      final logoWidth = (image.width * 0.10).toInt();
      logo = img.copyResize(
        logo,
        width: logoWidth,
        interpolation: img.Interpolation.linear,
      );

      // Calculate position
      final position Coordinates = _calculatePosition(
        image,
        logo,
        position,
      );

      // Composite with opacity
      image = img.compositeImage(
        image,
        logo,
        dstX: positionCoordinates.x,
        dstY: positionCoordinates.y,
        blend: img.BlendMode.screen,
      );

      // Add text watermark
      image = _addTextWatermark(
        image,
        text: 'StyleSnap',
        position: position,
      );

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final watermarkedFile = File('${tempDir.path}/watermarked_$timestamp.jpg');
      
      final outputBytes = img.encodeJpg(image, quality: 95);
      await watermarkedFile.writeAsBytes(outputBytes);

      return watermarkedFile;

    } catch (e) {
      print('Error adding watermark: $e');
      rethrow;
    }
  }

  /// Calculate watermark position
  _PositionCoordinates _calculatePosition(
    img.Image image,
    img.Image logo,
    WatermarkPosition position,
  ) {
    const padding = 20;

    switch (position) {
      case WatermarkPosition.topLeft:
        return _PositionCoordinates(padding, padding);
      
      case WatermarkPosition.topRight:
        return _PositionCoordinates(
          image.width - logo.width - padding,
          padding,
        );
      
      case WatermarkPosition.bottomLeft:
        return _PositionCoordinates(
          padding,
          image.height - logo.height - padding,
        );
      
      case WatermarkPosition.bottomRight:
        return _PositionCoordinates(
          image.width - logo.width - padding,
          image.height - logo.height - padding,
        );
      
      case WatermarkPosition.center:
        return _PositionCoordinates(
          (image.width - logo.width) ~/ 2,
          (image.height - logo.height) ~/ 2,
        );
    }
  }

  /// Add text watermark
  img.Image _addTextWatermark(
    img.Image image, {
    required String text,
    required WatermarkPosition position,
  }) {
    final textX = position == WatermarkPosition.bottomRight
        ? image.width - 150
        : 30;
    
    final textY = position == WatermarkPosition.bottomRight
        ? image.height - 50
        : image.height - 50;

    return img.drawString(
      image,
      text,
      font: img.arial24,
      x: textX,
      y: textY,
      color: img.ColorRgba8(255, 255, 255, 200), // Semi-transparent white
    );
  }

  /// Create shareable image with outfit composite
  Future<File> createShareableOutfitImage({
    required List<File> itemImages,
    String? outfitName,
  }) async {
    // Create canvas
    const canvasWidth = 1080;
    const canvasHeight = 1920; // Instagram Story size

    // Create base image
    img.Image canvas = img.Image(
      width: canvasWidth,
      height: canvasHeight,
    );

    // Fill with gradient background
    canvas = _fillGradient(canvas);

    // Add outfit name
    if (outfitName != null) {
      canvas = img.drawString(
        canvas,
        outfitName,
        font: img.arial48,
        x: 50,
        y: 50,
        color: img.ColorRgba8(255, 255, 255, 255),
      );
    }

    // Arrange item images in grid
    canvas = await _arrangeItemsInGrid(canvas, itemImages);

    // Add watermark
    final tempFile = File('${(await getTemporaryDirectory()).path}/temp_outfit.jpg');
    await tempFile.writeAsBytes(img.encodeJpg(canvas));

    return await addWatermark(tempFile);
  }

  /// Fill canvas with gradient
  img.Image _fillGradient(img.Image canvas) {
    // Purple to Pink gradient
    for (int y = 0; y < canvas.height; y++) {
      final ratio = y / canvas.height;
      
      // Interpolate between purple and pink
      final r = (139 + (ratio * (236 - 139))).toIn();
      final g = (92 + (ratio * (72 - 92))).toInt();
      final b = (246 + (ratio * (153 - 246))).toInt();

      for (int x = 0; x < canvas.width; x++) {
        canvas.setPixel(x, y, img.ColorRgba8(r, g, b, 255));
      }
    }

    return canvas;
  }

  /// Arrange clothing items in grid on canvas
  Future<img.Image> _arrangeItemsInGrid(
    img.Image canvas,
    List<File> itemImages,
  ) async {
    const itemSize = 300;
    const padding = 20;
    const startY = 150;

    int x = padding;
    int y = startY;
    int itemsPerRow = 3;
    int currentItem = 0;

    for (final itemFile in itemImages) {
      final itemBytes = await itemFile.readAsBytes();
      img.Image? item = img.decodeImage(itemBytes);

      if (item != null) {
        // Resize item
        item = img.copyResize(item, width: itemSize, height: itemSize);

        // Composite onto canvas
        canvas = img.compositeImage(canvas, item, dstX: x, dstY: y);

        // Calculate next position
        currentItem++;
        if (currentItem % itemsPerRow == 0) {
          x = padding;
          y += itemSize + padding;
        } else {
          x += itemSize + padding;
        }
      }
    }

    return canvas;
  }
}

enum WatermarkPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center,
}

class _PositionCoordinates {
  final int x;
  final int y;

  _PositionCoordinates(this.x, this.y);
}
```

---

## 📲 Step 2: Social Platform Integration

### SocialSharingService

**lib/services/social_sharing_service.dart**:
```dart
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SocialSharingService {
  final WatermarkService _watermarkService = WatermarkService();
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Share outfit to Instagram Stories
  Future<bool> shareToInstagramStories({
    required File outfitImage,
    required String outfitId,
  }) async {
    try {
      // Add watermark
      final watermarkedImage = await _watermarkService.addWatermark(
        outfitImage,
        position: WatermarkPosition.bottomRight,
      );

      // Generate deep link
      final deepLinkCode = await _generateDeepLink(outfitId);

      // Share via share_plus (opens Instagram share sheet)
      final result = await Share.shareXFiles(
        [XFile(watermarkedImage.path)],
        text: 'Check out my outfit on StyleSnap! Download: $deepLinkCode',
      );

      // Track share
      await _trackShare(
        platform: 'instagram',
        outfitId: outfitId,
        deepLinkCode: deepLinkCode,
      );

      return result.status == ShareResultStatus.success;

    } catch (e) {
      print('Error sharing to Instagram: $e');
      return false;
    }
  }

  /// Share outfit to TikTok
  Future<bool> shareToTikTok({
    required File outfitImage,
    required String outfitId,
  }) async {
    try {
      final watermarkedImage = await _watermarkService.addWatermark(
        outfitImage,
      );

      final deepLinkCode = await _generateDeepLink(outfitId);

      final result = await Share.shareXFiles(
        [XFile(watermarkedImage.path)],
        text: 'My AI-styled outfit 🤖✨ Created with StyleSnap\n'
            'Download: $deepLinkCode\n'
            '#StyleSnap #OOTD #AIFashion',
      );

      await _trackShare(
        platform: 'tiktok',
        outfitId: outfitId,
        deepLinkCode: deepLinkCode,
      );

      return result.status == ShareResultStatus.success;

    } catch (e) {
      print('Error sharing to TikTok: $e');
      return false;
    }
  }

  /// Generic share (WhatsApp, Twitter, etc.)
  Future<bool> shareGeneric({
    required File outfitImage,
    required String outfitId,
  }) async {
    try {
      final watermarkedImage = await _watermarkService.addWatermark(
        outfitImage,
      );

      final deepLinkCode = await _generateDeepLink(outfitId);

      final result = await Share.shareXFiles(
        [XFile(watermarkedImage.path)],
        text: 'Check out my outfit styled by AI! Get StyleSnap: $deepLinkCode',
        subject: 'My StyleSnap Outfit',
      );

      await _trackShare(
        platform: 'other',
        outfitId: outfitId,
        deepLinkCode: deepLinkCode,
      );

      return result.status == ShareResultStatus.success;

    } catch (e) {
      print('Error sharing: $e');
      return false;
    }
  }

  /// Generate deep link for attribution
  Future<String> _generateDeepLink(String outfitId) async {
    // Generate unique code
    final code = const Uuid().v4().substring(0, 8);

    // Create short link (use Firebase Dynamic Links or Branch.io)
    // For MVP, use simple URL scheme
    final deepLink = 'https://stylesnap.app/o/$code';

    // Store in database for tracking
    await _supabase.from('social_shares').insert({
      'deep_link_code': code,
      'outfit_id': outfitId,
      'user_id': _supabase.auth.currentUser!.id,
    });

    return deepLink;
  }

  /// Track share in database
  Future<void> _trackShare({
    required String platform,
    required String outfitId,
    required String deepLinkCode,
  }) async {
    try {
      // Find existing share record
      final existingShare = await _supabase
          .from('social_shares')
          .select()
          .eq('deep_link_code', deepLinkCode)
          .maybeSingle();

      if (existingShare != null) {
        // Update with platform
        await _supabase
            .from('social_shares')
            .update({'platform': platform})
            .eq('deep_link_code', deepLinkCode);
      }

    } catch (e) {
      print('Error tracking share: $e');
    }
  }

  /// Upload shareable image to cloud (optional, for sharing via URL)
  Future<String> uploadShareImage(File imageFile, String outfitId) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final fileName = '${outfitId}_share.jpg';
      final filePath = '$userId/shared/$fileName';

      await _supabase.storage
          .from('outfit-images')
          .upload(filePath, imageFile, fileOptions: const FileOptions(
            upsert: true,
          ));

      final publicUrl = _supabase.storage
          .from('outfit-images')
          .getPublicUrl(filePath);

      return publicUrl;

    } catch (e) {
      print('Error uploading share image: $e');
      rethrow;
    }
  }
}
```

---

## 🎨 Step 3: Share Modal UI

**lib/widgets/share_modal.dart**:
```dart
import 'package:flutter/material.dart';
import 'dart:io';

class ShareModal extends StatefulWidget {
  final File outfitImage;
  final String outfitId;
  final String outfitName;

  const ShareModal({
    Key? key,
    required this.outfitImage,
    required this.outfitId,
    required this.outfitName,
  }) : super(key: key);

  @override
  State<ShareModal> createState() => _ShareModalState();
}

class _ShareModalState extends State<ShareModal> {
  final SocialSharingService _sharingService = SocialSharingService();
  
  WatermarkPosition _selectedPosition = WatermarkPosition.bottomRight;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          const Text(
            'Share Your Style',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Preview
          Container(
            height: 200,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: FileImage(widget.outfitImage),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Watermark position selector
          const Text('Watermark Position:'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildPositionChip('Top Left', WatermarkPosition.topLeft),
              _buildPositionChip('Top Right', WatermarkPosition.topRight),
              _buildPositionChip('Bottom Left', WatermarkPosition.bottomLeft),
              _buildPositionChip('Bottom Right', WatermarkPosition.bottomRight),
            ],
          ),

          const SizedBox(height: 24),

          // Platform buttons
          if (_isProcessing)
            const CircularProgressIndicator()
          else
            Column(
              children: [
                _buildPlatformButton(
                  icon: Icons.camera_alt,
                  label: 'Instagram Stories',
                  color: const Color(0xFFE4405F),
                  onTap: _shareToInstagram,
                ),
                const SizedBox(height: 12),
                _buildPlatformButton(
                  icon: Icons.music_note,
                  label: 'TikTok',
                  color: Colors.black,
                  onTap: _shareToTikTok,
                ),
                const SizedBox(height: 12),
                _buildPlatformButton(
                  icon: Icons.share,
                  label: 'More Options',
                  color: Colors.grey,
                  onTap: _shareGeneric,
                ),
              ],
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPositionChip(String label, WatermarkPosition position) {
    final isSelected = _selectedPosition == position;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedPosition = position);
      },
    );
  }

  Widget _buildPlatformButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _shareToInstagram() async {
    setState(() => _isProcessing = true);

    final success = await _sharingService.shareToInstagramStories(
      outfitImage: widget.outfitImage,
      outfitId: widget.outfitId,
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Shared to Instagram!'
                : 'Share cancelled or failed',
          ),
          backgroundColor: success ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  Future<void> _shareToTikTok() async {
    setState(() => _isProcessing = true);

    final success = await _sharingService.shareToTikTok(
      outfitImage: widget.outfitImage,
      outfitId: widget.outfitId,
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Shared to TikTok!'
                : 'Share cancelled',
          ),
        ),
      );
    }
  }

  Future<void> _shareGeneric() async {
    setState(() => _isProcessing = true);

    final success = await _sharingService.shareGeneric(
      outfitImage: widget.outfitImage,
      outfitId: widget.outfitId,
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}

/// Helper to show share modal
void showShareModal(
  BuildContext context, {
  required File outfitImage,
  required String outfitId,
  required String outfitName,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ShareModal(
      outfitImage: outfitImage,
      outfitId: outfitId,
      outfitName: outfitName,
    ),
  );
}
```

---

## 🔗 Step 4: Deep Link Handling

### Firebase Dynamic Links Setup (Optional but Recommended)

**pubspec.yaml**:
```yaml
dependencies:
  firebase_dynamic_links: ^5.5.6
```

**lib/services/deep_link_service.dart**:
```dart
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DeepLinkService {
  /// Create deep link for outfit
  Future<String> createOutfitDeepLink(String outfitId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://stylesnap.page.link',
      link: Uri.parse('https://stylesnap.app/outfit/$outfitId'),
      androidParameters: const AndroidParameters(
        packageName: 'com.stylesnap.app',
        minimumVersion: 1,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.stylesnap.app',
        minimumVersion: '1.0.0',
        appStoreId: 'YOUR_APP_STORE_ID',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Check out my outfit on StyleSnap!',
        description: 'AI-styled outfit',
        imageUrl: Uri.parse('https://stylesnap.app/og-image.jpg'),
      ),
    );

    final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance
        .buildShortLink(parameters);

    return shortLink.shortUrl.toString();
  }

  /// Handle incoming deep links
  void initDeepLinkListener(Function(String outfitId) onOutfitOpened) {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final Uri deepLink = dynamicLinkData.link;
      
      // Parse outfit ID from link
      if (deepLink.pathSegments.contains('outfit')) {
        final outfitId = deepLink.pathSegments.last;
        onOutfitOpened(outfitId);
      }
    });
  }

  /// Handle initial deep link (app opened via link)
  Future<void> handleInitialLink(Function(String outfitId) onOutfitOpened) async {
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();

    if (initialLink != null) {
      final Uri deepLink = initialLink.link;
      
      if (deepLink.pathSegments.contains('outfit')) {
        final outfitId = deepLink.pathSegments.last;
        onOutfitOpened(outfitId);
      }
    }
  }
}
```

---

## 📊 Step 5: Share Attribution & Analytics

### Track Share Performance

**lib/services/share_analytics_service.dart**:
```dart
class ShareAnalyticsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Record deep link click
  Future<void> recordDeepLinkClick(String deepLinkCode) async {
    try {
      await _supabase.rpc('increment_share_clicks', params: {
        'link_code': deepLinkCode,
      });

    } catch (e) {
      print('Error recording click: $e');
    }
  }

  /// Record app install from share
  Future<void> recordInstallFromShare(String deepLinkCode) async {
    try {
      await _supabase.rpc('increment_share_installs', params: {
        'link_code': deepLinkCode,
      });

      // Update user who shared (give reward)
      final share = await _supabase
          .from('social_shares')
          .select('user_id')
          .eq('deep_link_code', deepLinkCode)
          .maybeSingle();

      if (share != null) {
        await _grantReferralReward(share['user_id']);
      }

    } catch (e) {
      print('Error recording install: $e');
    }
  }

  /// Grant reward to referring user
  Future<void> _grantReferralReward(String userId) async {
    // Give 1 week premium or $1 credit
    await _supabase.from('users').update({
      'referral_credits': _supabase.from('users')
          .select('referral_credits')
          .eq('id', userId)
          .single()['referral_credits'] + 1.0,
    }).eq('id', userId);
  }

  /// Get share statistics
  Future<Map<String, dynamic>> getShareStats(String userId) async {
    final stats = await _supabase
        .from('social_shares')
        .select('platform, clicks, installs')
        .eq('user_id', userId);

    final totalShares = stats.length;
    final totalClicks = stats.fold<int>(0, (sum, s) => sum + (s['clicks'] as int));
    final totalInstalls = stats.fold<int>(0, (sum, s) => sum + (s['installs'] as int));

    return {
      'total_shares': totalShares,
      'total_clicks': totalClicks,
      'total_installs': totalInstalls,
      'conversion_rate': totalClicks > 0 ? totalInstalls / totalClicks : 0,
    };
  }
}
```

---

## 🎁 Step 6: Incentivize Sharing

### Gamification & Rewards

**Share Rewards System**:
```dart
class ShareRewardSystem {
  /// Check if user qualifies for reward
  Future<ShareReward?> checkRewardEligibility(String userId) async {
    final supabase = Supabase.instance.client;

    final shareCount = await supabase
        .from('social_shares')
        .select('count')
        .eq('user_id', userId)
        .count();

    // Milestone rewards
    if (shareCount == 1) {
      return ShareReward(
        type: 'unlock',
        description: 'First share! Unlocked 1 celebrity style pack',
        value: 'celebrity_pack_1',
      );
    } else if (shareCount == 5) {
      return ShareReward(
        type: 'premium_feature',
        description: '5 shares! Unlocked advanced analytics',
        value: 'analytics_unlocked',
      );
    } else if (shareCount == 10) {
      return ShareReward(
        type: 'free_month',
        description: '10 shares! Free month of premium',
        value: 'premium_1_month',
      );
    }

    return null;
  }
}

class ShareReward {
  final String type;
  final String description;
  final String value;

  ShareReward({
    required this.type,
    required this.description,
    required this.value,
  });
}
```

---

## 📱 Step 7: Platform-Specific Optimizations

### Instagram Stories Best Practices

1. **Image Size**: 1080x1920 (9:16 aspect ratio)
2. **Safe Area**: Keep important content in center 1080x1480
3. **File Size**: <10MB
4. **Format**: JPG or PNG

### TikTok Content Guidelines

1. **Video preferred** over static image
2. **Aspect ratio**: 9:16  (vertical)
3. **Hashtags**: Include trending + branded (#StyleSnap)
4. **CTA**: Clear call-to-action in caption

---

## ✅ Testing Checklist

- [ ] Watermark appears correctly on image
- [ ] Watermark position customization works
- [ ] Share to Instagram opens correct app
- [ ] Share to TikTok opens correct app
- [ ] Generic share shows system share sheet
- [ ] Deep links generated and tracked
- [ ] Share tracking saved to database
- [ ] Referral rewards granted correctly
- [ ] Image quality maintained after watermarking
- [ ] Sharing works on iOS
- [ ] Sharing works on Android

---

## 🎯 Growth Targets

**Month 1**:
- 20% of users share at least once
- 1,000 shares total
- 100 click-throughs
- 10 app installs from shares

**Month 3**:
- 30% share rate
- 15,000 shares total
- 3,000 clicks
- 300 installs (K-factor = 0.6)

**Month 6**:
- 35% share rate
- 100,000 shares
- 30,000 clicks
- 6,000 installs (K-factor = 1.2) ✅ Viral!

---

## 💡 Viral Loop Optimization

### A/B Tests

1. **Watermark Style**
   - Variant A: Logo only
   - Variant B: Logo + text
   - Measure: Share rate

2. **CTA Text**
   - Variant A: "Created with StyleSnap"
   - Variant B: "Get your AI stylist"
   - Measure: Click-through rate

3. **Reward Timing**
   - Variant A: Reward after 1st share
   - Variant B: Reward after 3rd share
   - Measure: Total shares per user

---

## 🔗 Resources

- [share_plus Package](https://pub.dev/packages/share_plus)
- [Firebase Dynamic Links](https://firebase.google.com/docs/dynamic-links)
- [Instagram Best Practices](https://developers.facebook.com/docs/instagram)

---

**Implementation Week**: Week 10 (from timeline)
**Critical for Growth**: ✅ Yes (viral loop)
**Expected K-Factor**: 1.2+ (sustainable viral growth)
