import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../models/outfit_recommendation.dart';
import '../../../models/outfit.dart';
import '../../../models/clothing_item.dart';
import '../providers/outfit_providers.dart';
import '../../../repositories/clothing_repository.dart';
import '../../wardrobe/screens/clothing_detail_screen.dart';
import '../widgets/outfit_share_preview.dart';
import '../../../services/screenshot_service.dart';
import '../../../services/share_service.dart';
import '../../../features/auth/providers/auth_providers.dart';

class OutfitDetailScreen extends ConsumerStatefulWidget {
  final OutfitRecommendation recommendation;

  const OutfitDetailScreen({super.key, required this.recommendation});

  @override
  ConsumerState<OutfitDetailScreen> createState() => _OutfitDetailScreenState();
}

class _OutfitDetailScreenState extends ConsumerState<OutfitDetailScreen> {
  List<ClothingItem> _clothingItems = [];
  bool _isLoading = true;
  final GlobalKey _shareKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadClothingItems();
  }

  Future<void> _loadClothingItems() async {
    final repository = ClothingRepository();
    final items = <ClothingItem>[];

    for (final recItem in widget.recommendation.items) {
      // Load each clothing item by ID
      try {
        final allItems = await repository.getUserClothingItems();
        final item = allItems.firstWhere((i) => i.id == recItem.itemId);
        items.add(item);
      } catch (e) {
        // Item not found
      }
    }

    setState(() {
      _clothingItems = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recommendation.outfitName),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Occasion Badge
                  Chip(
                    label: Text(widget.recommendation.occasion),
                    backgroundColor: theme.colorScheme.primaryContainer,
                  ),
                  const SizedBox(height: 24),

                  // Items Grid
                  Text(
                    'Items',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _clothingItems.length,
                    itemBuilder: (context, index) {
                      final item = _clothingItems[index];
                      final recItem = widget.recommendation.items[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ClothingDetailScreen(item: item),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Container(
                                    color: Colors.grey[100],
                                    child: item.thumbnailUrl != null
                                        ? Image.network(
                                            item.thumbnailUrl!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          )
                                        : const Icon(Icons.checkroom, size: 48),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.category,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (item.brand != null)
                                      Text(
                                        item.brand!,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: Colors.grey[600]),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Style Description
                  Text(
                    'Style Description',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.recommendation.styleDescription,
                    style: theme.textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 24),

                  // Scores
                  Text(
                    'Outfit Scores',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ScoreBar(
                    label: 'Weather Appropriateness',
                    score: widget.recommendation.weatherAppropriateness,
                    icon: Icons.wb_sunny,
                  ),
                  const SizedBox(height: 8),
                  _ScoreBar(
                    label: 'Style Score',
                    score: widget.recommendation.styleScore,
                    icon: Icons.style,
                  ),

                  const SizedBox(height: 24),

                  // Styling Tips
                  if (widget.recommendation.stylingTips.isNotEmpty) ...[
                    Text(
                      'Styling Tips',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.recommendation.stylingTips.map((tip) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tip,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],

                  // Missing Items
                  if (widget.recommendation.missingItems.isNotEmpty) ...[
                    Text(
                      'Complete Your Look',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.recommendation.missingItems.map((missing) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    missing.category,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    missing.description,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(
                                missing.priority,
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: missing.isHighPriority
                                  ? Colors.red[100]
                                  : missing.isMediumPriority
                                  ? Colors.orange[100]
                                  : Colors.blue[100],
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _saveOutfit(context),
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Save Outfit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _markWorn(context),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Worn Today'),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _shareOutfit,
        icon: const Icon(Icons.share),
        label: const Text('Share'),
      ),
    );
  }

  Future<void> _shareOutfit() async {
    try {
      // Get username
      final userAsync = ref.read(currentUserProvider);
      final username = await userAsync.when(
        data: (user) => user?.name ?? 'user',
        loading: () => 'user',
        error: (_, __) => 'user',
      );

      if (!mounted) return;

      // Show overlay with share preview
      final overlay = Overlay.of(context);
      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: -10000,
          top: -10000,
          child: RepaintBoundary(
            key: _shareKey,
            child: OutfitSharePreview(
              outfit: widget.recommendation,
              username: username,
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry);

      // Wait for render
      await Future.delayed(const Duration(milliseconds: 300));

      // Capture screenshot
      final file = await ScreenshotService.captureAndSave(
        _shareKey,
        'outfit_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Remove overlay
      overlayEntry.remove();

      if (file != null && mounted) {
        await ShareService.showShareDialog(context, file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to share outfit')));
      }
    }
  }

  void _saveOutfit(BuildContext context) async {
    try {
      final outfit = Outfit(
        id: const Uuid().v4(),
        userId: '', // Will be set by repository
        name: widget.recommendation.outfitName,
        clothingItemIds: widget.recommendation.itemIds,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(savedOutfitsProvider.notifier).saveOutfit(outfit);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Outfit saved successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving outfit: $e')));
      }
    }
  }

  void _markWorn(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Marked as worn today!')));
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final double score;
  final IconData icon;

  const _ScoreBar({
    required this.label,
    required this.score,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (score * 100).toInt();
    final color = score >= 0.8
        ? Colors.green
        : score >= 0.6
        ? Colors.orange
        : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '$percentage%',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
