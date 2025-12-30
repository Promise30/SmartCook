import 'package:json_annotation/json_annotation.dart';

part 'recipe.g.dart';

@JsonSerializable()
class Recipe {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty;
  final String? imageUrl;
  final double rating;
  final NutritionalInfo? nutritionalInfo;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    this.imageUrl,
    required this.rating,
    this.nutritionalInfo,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeToJson(this);

  String get totalTime => '${prepTimeMinutes + cookTimeMinutes} min';
}

@JsonSerializable()
class RecipeSuggestion {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final String difficulty;
  final double rating;
  final String? imageUrl;
  final NutritionalInfo? nutritionalInfo;

  const RecipeSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.difficulty,
    required this.rating,
    this.imageUrl,
    this.nutritionalInfo,
  });

  factory RecipeSuggestion.fromJson(Map<String, dynamic> json) => _$RecipeSuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeSuggestionToJson(this);

  String get totalTime => '${prepTimeMinutes + cookTimeMinutes} min';
}

class NutritionalInfo {
  // Dynamic map to store any nutritional information
  final Map<String, dynamic> data;

  const NutritionalInfo({required this.data});

  factory NutritionalInfo.fromJson(Map<String, dynamic> json) {
    return NutritionalInfo(data: Map<String, dynamic>.from(json));
  }

  Map<String, dynamic> toJson() {
    return data;
  }

  // Helper method to get all nutritional class names
  List<String> get nutritionalClasses {
    // Filter out 'servings' and only include fields with true values (food groups present)
    return data.keys
        .where((key) => key != 'servings' && data[key] == true)
        .toList()
      ..sort();
  }

  // Helper method to format class names for display
  String formatClassName(String key) {
    // Convert camelCase to Title Case
    final result = key.replaceAllMapped(
      RegExp(r'([A-Z])|([a-z])([A-Z])'),
      (match) {
        if (match.group(1) != null) return ' ${match.group(1)}';
        return '${match.group(2)} ${match.group(3)}';
      },
    );
    return result[0].toUpperCase() + result.substring(1);
  }

  // Convenience getters for common fields
  int? get servings => data['servings'] as int?;
  num? get calories => data['calories'] as num?;
  num? get protein => data['protein'] as num?;
  num? get carbs => data['carbs'] as num?;
  num? get fat => data['fat'] as num?;
  num? get fiber => data['fiber'] as num?;
}
