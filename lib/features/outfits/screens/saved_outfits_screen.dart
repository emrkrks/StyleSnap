import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/outfit_providers.dart';
import 'outfit_detail_screen.dart';
import '../../../models/outfit.dart';
import '../../../models/outfit_recommendation.dart';
import '../../../repositories/clothing_repository.dart';

class SavedOutfitsScreen extends ConsumerWidget {
  const SavedOutfitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outfitsAsync = ref.watch(savedOutfitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Outfits'), elevation: 0),
      body: outfitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Error loading outfits: $error'),
            ],
          ),
        ),
        data: (outfits) {
          if (outfits.isEmpty) {
            return const _EmptyState();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: outfits.length,
            itemBuilder: (context, index) {
              final outfit = outfits[index];
              return _OutfitCard(outfit: outfit);
            },
          );
        },
      ),
    );
  }
}

class _OutfitCard extends ConsumerStatefulWidget {
  final Outfit outfit;

  const _OutfitCard({required this.outfit});

  @override
  ConsumerState<_OutfitCard> createState() => _OutfitCardState();
}

class _OutfitCardState extends ConsumerState<_OutfitCard> {
  List<String> _itemImageUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItemImages();
  }

  Future<void> _loadItemImages() async {
    final repository = ClothingRepository();
    final allItems = await repository.getUserClothingItems();

    final urls = <String>[];
    for (final itemId in widget.outfit.clothingItemIds.take(4)) {
      try {
        final item = allItems.firstWhere((i) => i.id == itemId);
        if (item.thumbnailUrl != null) {
          urls.add(item.thumbnailUrl!);
        }
      } catch (e) {
        // Item not found
      }
    }

    setState(() {
      _itemImageUrls = urls;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        // Can't navigate to detail screen without full recommendation
        // Show snackbar instead
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Viewing saved outfits coming soon!')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail grid (2x2)
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: _isLoading
                    ? Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    : _buildThumbnailGrid(),
              ),
            ),

            // Outfit info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.outfit.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.checkroom, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.outfit.clothingItemsSize} items',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      if (widget.outfit.isFavorite)
                        const Icon(Icons.favorite, size: 14, color: Colors.red),
                    ],
                  ),
                  if (widget.outfit.timesWorn > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Worn ${widget.outfit.timesWorn} times',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailGrid() {
    if (_itemImageUrls.isEmpty) {
      return Container(
        color: Colors.grey[100],
        child: const Icon(Icons.checkroom, size: 48),
      );
    }

    if (_itemImageUrls.length == 1) {
      return Image.network(
        _itemImageUrls[0],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _itemImageUrls.length,
      itemBuilder: (context, index) {
        return Image.network(_itemImageUrls[index], fit: BoxFit.cover);
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No saved outfits yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Save outfits you love from recommendations',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// Extension to get clothing items count
extension on Outfit {
  int get clothingItemsSize => clothingItemIds.length;
}
