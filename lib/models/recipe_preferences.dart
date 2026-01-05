class RecipePreferences {
  final int servings;
  final MealType mealType;
  final TimeConstraint timeConstraint;

  const RecipePreferences({
    required this.servings,
    required this.mealType,
    required this.timeConstraint,
  });

  Map<String, dynamic> toJson() {
    return {
      'servings': servings,
      'mealType': mealType.value,
      'timeConstraint': timeConstraint.value,
    };
  }

  factory RecipePreferences.fromJson(Map<String, dynamic> json) {
    return RecipePreferences(
      servings: json['servings'] as int,
      mealType: MealType.fromValue(json['mealType'] as String),
      timeConstraint: TimeConstraint.fromValue(json['timeConstraint'] as String),
    );
  }

  // Default preferences
  factory RecipePreferences.defaultPreferences() {
    return const RecipePreferences(
      servings: 4,
      mealType: MealType.any,
      timeConstraint: TimeConstraint.moderate,
    );
  }
}

enum MealType {
  breakfast('Breakfast'),
  lunch('Lunch'),
  dinner('Dinner'),
  snack('Snack'),
  any('Any');

  final String value;
  const MealType(this.value);

  static MealType fromValue(String value) {
    return MealType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MealType.any,
    );
  }

  String get description {
    switch (this) {
      case MealType.breakfast:
        return 'Morning meals';
      case MealType.lunch:
        return 'Midday meals';
      case MealType.dinner:
        return 'Evening meals';
      case MealType.snack:
        return 'Light bites';
      case MealType.any:
        return 'All meal types';
    }
  }
}

enum TimeConstraint {
  quick('Quick'),
  moderate('Moderate'),
  noRush('No Rush');

  final String value;
  const TimeConstraint(this.value);

  static TimeConstraint fromValue(String value) {
    return TimeConstraint.values.firstWhere(
      (constraint) => constraint.value == value,
      orElse: () => TimeConstraint.moderate,
    );
  }

  String get description {
    switch (this) {
      case TimeConstraint.quick:
        return 'Under 30 minutes';
      case TimeConstraint.moderate:
        return '30-60 minutes';
      case TimeConstraint.noRush:
        return 'Any time';
    }
  }

  int? get maxMinutes {
    switch (this) {
      case TimeConstraint.quick:
        return 30;
      case TimeConstraint.moderate:
        return 60;
      case TimeConstraint.noRush:
        return null;
    }
  }
}
