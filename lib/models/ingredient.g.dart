// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ingredient _$IngredientFromJson(Map<String, dynamic> json) => Ingredient(
  id: json['id'] as String,
  name: json['name'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  imagePath: json['imagePath'] as String?,
  cookingMethod: json['cookingMethod'] as String?,
  quantityEstimate: json['quantityEstimate'] as String?,
  category: json['category'] as String,
  isManual: json['isManual'] as bool? ?? false,
);

Map<String, dynamic> _$IngredientToJson(Ingredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'confidence': instance.confidence,
      'imagePath': instance.imagePath,
      'cookingMethod': instance.cookingMethod,
      'quantityEstimate': instance.quantityEstimate,
      'category': instance.category,
      'isManual': instance.isManual,
    };
