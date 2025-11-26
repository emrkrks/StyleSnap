import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../providers/subscription_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(offeringsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/paywall_bg.jpg',
                ), // Placeholder
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Close Button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const Spacer(),

                // Header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.diamond_outlined,
                        size: 64,
                        color: Colors.amber,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Unlock Full Style Potential',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Get unlimited AI recommendations, ad-free experience, and exclusive styles.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Features List
                _buildFeatureItem(
                  Icons.check_circle,
                  'Unlimited AI Outfit Ideas',
                ),
                _buildFeatureItem(Icons.block, 'Ad-Free Experience'),
                _buildFeatureItem(Icons.star, 'Exclusive Style Packs'),

                const SizedBox(height: 32),

                // Subscription Options
                offeringsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (error, _) => Center(
                    child: Text(
                      'Error loading offers',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                  data: (offerings) {
                    if (offerings == null || offerings.current == null) {
                      return const Center(
                        child: Text(
                          'No offers available',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final availablePackages =
                        offerings.current!.availablePackages;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: availablePackages.map((package) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildSubscriptionButton(package),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),

                // Restore Purchases
                TextButton(
                  onPressed: _restorePurchases,
                  child: const Text(
                    'Restore Purchases',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionButton(Package package) {
    final product = package.storeProduct;
    final isAnnual = package.packageType == PackageType.annual;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _purchasePackage(package),
        style: ElevatedButton.styleFrom(
          backgroundColor: isAnnual ? Colors.amber : Colors.white,
          foregroundColor: isAnnual ? Colors.black : Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          children: [
            Text(
              isAnnual ? 'BEST VALUE' : 'MOST FLEXIBLE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isAnnual ? Colors.black54 : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${product.priceString} / ${isAnnual ? 'Year' : 'Month'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (isAnnual)
              const Text(
                'Save 50%', // Placeholder discount logic
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchasePackage(Package package) async {
    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(subscriptionProvider.notifier)
          .purchasePackage(package);

      if (success && mounted) {
        Navigator.pop(context); // Close paywall on success
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Welcome to Premium! 🌟')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(subscriptionProvider.notifier)
          .restorePurchases();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchases restored successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No purchases found to restore')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
