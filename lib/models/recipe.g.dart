// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  ingredients: (json['ingredients'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  instructions: (json['instructions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  prepTimeMinutes: (json['prepTimeMinutes'] as num).toInt(),
  cookTimeMinutes: (json['cookTimeMinutes'] as num).toInt(),
  servings: (json['servings'] as num).toInt(),
  difficulty: json['difficulty'] as String,
  imageUrl: json['imageUrl'] as String?,
  rating: (json['rating'] as num).toDouble(),
  category: json['category'] as String,
);

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'ingredients': instance.ingredients,
  'instructions': instance.instructions,
  'prepTimeMinutes': instance.prepTimeMinutes,
  'cookTimeMinutes': instance.cookTimeMinutes,
  'servings': instance.servings,
  'difficulty': instance.difficulty,
  'imageUrl': instance.imageUrl,
  'rating': instance.rating,
  'category': instance.category,
};

RecipeSuggestion _$RecipeSuggestionFromJson(Map<String, dynamic> json) =>
    RecipeSuggestion(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      prepTimeMinutes: (json['prepTimeMinutes'] as num).toInt(),
      cookTimeMinutes: (json['cookTimeMinutes'] as num).toInt(),
      difficulty: json['difficulty'] as String,
      rating: (json['rating'] as num).toDouble(),
      category: json['category'] as String,
    );

Map<String, dynamic> _$RecipeSuggestionToJson(RecipeSuggestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'ingredients': instance.ingredients,
      'prepTimeMinutes': instance.prepTimeMinutes,
      'cookTimeMinutes': instance.cookTimeMinutes,
      'difficulty': instance.difficulty,
      'rating': instance.rating,
      'category': instance.category,
    };
