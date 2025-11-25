import 'package:json_annotation/json_annotation.dart';

part 'clothing_item.g.dart';

@JsonSerializable()
class ColorInfo {
  final String hex;
  final String name;
  final int percentage;

  const ColorInfo({
    required this.hex,
    required this.name,
    required this.percentage,
  });

  factory ColorInfo.fromJson(Map<String, dynamic> json) =>
      _$ColorInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ColorInfoToJson(this);
}

@JsonSerializable()
class ClothingItem {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Ownership
  final String userId;

  // Images
  final String imageUrl;
  final String? thumbnailUrl;
  final String? backgroundRemovedUrl;

  // AI Analysis Results
  final String category;
  final String? subcategory;
  final List<ColorInfo> colors;
  final List<String> patterns;
  final List<String> materials;
  final List<String> seasons;
  final List<String> styles;

  // Manual Metadata
  final String? brand;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final String? purchaseCurrency;
  final String? notes;

  // AI Confidence
  final double aiConfidence;
  final String aiModelVersion;
  final bool manuallyEdited;

  // Usage Stats
  final bool favorite;
  final int timesWorn;
  final DateTime? lastWornAt;

  // State
  final bool archived;
  final DateTime? deletedAt;

  const ClothingItem({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.imageUrl,
    this.thumbnailUrl,
    this.backgroundRemovedUrl,
    required this.category,
    this.subcategory,
    required this.colors,
    this.patterns = const [],
    this.materials = const [],
    this.seasons = const [],
    this.styles = const [],
    this.brand,
    this.purchaseDate,
    this.purchasePrice,
    this.purchaseCurrency,
    this.notes,
    required this.aiConfidence,
    this.aiModelVersion = 'gemini-1.5-flash',
    this.manuallyEdited = false,
    this.favorite = false,
    this.timesWorn = 0,
    this.lastWornAt,
    this.archived = false,
    this.deletedAt,
  });

  factory ClothingItem.fromJson(Map<String, dynamic> json) =>
      _$ClothingItemFromJson(json);

  Map<String, dynamic> toJson() => _$ClothingItemToJson(this);

  String get displayImageUrl => backgroundRemovedUrl ?? imageUrl;

  String get primaryColor => colors.isNotEmpty ? colors.first.name : 'unknown';

  bool get isHighConfidence => aiConfidence >= 0.8;

  ClothingItem copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    String? imageUrl,
    String? thumbnailUrl,
    String? backgroundRemovedUrl,
    String? category,
    String? subcategory,
    List<ColorInfo>? colors,
    List<String>? patterns,
    List<String>? materials,
    List<String>? seasons,
    List<String>? styles,
    String? brand,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? purchaseCurrency,
    String? notes,
    double? aiConfidence,
    String? aiModelVersion,
    bool? manuallyEdited,
    bool? favorite,
    int? timesWorn,
    DateTime? lastWornAt,
    bool? archived,
    DateTime? deletedAt,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      backgroundRemovedUrl: backgroundRemovedUrl ?? this.backgroundRemovedUrl,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      colors: colors ?? this.colors,
      patterns: patterns ?? this.patterns,
      materials: materials ?? this.materials,
      seasons: seasons ?? this.seasons,
      styles: styles ?? this.styles,
      brand: brand ?? this.brand,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseCurrency: purchaseCurrency ?? this.purchaseCurrency,
      notes: notes ?? this.notes,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      aiModelVersion: aiModelVersion ?? this.aiModelVersion,
      manuallyEdited: manuallyEdited ?? this.manuallyEdited,
      favorite: favorite ?? this.favorite,
      timesWorn: timesWorn ?? this.timesWorn,
      lastWornAt: lastWornAt ?? this.lastWornAt,
      archived: archived ?? this.archived,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
