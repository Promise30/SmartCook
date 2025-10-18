import 'package:json_annotation/json_annotation.dart';
import 'ingredient.dart';
import 'recipe.dart';

part 'history_entry.g.dart';

@JsonSerializable()
class HistoryEntry {
  final String id;
  final DateTime timestamp;
  final List<Ingredient> ingredients;
  final List<RecipeSuggestion> suggestedRecipes;
  final String? topRecipe;

  const HistoryEntry({
    required this.id,
    required this.timestamp,
    required this.ingredients,
    required this.suggestedRecipes,
    this.topRecipe,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => _$HistoryEntryFromJson(json);
  Map<String, dynamic> toJson() => _$HistoryEntryToJson(this);

  String get ingredientNames => ingredients.map((i) => i.name).join(', ');
  
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (entryDate == today) {
      return 'Today - ${_formatTime(timestamp)}';
    } else if (entryDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday - ${_formatTime(timestamp)}';
    } else {
      return '${_formatDate(timestamp)} - ${_formatTime(timestamp)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }
}
