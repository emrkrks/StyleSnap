import 'package:json_annotation/json_annotation.dart';

part 'outfit.g.dart';

@JsonSerializable()
class Outfit {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String name;
  @JsonKey(name: 'clothing_item_ids')
  final List<String> clothingItemIds;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'is_favorite')
  final bool isFavorite;
  @JsonKey(name: 'times_worn')
  final int timesWorn;
  @JsonKey(name: 'last_worn_at')
  final DateTime? lastWornAt;
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  const Outfit({
    required this.id,
    required this.userId,
    required this.name,
    required this.clothingItemIds,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.timesWorn = 0,
    this.lastWornAt,
    this.deletedAt,
  });

  factory Outfit.fromJson(Map<String, dynamic> json) => _$OutfitFromJson(json);

  Map<String, dynamic> toJson() => _$OutfitToJson(this);

  Outfit copyWith({
    String? id,
    String? userId,
    String? name,
    List<String>? clothingItemIds,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    int? timesWorn,
    DateTime? lastWornAt,
    DateTime? deletedAt,
  }) {
    return Outfit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      clothingItemIds: clothingItemIds ?? this.clothingItemIds,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      timesWorn: timesWorn ?? this.timesWorn,
      lastWornAt: lastWornAt ?? this.lastWornAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
