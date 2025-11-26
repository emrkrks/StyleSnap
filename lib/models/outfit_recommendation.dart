import 'package:json_annotation/json_annotation.dart';

part 'outfit_recommendation.g.dart';

@JsonSerializable()
class RecommendedItem {
  @JsonKey(name: 'item_id')
  final String itemId;
  final String category;
  final String reason;

  const RecommendedItem({
    required this.itemId,
    required this.category,
    required this.reason,
  });

  factory RecommendedItem.fromJson(Map<String, dynamic> json) =>
      _$RecommendedItemFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendedItemToJson(this);
}

@JsonSerializable()
class MissingItem {
  final String category;
  final String description;
  final String priority;

  const MissingItem({
    required this.category,
    required this.description,
    required this.priority,
  });

  factory MissingItem.fromJson(Map<String, dynamic> json) =>
      _$MissingItemFromJson(json);

  Map<String, dynamic> toJson() => _$MissingItemToJson(this);

  bool get isHighPriority => priority.toLowerCase() == 'high';
  bool get isMediumPriority => priority.toLowerCase() == 'medium';
  bool get isLowPriority => priority.toLowerCase() == 'low';
}

@JsonSerializable()
class OutfitRecommendation {
  @JsonKey(name: 'outfit_name')
  final String outfitName;
  final String occasion;
  final List<RecommendedItem> items;
  @JsonKey(name: 'style_description')
  final String styleDescription;
  @JsonKey(name: 'style_score')
  final double styleScore;
  @JsonKey(name: 'weather_appropriateness')
  final double weatherAppropriateness;
  @JsonKey(name: 'styling_tips')
  final List<String> stylingTips;
  @JsonKey(name: 'missing_items')
  final List<MissingItem> missingItems;

  const OutfitRecommendation({
    required this.outfitName,
    required this.occasion,
    required this.items,
    required this.styleDescription,
    required this.styleScore,
    required this.weatherAppropriateness,
    required this.stylingTips,
    this.missingItems = const [],
  });

  factory OutfitRecommendation.fromJson(Map<String, dynamic> json) =>
      _$OutfitRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$OutfitRecommendationToJson(this);

  // Overall score combining style and weather
  double get overallScore => (styleScore + weatherAppropriateness) / 2;

  // Get item IDs for easy lookup
  List<String> get itemIds => items.map((item) => item.itemId).toList();

  // Check if outfit is well-suited for weather
  bool get isWeatherAppropriate => weatherAppropriateness >= 0.7;

  // Check if outfit has good style
  bool get isStylish => styleScore >= 0.7;
}
