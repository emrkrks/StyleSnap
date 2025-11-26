import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../models/weather_data.dart';
import '../../../models/outfit.dart';
import '../../../models/outfit_recommendation.dart';
import '../../../models/clothing_item.dart';
import '../../../repositories/outfit_repository.dart';
import '../../../repositories/recommendation_repository.dart';
import '../../../services/weather_service.dart';
import '../../../services/gemini_outfit_service.dart';
import '../../wardrobe/providers/wardrobe_providers.dart';
import '../../auth/providers/auth_providers.dart';

// Services
final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

final geminiOutfitServiceProvider = Provider<GeminiOutfitService>((ref) {
  return GeminiOutfitService();
});

// Repositories
final outfitRepositoryProvider = Provider<OutfitRepository>((ref) {
  return OutfitRepository();
});

final recommendationRepositoryProvider = Provider<RecommendationRepository>((
  ref,
) {
  return RecommendationRepository();
});

// Weather provider
final weatherProvider = FutureProvider<WeatherData>((ref) async {
  final weatherService = ref.watch(weatherServiceProvider);

  // Try to get user's location
  try {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied ||
          requested == LocationPermission.deniedForever) {
        // Fallback to city name (Istanbul as default)
        return await weatherService.getWeatherByCity('Istanbul');
      }
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );

    return await weatherService.getWeatherByCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  } catch (e) {
    // Fallback to default city if location fails
    return await weatherService.getWeatherByCity('Istanbul');
  }
});

// Daily recommendations state
enum RecommendationStatus { idle, loading, success, error }

class RecommendationState {
  final RecommendationStatus status;
  final List<OutfitRecommendation> recommendations;
  final String? error;

  RecommendationState({
    this.status = RecommendationStatus.idle,
    this.recommendations = const [],
    this.error,
  });

  RecommendationState copyWith({
    RecommendationStatus? status,
    List<OutfitRecommendation>? recommendations,
    String? error,
  }) {
    return RecommendationState(
      status: status ?? this.status,
      recommendations: recommendations ?? this.recommendations,
      error: error,
    );
  }
}

class RecommendationNotifier extends StateNotifier<RecommendationState> {
  final OutfitRepository _outfitRepo;
  final RecommendationRepository _recommendationRepo;
  final GeminiOutfitService _geminiService;
  final WeatherService _weatherService;
  final Ref _ref;

  RecommendationNotifier(
    this._outfitRepo,
    this._recommendationRepo,
    this._geminiService,
    this._weatherService,
    this._ref,
  ) : super(RecommendationState()) {
    _loadTodayRecommendations();
  }

  Future<void> _loadTodayRecommendations() async {
    // First try to load cached recommendations
    final cached = await _recommendationRepo.getTodayRecommendations();
    if (cached.isNotEmpty) {
      state = state.copyWith(
        status: RecommendationStatus.success,
        recommendations: cached,
      );
      return;
    }

    // If no cache, generate new ones
    await generateRecommendations();
  }

  Future<void> generateRecommendations({String occasion = 'casual'}) async {
    state = state.copyWith(status: RecommendationStatus.loading);

    try {
      // Get wardrobe items
      final wardrobeAsync = _ref.read(wardrobeItemsProvider);
      final wardrobe = wardrobeAsync.when(
        data: (items) => items.where((item) => item.deletedAt == null).toList(),
        loading: () => <ClothingItem>[],
        error: (_, __) => <ClothingItem>[],
      );

      if (wardrobe.isEmpty) {
        throw Exception('Add clothing items to your wardrobe first');
      }

      // Get user data
      final userAsync = _ref.read(currentUserProvider);
      final user = userAsync.when(
        data: (u) => u,
        loading: () => null,
        error: (_, __) => null,
      );

      if (user == null) {
        throw Exception('User not found');
      }

      // Get weather
      final weatherAsync = _ref.read(weatherProvider);
      final weather = await weatherAsync.when(
        data: (w) async => w,
        loading: () async => throw Exception('Loading weather...'),
        error: (e, _) async => throw Exception('Weather unavailable: $e'),
      );

      // Get current season
      final season = GeminiOutfitService.getCurrentSeason();

      // Generate recommendations
      final recommendations = await _geminiService
          .generateOutfitRecommendations(
            wardrobe: wardrobe,
            weather: weather,
            occasion: occasion,
            season: season,
            user: user,
          );

      // Save to cache
      await _recommendationRepo.saveDailyRecommendations(recommendations);

      state = state.copyWith(
        status: RecommendationStatus.success,
        recommendations: recommendations,
      );
    } catch (e) {
      state = state.copyWith(
        status: RecommendationStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    _weatherService.clearCache();
    await generateRecommendations();
  }
}

final dailyRecommendationsProvider =
    StateNotifierProvider<RecommendationNotifier, RecommendationState>((ref) {
      final outfitRepo = ref.watch(outfitRepositoryProvider);
      final recommendationRepo = ref.watch(recommendationRepositoryProvider);
      final geminiService = ref.watch(geminiOutfitServiceProvider);
      final weatherService = ref.watch(weatherServiceProvider);

      return RecommendationNotifier(
        outfitRepo,
        recommendationRepo,
        geminiService,
        weatherService,
        ref,
      );
    });

// Saved outfits provider
class SavedOutfitsNotifier extends StateNotifier<AsyncValue<List<Outfit>>> {
  final OutfitRepository _repository;

  SavedOutfitsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadOutfits();
  }

  Future<void> _loadOutfits() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repository.getUserOutfits();
    });
  }

  Future<void> refresh() async {
    await _loadOutfits();
  }

  Future<void> saveOutfit(Outfit outfit) async {
    await _repository.createOutfit(outfit);
    await refresh();
  }

  Future<void> toggleFavorite(String outfitId, bool currentFavorite) async {
    await _repository.toggleFavorite(outfitId, currentFavorite);
    await refresh();
  }

  Future<void> deleteOutfit(String outfitId) async {
    await _repository.deleteOutfit(outfitId);
    await refresh();
  }

  Future<void> markWorn(String outfitId) async {
    await _repository.incrementWearCount(outfitId);
    await refresh();
  }
}

final savedOutfitsProvider =
    StateNotifierProvider<SavedOutfitsNotifier, AsyncValue<List<Outfit>>>((
      ref,
    ) {
      final repository = ref.watch(outfitRepositoryProvider);
      return SavedOutfitsNotifier(repository);
    });

// Outfit history provider
final outfitHistoryProvider = FutureProvider<List<Outfit>>((ref) async {
  final repository = ref.watch(outfitRepositoryProvider);
  return repository.getRecentOutfits(limit: 20);
});
