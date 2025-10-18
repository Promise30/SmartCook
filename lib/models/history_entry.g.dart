// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryEntry _$HistoryEntryFromJson(Map<String, dynamic> json) => HistoryEntry(
  id: json['id'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  ingredients: (json['ingredients'] as List<dynamic>)
      .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
      .toList(),
  suggestedRecipes: (json['suggestedRecipes'] as List<dynamic>)
      .map((e) => RecipeSuggestion.fromJson(e as Map<String, dynamic>))
      .toList(),
  topRecipe: json['topRecipe'] as String?,
);

Map<String, dynamic> _$HistoryEntryToJson(HistoryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'ingredients': instance.ingredients,
      'suggestedRecipes': instance.suggestedRecipes,
      'topRecipe': instance.topRecipe,
    };
