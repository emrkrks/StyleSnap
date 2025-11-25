import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/clothing_item.dart';

/// Screen for reviewing and editing AI-analyzed clothing item
class ClothingReviewScreen extends ConsumerWidget {
  final ClothingItem clothingItem;

  const ClothingReviewScreen({super.key, required this.clothingItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Item'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Item already saved, just go back
              Navigator.popUntil(context, (route) => route.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item added to wardrobe!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: clothingItem.imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.grey200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // AI Confidence
            _buildConfidenceBadge(clothingItem.aiConfidence),
            const SizedBox(height: 24),

            // Category
            _buildSection(
              'Category',
              Text(
                '${clothingItem.category} ${clothingItem.subcategory != null ? '• ${clothingItem.subcategory}' : ''}',
                style: AppTextStyles.titleMedium,
              ),
            ),
            const SizedBox(height: 16),

            // Colors
            if (clothingItem.colors.isNotEmpty)
              _buildSection(
                'Colors',
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: clothingItem.colors.map((color) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: Color(
                          int.parse(color.hex.replaceFirst('#', '0xFF')),
                        ),
                      ),
                      label: Text('${color.name} (${color.percentage}%)'),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 16),

            // Patterns
            if (clothingItem.patterns.isNotEmpty)
              _buildSection(
                'Patterns',
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: clothingItem.patterns
                      .map((p) => Chip(label: Text(p)))
                      .toList(),
                ),
              ),
            const SizedBox(height: 16),

            // Materials
            if (clothingItem.materials.isNotEmpty)
              _buildSection(
                'Materials',
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: clothingItem.materials
                      .map((m) => Chip(label: Text(m)))
                      .toList(),
                ),
              ),
            const SizedBox(height: 16),

            // Seasons
            if (clothingItem.seasons.isNotEmpty)
              _buildSection(
                'Seasons',
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: clothingItem.seasons
                      .map((s) => Chip(label: Text(s)))
                      .toList(),
                ),
              ),
            const SizedBox(height: 16),

            // Styles
            if (clothingItem.styles.isNotEmpty)
              _buildSection(
                'Styles',
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: clothingItem.styles
                      .map((s) => Chip(label: Text(s)))
                      .toList(),
                ),
              ),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Implement edit functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit functionality coming soon!'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Edit Details'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Item added to wardrobe!'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Save to Wardrobe',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(double confidence) {
    final percentage = (confidence * 100).toInt();
    final color = confidence >= 0.8
        ? AppColors.success
        : confidence >= 0.6
        ? AppColors.warning
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            'AI Confidence: $percentage%',
            style: AppTextStyles.labelMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(color: AppColors.grey600),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
