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
  final String category;

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
    required this.category,
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
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final String difficulty;
  final double rating;
  final String category;

  const RecipeSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.difficulty,
    required this.rating,
    required this.category,
  });

  factory RecipeSuggestion.fromJson(Map<String, dynamic> json) => _$RecipeSuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeSuggestionToJson(this);

  String get totalTime => '${prepTimeMinutes + cookTimeMinutes} min';
}
