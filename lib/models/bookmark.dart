import 'package:json_annotation/json_annotation.dart';
import 'recipe.dart';

part 'bookmark.g.dart';

@JsonSerializable()
class Bookmark {
  final String id;
  final DateTime timestamp;
  final RecipeSuggestion recipe;

  const Bookmark({
    required this.id,
    required this.timestamp,
    required this.recipe,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) => _$BookmarkFromJson(json);
  Map<String, dynamic> toJson() => _$BookmarkToJson(this);

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookmarkDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (bookmarkDate == today) {
      return 'Today';
    } else if (bookmarkDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return _formatDate(timestamp);
    }
  }

  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }
}
