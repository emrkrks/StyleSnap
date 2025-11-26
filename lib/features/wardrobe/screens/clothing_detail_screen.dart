import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/clothing_item.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/wardrobe_providers.dart';

class ClothingDetailScreen extends ConsumerStatefulWidget {
  final ClothingItem item;

  const ClothingDetailScreen({super.key, required this.item});

  @override
  ConsumerState<ClothingDetailScreen> createState() =>
      _ClothingDetailScreenState();
}

class _ClothingDetailScreenState extends ConsumerState<ClothingDetailScreen> {
  late ClothingItem _item;
  bool _isEditing = false;
  late TextEditingController _brandController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _brandController = TextEditingController(text: _item.brand);
    _notesController = TextEditingController(text: _item.notes);
  }

  @override
  void dispose() {
    _brandController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Clothing Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_item.favorite ? Icons.favorite : Icons.favorite_border),
            color: _item.favorite ? Colors.red : null,
            onPressed: _toggleFavorite,
          ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'archive', child: Text('Archive')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: double.infinity,
              height: 400,
              color: Colors.grey[100],
              child: _item.imageUrl.isNotEmpty
                  ? Image.network(
                      _item.displayImageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported, size: 64);
                      },
                    )
                  : const Icon(Icons.checkroom, size: 96),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Subcategory
                  Row(
                    children: [
                      Chip(
                        label: Text(_capitalize(_item.category)),
                        backgroundColor: theme.colorScheme.primaryContainer,
                      ),
                      if (_item.subcategory != null) ...[
                        const SizedBox(width: 8),
                        Chip(label: Text(_capitalize(_item.subcategory!))),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Brand
                  _buildInfoSection(
                    'Brand',
                    _isEditing
                        ? TextField(
                            controller: _brandController,
                            decoration: const InputDecoration(
                              hintText: 'Enter brand name',
                              border: OutlineInputBorder(),
                            ),
                          )
                        : Text(
                            _item.brand ?? 'Not specified',
                            style: theme.textTheme.bodyLarge,
                          ),
                  ),

                  // Colors
                  _buildInfoSection(
                    'Colors',
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: _item.colors.map((color) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _parseColor(color.hex),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${color.name} (${color.percentage}%)'),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  // Materials
                  if (_item.materials.isNotEmpty)
                    _buildInfoSection(
                      'Materials',
                      Wrap(
                        spacing: 8,
                        children: _item.materials.map((material) {
                          return Chip(label: Text(_capitalize(material)));
                        }).toList(),
                      ),
                    ),

                  // Styles
                  if (_item.styles.isNotEmpty)
                    _buildInfoSection(
                      'Styles',
                      Wrap(
                        spacing: 8,
                        children: _item.styles.map((style) {
                          return Chip(
                            label: Text(_capitalize(style)),
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                          );
                        }).toList(),
                      ),
                    ),

                  // Seasons
                  if (_item.seasons.isNotEmpty)
                    _buildInfoSection(
                      'Seasons',
                      Wrap(
                        spacing: 8,
                        children: _item.seasons.map((season) {
                          return Chip(
                            label: Text(_capitalize(season)),
                            avatar: Icon(_getSeasonIcon(season), size: 18),
                          );
                        }).toList(),
                      ),
                    ),

                  // Patterns
                  if (_item.patterns.isNotEmpty)
                    _buildInfoSection(
                      'Patterns',
                      Wrap(
                        spacing: 8,
                        children: _item.patterns.map((pattern) {
                          return Chip(label: Text(_capitalize(pattern)));
                        }).toList(),
                      ),
                    ),

                  // Notes
                  _buildInfoSection(
                    'Notes',
                    _isEditing
                        ? TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Add notes about this item...',
                              border: OutlineInputBorder(),
                            ),
                          )
                        : Text(
                            _item.notes ?? 'No notes',
                            style: theme.textTheme.bodyLarge,
                          ),
                  ),

                  // Stats
                  _buildInfoSection(
                    'Stats',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Times worn: ${_item.timesWorn}'),
                        if (_item.lastWornAt != null)
                          Text('Last worn: ${_formatDate(_item.lastWornAt!)}'),
                        Text(
                          'AI Confidence: ${(_item.aiConfidence * 100).toStringAsFixed(0)}%',
                        ),
                      ],
                    ),
                  ),

                  // Purchase Info
                  if (_item.purchasePrice != null)
                    _buildInfoSection(
                      'Purchase Info',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price: ${_item.purchaseCurrency ?? '\$'}${_item.purchasePrice}',
                          ),
                          if (_item.purchaseDate != null)
                            Text('Date: ${_formatDate(_item.purchaseDate!)}'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isEditing
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _brandController.text = _item.brand ?? '';
                            _notesController.text = _item.notes ?? '';
                          });
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildInfoSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        content,
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _toggleFavorite() async {
    try {
      await ref
          .read(wardrobeItemsProvider.notifier)
          .toggleFavorite(_item.id, _item.favorite);
      setState(() {
        _item = _item.copyWith(favorite: !_item.favorite);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _item.favorite ? 'Added to favorites' : 'Removed from favorites',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _saveChanges() async {
    try {
      final updatedItem = _item.copyWith(
        brand: _brandController.text.isEmpty ? null : _brandController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        manuallyEdited: true,
        updatedAt: DateTime.now(),
      );

      await ref.read(wardrobeItemsProvider.notifier).updateItem(updatedItem);

      setState(() {
        _item = updatedItem;
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Changes saved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    }
  }

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'archive':
        await _archiveItem();
        break;
      case 'delete':
        await _deleteItem();
        break;
    }
  }

  Future<void> _archiveItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Item'),
        content: const Text('Are you sure you want to archive this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final archived = _item.copyWith(archived: true);
        await ref.read(wardrobeItemsProvider.notifier).updateItem(archived);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error archiving: $e')));
        }
      }
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text(
          'Are you sure you want to delete this item? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(wardrobeItemsProvider.notifier).deleteItem(_item.id);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
        }
      }
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Color _parseColor(String hex) {
    try {
      final hexColor = hex.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  IconData _getSeasonIcon(String season) {
    switch (season.toLowerCase()) {
      case 'spring':
        return Icons.local_florist;
      case 'summer':
        return Icons.wb_sunny;
      case 'fall':
        return Icons.auto_awesome;
      case 'winter':
        return Icons.ac_unit;
      default:
        return Icons.calendar_today;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
