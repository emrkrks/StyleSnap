import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/clothing_item.dart';
import '../../../repositories/clothing_repository.dart';
import '../../../services/wardrobe_scanning_service.dart';

// Repository provider
final clothingRepositoryProvider = Provider<ClothingRepository>((ref) {
  return ClothingRepository();
});

// Wardrobe scanning service provider
final wardrobeScanningProvider = Provider<WardrobeScanningService>((ref) {
  return WardrobeScanningService();
});

// All clothing items stream
final clothingItemsProvider = StreamProvider<List<ClothingItem>>((ref) async* {
  final repository = ref.watch(clothingRepositoryProvider);

  // Poll every 5 seconds for updates
  while (true) {
    try {
      final items = await repository.getUserClothingItems();
      yield items;
    } catch (e) {
      print('Error fetching clothing items: $e');
      yield [];
    }
    await Future.delayed(const Duration(seconds: 5));
  }
});

// Scanning state
enum ScanningStatus { idle, processing, success, error }

class ScanningState {
  final ScanningStatus status;
  final String? processStep;
  final ClothingItem? result;
  final String? error;

  ScanningState({
    this.status = ScanningStatus.idle,
    this.processStep,
    this.result,
    this.error,
  });

  ScanningState copyWith({
    ScanningStatus? status,
    String? processStep,
    ClothingItem? result,
    String? error,
  }) {
    return ScanningState(
      status: status ?? this.status,
      processStep: processStep,
      result: result ?? this.result,
      error: error,
    );
  }
}

// Scanning state notifier
class ScanningNotifier extends StateNotifier<ScanningState> {
  final WardrobeScanningService _scanningService;

  ScanningNotifier(this._scanningService) : super(ScanningState());

  Future<void> scanImage(File imageFile) async {
    state = state.copyWith(
      status: ScanningStatus.processing,
      processStep: 'Analyzing image...',
    );

    try {
      final result = await _scanningService.processClothingImage(imageFile);

      state = state.copyWith(status: ScanningStatus.success, result: result);
    } catch (e) {
      state = state.copyWith(status: ScanningStatus.error, error: e.toString());
    }
  }

  void reset() {
    state = ScanningState();
  }
}

// Scanning state provider
final scanningProvider = StateNotifierProvider<ScanningNotifier, ScanningState>(
  (ref) {
    final scanningService = ref.watch(wardrobeScanningProvider);
    return ScanningNotifier(scanningService);
  },
);

// Category filter provider
final categoryFilterProvider = StateProvider<String?>((ref) => null);

// Filtered items provider
final filteredClothingItemsProvider = Provider<AsyncValue<List<ClothingItem>>>((
  ref,
) {
  final itemsAsync = ref.watch(clothingItemsProvider);
  final categoryFilter = ref.watch(categoryFilterProvider);

  return itemsAsync.when(
    data: (items) {
      if (categoryFilter == null || categoryFilter.isEmpty) {
        return AsyncValue.data(items);
      }
      final filtered = items
          .where((item) => item.category == categoryFilter)
          .toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Wardrobe items notifier for CRUD operations
class WardrobeItemsNotifier
    extends StateNotifier<AsyncValue<List<ClothingItem>>> {
  final ClothingRepository _repository;

  WardrobeItemsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadItems();
  }

  Future<void> _loadItems() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repository.getUserClothingItems();
    });
  }

  Future<void> refresh() async {
    await _loadItems();
  }

  Future<void> updateItem(ClothingItem item) async {
    await _repository.updateClothingItem(item);
    await refresh();
  }

  Future<void> toggleFavorite(String itemId, bool currentFavorite) async {
    await _repository.toggleFavorite(itemId, currentFavorite);
    await refresh();
  }

  Future<void> deleteItem(String itemId) async {
    await _repository.deleteClothingItem(itemId);
    await refresh();
  }
}

// Wardrobe items provider
final wardrobeItemsProvider =
    StateNotifierProvider<
      WardrobeItemsNotifier,
      AsyncValue<List<ClothingItem>>
    >((ref) {
      final repository = ref.watch(clothingRepositoryProvider);
      return WardrobeItemsNotifier(repository);
    });
