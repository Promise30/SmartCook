import 'package:json_annotation/json_annotation.dart';

part 'ingredient.g.dart';

@JsonSerializable()
class Ingredient {
  final String id;
  final String name;
  final double confidence;
  final String? imagePath;
  final String? cookingMethod;
  final String? quantityEstimate;
  final String category;
  final bool isManual;
  final String detectionMethod; // 'ml', 'ocr', or 'manual'

  const Ingredient({
    required this.id,
    required this.name,
    required this.confidence,
    this.imagePath,
    this.cookingMethod,
    this.quantityEstimate,
    required this.category,
    this.isManual = false,
    this.detectionMethod = 'ml',
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientToJson(this);

  Ingredient copyWith({
    String? id,
    String? name,
    double? confidence,
    String? imagePath,
    bool clearImagePath = false,
    String? cookingMethod,
    String? quantityEstimate,
    String? category,
    bool? isManual,
    String? detectionMethod,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      confidence: confidence ?? this.confidence,
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
      cookingMethod: cookingMethod ?? this.cookingMethod,
      quantityEstimate: quantityEstimate ?? this.quantityEstimate,
      category: category ?? this.category,
      isManual: isManual ?? this.isManual,
      detectionMethod: detectionMethod ?? this.detectionMethod,
    );
  }
}
