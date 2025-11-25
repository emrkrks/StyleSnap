# StyleSnap - Affiliate Link System

## 🛍️ Overview

Complete implementation guide for affiliate shopping integration with Trendyol, Zara, H&M, Shein, and ASOS.

**Goal**: Generate $10K/month affiliate revenue at 50K users

---

## 🤝 Step 1: Affiliate Program Registration

### Trendyol Partner Network (Turkey)

**Sign Up**:
1. Go to [partner.trendyol.com](https://partner.trendyol.com)
2. **Become a Partner** → **Affiliate Marketing**
3. Fill application form
4. Provide:
   - Company/Individual details
   - Tax number (TC Kimlik or Vergi No)
   - Bank account (for payments)
5. **Submit** → Approval in 2-5 business days

**Commission Rates**:
- Fashion: 5-8%
- Shoes: 6-10%
- Accessories: 7-12%

**API Access**:
- Request API credentials via partner dashboard
- Get **Partner ID** and **API Key**

---

### Zara Affiliate (Global)

**Note**: Zara doesn't have direct affiliate program

**Workaround**:
1. Use **Awin** network: [awin.com](https://www.awin.com)
2. Sign up as publisher
3. Search for "Zara" in merchants
4. Apply to Zara program
5. Wait for approval (1-2 weeks)

**Alternative**: Use manual deep links (no commission tracking)

**Commission**: ~4-6%

---

### H&M Affiliate Program

**Sign Up**:
1. Via **Impact** network:  [impact.com](https://impact.com)
2. Or **Rakuten Advertising**: [rakutenadvertising.com](https://rakutenadvertising.com)
3. Apply as publisher
4. Search for "H&M" or "H&M Group"
5. Apply → Approval in 1 week

**Commission**: 5-8%

---

### Shein Affiliate

**Sign Up**:
1. [affiliate.shein.com](https://affiliate.shein.com)
2. **Join Now** → Fill form
3. Select region (Global, US, Europe, etc.)
4. Approval within 24-48 hours

**Commission**: 10-15% (highest!)

**API**: Basic product search API available

---

### ASOS Affiliate

**Sign Up**:
1. Via **Awin**: [awin.com](https://www.awin.com)
2. Search for "ASOS"
3. Apply to program
4. Approval in 1 week

**Commission**: 6-10%

**API**: Product search via partner links

---

## 🔧 Step 2: Flutter Implementation

### Affiliate Service

**lib/services/affiliate_service.dart**:
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class AffiliateService {
  // Partner IDs (from .env)
  static const String trendyolPartnerId = 'YOUR_TRENDYOL_PARTNER_ID';
  static const String sheinAffiliateId = 'YOUR_SHEIN_AFFILIATE_ID';
  
  /// Search for affiliate products
  Future<List<AffiliateProduct>> searchProducts({
    required String category,
    required String query,
    String? color,
    String? partner,
  }) async {
    final products = <AffiliateProduct>[];

    // Search each partner
    if (partner == null || partner == 'trendyol') {
      products.addAll(await _searchTrendyol(query, category, color));
    }

    if (partner == null || partner == 'shein') {
      products.addAll(await _searchShein(query, category, color));
    }

    if (partner == null || partner == 'hm') {
      products.addAll(await _searchHM(query, category));
    }

    if (partner == null || partner == 'zara') {
      products.addAll(await _searchZara(query, category));
    }

    if (partner == null || partner == 'asos') {
      products.addAll(await _searchAsos(query, category));
    }

    return products;
  }

  /// Trendyol API Search
  Future<List<AffiliateProduct>> _searchTrendyol(
    String query,
    String category,
    String? color,
  ) async {
    try {
      // Trendyol Partner API
      final url = Uri.parse(
        'https://api.trendyol.com/sapigw/product/api/v1/search'
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY',
        },
        body: json.encode({
          'query': query,
          'category': category,
          'color': color,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['result']['products'] as List;

        return results.map((item) {
          return AffiliateProduct(
            name: item['name'],
            imageUrl: item['images'][0],
            price: double.parse(item['price'].toString()),
            currency: 'TRY',
            storeId: 'trendyol',
            storeName: 'Trendyol',
            affiliateUrl: _generateTrendyolAffiliateLink(item['url']),
            productUrl: item['url'],
          );
        }).toList();
      }
    } catch (e) {
      print('Error searching Trendyol: $e');
    }

    return [];
  }

  /// Shein API Search
  Future<List<AffiliateProduct>> _searchShein(
    String query,
    String category,
    String? color,
  ) async {
    try {
      // Shein Affiliate API
      final url = Uri.parse(
        'https://affiliate-api.shein.com/v1/products/search'
      );

      final response = await http.get(
        url.replace(queryParameters: {
          'api_key': 'YOUR_SHEIN_API_KEY',
          'query': query,
          'category': _mapCategoryToShein(category),
          'limit': '20',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['data']['products'] as List;

        return items.map((item) {
          return AffiliateProduct(
            name: item['goods_name'],
            imageUrl: item['goods_img'],
            price: double.parse(item['salePrice']['amount']),
            currency: item['salePrice']['currency'],
            storeId: 'shein',
            storeName: 'SHEIN',
            affiliateUrl: _generateSheinAffiliateLink(item['goods_url_name']),
            productUrl: item['goods_url'],
          );
        }).toList();
      }
    } catch (e) {
      print('Error searching Shein: $e');
    }

    return [];
  }

  /// H&M Fallback (Manual search, no API)
  Future<List<AffiliateProduct>> _searchHM(
    String query,
    String category,
  ) async {
    // H&M doesn't provide public API
    // Fallback: Generate search URL with affiliate tracking

    final searchUrl = 'https://www2.hm.com/search?q=${Uri.encodeComponent(query)}';
    
    // Return manual link (user clicks, we get  commission)
    return [
      AffiliateProduct(
        name: 'Search "${query}" on H&M',
        imageUrl: 'https://via.placeholder.com/300?text=H%26M',
        price: 0,
        currency: 'USD',
        storeId: 'hm',
        storeName: 'H&M',
        affiliateUrl: _generateHMAffiliateLink(searchUrl),
        productUrl: searchUrl,
        isSearchLink: true,
      ),
    ];
  }

  /// Zara Fallback (Manual search)
  Future<List<AffiliateProduct>> _searchZara(
    String query,
    String category,
  ) async {
    // Zara has no API or affiliate program
    // Fallback: Direct link (no commission)

    final searchUrl = 'https://www.zara.com/search?searchTerm=${Uri.encodeComponent(query)}';

    return [
      AffiliateProduct(
        name: 'Search "${query}" on Zara',
        imageUrl: 'https://via.placeholder.com/300?text=Zara',
        price: 0,
        currency: 'USD',
        storeId: 'zara',
        storeName: 'Zara',
        affiliateUrl: searchUrl, // No affiliate (Zara doesn't have program)
        productUrl: searchUrl,
        isSearchLink: true,
      ),
    ];
  }

  /// ASOS via Awin
  Future<List<AffiliateProduct>> _searchAsos(
    String query,
    String category,
  ) async {
    // ASOS via Awin network
    // Use Awin Product API

    try {
      final url = Uri.parse(
        'https://productapi.awin.com/search'
      );

      final response = await http.get(
        url.replace(queryParameters: {
          'advertiserId': 'ASOS_ADVERTISER_ID', // From Awin
          'query': query,
          'category': category,
        }),
        headers: {
          'Authorization': 'Bearer YOUR_AWIN_API_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List;

        return products.map((item) {
          return AffiliateProduct(
            name: item['product_name'],
            imageUrl: item['image_url'],
            price: double.parse(item['price'].toString()),
            currency: item['currency'],
            storeId: 'asos',
            storeName: 'ASOS',
            affiliateUrl: _generateAwinAffiliateLink(item['aw_deep_link']),
            productUrl: item['merchant_product_url'],
          );
        }).toList();
      }
    } catch (e) {
      print('Error searching ASOS: $e');
    }

    return [];
  }

  /// Generate Trendyol affiliate link
  String _generateTrendyolAffiliateLink(String productUrl) {
    // Trendyol partner link format
    return '$productUrl?boutiqueId=$trendyolPartnerId';
  }

  /// Generate Shein affiliate link
  String _generateSheinAffiliateLink(String productSlug) {
    // Shein affiliate link format
    return 'https://api-shein.shein.com/h5/sharejump/appsharejump'
        '?lan=en&share_type=goods&site=iosshus&localcountry=us'
        '&appuid=$sheinAffiliateId&goods_id=$productSlug';
  }

  /// Generate H&M affiliate link (via Impact/Rakuten)
  String _generateHMAffiliateLink(String url) {
    // Via Impact network
    final encodedUrl = Uri.encodeComponent(url);
    return 'https://click.linksynergy.com/deeplink?id=YOUR_IMPACT_ID&mid=YOUR_HM_MID&murl=$encodedUrl';
  }

  /// Generate Awin affiliate link
  String _generateAwinAffiliateLink(String deepLink) {
    // Awin provides deep links directly
    return deepLink; // Already contains affiliate tracking
  }

  /// Map category to Shein category IDs
  String _mapCategoryToShein(String category) {
    switch (category.toLowerCase()) {
      case 'tops':
        return '1727'; // Shein tops category
      case 'bottoms':
        return '1728';
      case 'dresses':
        return '1721';
      case 'shoes':
        return '1729';
      default:
        return '1730'; // All clothing
    }
  }
}

/// Affiliate Product Model
class AffiliateProduct {
  final String name;
  final String imageUrl;
  final double price;
  final String currency;
  final String storeId;
  final String storeName;
  final String affiliateUrl;
  final String productUrl;
  final bool isSearchLink;

  AffiliateProduct({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.currency,
    required this.storeId,
    required this.storeName,
    required this.affiliateUrl,
    required this.productUrl,
    this.isSearchLink = false,
  });
}
```

---

## 📊 Step 3: Click Tracking

Track affiliate clicks in database for analytics:

**lib/services/affiliate_click_tracker.dart**:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AffiliateClickTracker {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Track click and open affiliate link
  Future<void> trackAndOpenLink({
    required AffiliateProduct product,
    String? sourceOutfitId,
    String? sourceClothingId,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      // Track click in database
      await _supabase.from('affiliate_clicks').insert({
        'user_id': userId,
        'partner': product.storeId,
        'product_url': product.productUrl,
        'affiliate_url': product.affiliateUrl,
        'product_name': product.name,
        'product_price': product.price,
        'product_currency': product.currency,
        'source_outfit_id': sourceOutfitId,
        'source_clothing_id': sourceClothingId,
      });

      // Open affiliate link
      final url = Uri.parse(product.affiliateUrl);
      
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // Open in browser/app
        );
      } else {
        throw 'Could not launch $url';
      }

    } catch (e) {
      print('Error tracking affiliate click: $e');
      rethrow;
    }
  }

  /// Track conversion (webhook from partner)
  Future<void> trackConversion({
    required String clickId,
    required double conversionAmount,
    required double commissionEarned,
  }) async {
    try {
      await _supabase
          .from('affiliate_clicks')
          .update({
            'converted': true,
            'conversion_amount': conversionAmount,
            'commission_earned': commissionEarned,
          })
          .eq('id', clickId);

    } catch (e) {
      print('Error tracking conversion: $e');
    }
  }
}
```

---

## 🎨 Step 4: UI Implementation

### Shopping Screen

**lib/features/shopping/screens/shopping_screen.dart**:
```dart
import 'package:flutter/material.dart';

class ShoppingScreen extends StatefulWidget {
  final String? missingCategory; // e.g., "shoes" from outfit
  final String? colorHint;

  const ShoppingScreen({
    Key? key,
    this.missingCategory,
    this.colorHint,
  }) : super(key: key);

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final AffiliateService _affiliateService = AffiliateService();
  final AffiliateClickTracker _clickTracker = AffiliateClickTracker();

  List<AffiliateProduct> _products = [];
  bool _isLoading = false;
  String _selectedPartner = 'all';
  
  @override
  void initState() {
    super.initState();
    if (widget.missingCategory != null) {
      _searchProducts();
    }
  }

  Future<void> _searchProducts() async {
    setState(() => _isLoading = true);

    final products = await _affiliateService.searchProducts(
      category: widget.missingCategory ?? 'all',
      query: widget.missingCategory ?? 'clothing',
      color: widget.colorHint,
      partner: _selectedPartner == 'all' ? null : _selectedPartner,
    );

    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Missing Items'),
      ),
      body: Column(
        children: [
          // Partner filter
          _buildPartnerFilter(),

          // Products grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          _buildFilterChip('Trendyol', 'trendyol'),
          _buildFilterChip('SHEIN', 'shein'),
          _buildFilterChip('H&M', 'hm'),
          _buildFilterChip('Zara', 'zara'),
          _buildFilterChip('ASOS', 'asos'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedPartner == value;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedPartner = value);
          _searchProducts();
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_products.isEmpty) {
      return const Center(
        child: Text('No products found'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_products[index]);
      },
    );
  }

  Widget _buildProductCard(AffiliateProduct product) {
    return GestureDetector(
      onTap: () => _openProduct(product),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: product.isSearchLink
                      ? null
                      : DecorationImage(
                          image: NetworkImage(product.imageUrl),
                          fit: BoxFit.cover,
                        ),
                  color: Colors.grey[200],
                ),
                child: product.isSearchLink
                    ? Center(
                        child: Icon(
                          Icons.search,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      )
                    : null,
              ),
            ),

            // Product info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStoreColor(product.storeId),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.storeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Product name
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),

                  const SizedBox(height: 4),

                  // Price
                  if (!product.isSearchLink)
                    Text(
                      '${product.price.toStringAsFixed(2)} ${product.currency}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStoreColor(String storeId) {
    switch (storeId) {
      case 'trendyol':
        return Colors.orange;
      case 'shein':
        return Colors.black;
      case 'hm':
        return Colors.red;
      case 'zara':
        return Colors.blueGrey;
      case 'asos':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _openProduct(AffiliateProduct product) async {
    await _clickTracker.trackAndOpenLink(product: product);
  }
}
```

---

## 📈 Step 5: Revenue Analytics

### Dashboard for Tracking

**lib/features/admin/affiliate_dashboard.dart**:
```dart
class AffiliateDashboard extends StatelessWidget {
  Future<Map<String, dynamic>> _getAffiliateStats() async {
    final supabase = Supabase.instance.client;

    // Total clicks
    final clicksResponse = await supabase
        .from('affiliate_clicks')
        .select('count');
    final totalClicks = clicksResponse.count;

    // Total conversions
    final conversionsResponse = await supabase
        .from('affiliate_clicks')
        .select('commission_earned')
        .eq('converted', true);
    
    final totalCommission = conversionsResponse.fold<double>(
      0.0,
      (sum, row) => sum + (row['commission_earned'] as double),
    );

    // Clicks by partner
    final partnerStats = await supabase
        .from('affiliate_clicks')
        .select('partner, count')
        .groupBy(['partner']);

    return {
      'total_clicks': totalClicks,
      'total_commission': totalCommission,
      'partner_stats': partnerStats,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getAffiliateStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircleularProgressIndicator();
        }

        final stats = snapshot.data!;

        return Column(
          children: [
            Text('Total Clicks: ${stats['total_clicks']}'),
            Text('Total Commission: \$${stats['total_commission']}'),
            // ... more stats
          ],
        );
      },
    );
  }
}
```

---

## 💰 Revenue Estimates

**Commission Rates**:
- Trendyol: 7% average
- Shein: 12% average
- H&M: 6% average
- Zara: N/A (no program)
- ASOS: 8% average

**Projections** (50K users):
- Monthly affiliate clicks: 10,000
- Conversion rate: 10%
- Average purchase: $50
- Total sales: $50K/month
- **Commission earned**: $4-6K/month

---

## ✅ Implementation Checklist

- [ ] Register for Trendyol Partner
- [ ] Register for Shein Affiliate
- [ ] Join Awin network (H&M, ASOS)
- [ ] Get all API keys and partner IDs
- [ ] Implement `AffiliateService`
- [ ] Implement `AffiliateClickTracker`
- [ ] Build shopping screen UI
- [ ] Add click tracking to database
- [ ] Test affiliate links (all 5 partners)
- [ ] Verify commission tracking
- [ ] Add analytics dashboard

---

## 🐛 Troubleshooting

### Issue: "Affiliate link not tracking"

**Solution**: Ensure user clicks → opens in external browser (not in-app webview)

### Issue: "No products returned from API"

**Solution**: Check API keys, verify account approved, check rate limits

---

**Implementation Week**: Week 9 (from timeline)
**Revenue Potential**: $4-10K/month
**Critical for Monetization**: ✅ Yes
