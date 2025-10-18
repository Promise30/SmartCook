// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bookmark _$BookmarkFromJson(Map<String, dynamic> json) => Bookmark(
  id: json['id'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  recipe: RecipeSuggestion.fromJson(json['recipe'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookmarkToJson(Bookmark instance) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp.toIso8601String(),
  'recipe': instance.recipe,
};
