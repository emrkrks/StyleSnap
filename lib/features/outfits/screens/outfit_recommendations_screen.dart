import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/outfit_providers.dart';
import 'outfit_detail_screen.dart';
import '../../../models/weather_data.dart';
import '../../../models/outfit_recommendation.dart';

class OutfitRecommendationsScreen extends ConsumerWidget {
  const OutfitRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final weatherAsync = ref.watch(weatherProvider);
    final recommendationState = ref.watch(dailyRecommendationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Outfit Recommendations'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(dailyRecommendationsProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weather Card
              weatherAsync.when(
                loading: () => const _WeatherCardLoading(),
                error: (error, _) => _WeatherCardError(error: error.toString()),
                data: (weather) => _WeatherCard(weather: weather),
              ),

              const SizedBox(height: 24),

              // Recommendations Section
              Text(
                'Your Daily Outfits',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Recommendations List
              if (recommendationState.status == RecommendationStatus.loading)
                const _RecommendationsLoading()
              else if (recommendationState.status == RecommendationStatus.error)
                _RecommendationsError(error: recommendationState.error!)
              else if (recommendationState.recommendations.isEmpty)
                const _RecommendationsEmpty()
              else
                ...recommendationState.recommendations.map((rec) {
                  final index = recommendationState.recommendations.indexOf(
                    rec,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _RecommendationCard(
                      recommendation: rec,
                      index: index + 1,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OutfitDetailScreen(recommendation: rec),
                          ),
                        );
                      },
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await ref.read(dailyRecommendationsProvider.notifier).refresh();
        },
        icon: const Icon(Icons.refresh),
        label: const Text('New Recommendations'),
      ),
    );
  }
}

// Weather Card
class _WeatherCard extends StatelessWidget {
  final WeatherData weather;

  const _WeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(weather.weatherEmoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weather.temperature.toStringAsFixed(0)}°C',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  weather.condition,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  weather.location,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherCardLoading extends StatelessWidget {
  const _WeatherCardLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _WeatherCardError extends StatelessWidget {
  final String error;

  const _WeatherCardError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text('Weather unavailable: $error'),
    );
  }
}

// Recommendation Card
class _RecommendationCard extends StatelessWidget {
  final OutfitRecommendation recommendation;
  final int index;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.recommendation,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      '$index',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation.outfitName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          recommendation.occasion,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Scores
              Row(
                children: [
                  _ScoreBadge(
                    icon: Icons.wb_sunny,
                    label: 'Weather',
                    score: recommendation.weatherAppropriateness,
                  ),
                  const SizedBox(width: 16),
                  _ScoreBadge(
                    icon: Icons.style,
                    label: 'Style',
                    score: recommendation.styleScore,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Number of items
              Row(
                children: [
                  Icon(Icons.checkroom, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${recommendation.items.length} items',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final double score;

  const _ScoreBadge({
    required this.icon,
    required this.label,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score * 100).toInt();
    final color = score >= 0.8
        ? Colors.green
        : score >= 0.6
        ? Colors.orange
        : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$percentage%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Loading States
class _RecommendationsLoading extends StatelessWidget {
  const _RecommendationsLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating your perfect outfits...'),
            SizedBox(height: 8),
            Text(
              'This may take 10-30 seconds',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationsError extends StatelessWidget {
  final String error;

  const _RecommendationsError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to generate recommendations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationsEmpty extends StatelessWidget {
  const _RecommendationsEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.checkroom_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Add more clothes to get recommendations'),
          ],
        ),
      ),
    );
  }
}
