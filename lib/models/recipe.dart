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
    this.nutritionalInfo,
  });

  factory RecipeSuggestion.fromJson(Map<String, dynamic> json) => _$RecipeSuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeSuggestionToJson(this);

  String get totalTime => '${prepTimeMinutes + cookTimeMinutes} min';
}

class NutritionalInfo {
  final int calories;
  final int protein; // in grams
  final int carbs; // in grams
  final int fat; // in grams
  final int fiber; // in grams
  final int servings;

  const NutritionalInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.servings,
  });

  factory NutritionalInfo.fromJson(Map<String, dynamic> json) {
    return NutritionalInfo(
      calories: json['calories'] as int,
      protein: json['protein'] as int,
      carbs: json['carbs'] as int,
      fat: json['fat'] as int,
      fiber: json['fiber'] as int,
      servings: json['servings'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'servings': servings,
    };
  }
}
