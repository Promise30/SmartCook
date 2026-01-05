import 'package:flutter/material.dart';
import '../models/recipe_preferences.dart';
import '../models/ingredient.dart';
import '../models/history_entry.dart';
import '../services/recipe_ai_service.dart';
import '../services/database_service.dart';
import '../widgets/loading_dialog.dart';
import '../widgets/error_dialog.dart';
import 'recipe_suggestions_screen.dart';

class RecipePreferencesScreen extends StatefulWidget {
  final List<Ingredient> ingredients;

  const RecipePreferencesScreen({
    super.key,
    required this.ingredients,
  });

  @override
  State<RecipePreferencesScreen> createState() => _RecipePreferencesScreenState();
}

class _RecipePreferencesScreenState extends State<RecipePreferencesScreen> {
  final RecipeAIService _recipeService = RecipeAIService();
  final DatabaseService _databaseService = DatabaseService();
  
  int _servings = 4;
  MealType _selectedMealType = MealType.any;
  TimeConstraint _selectedTimeConstraint = TimeConstraint.moderate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E8),
              Color(0xFFF0F8F0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    const Expanded(
                      child: Text(
                        'Recipe Preferences',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Intro text
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: const Color(0xFF4CAF50),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tell us your preferences for more personalized recipes!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Servings section
                      _buildSectionTitle('How many servings?', Icons.people),
                      const SizedBox(height: 12),
                      _buildServingsSelector(),
                      
                      const SizedBox(height: 32),
                      
                      // Meal type section
                      _buildSectionTitle('What meal are you planning?', Icons.restaurant_menu),
                      const SizedBox(height: 12),
                      _buildMealTypeSelector(),
                      
                      const SizedBox(height: 32),
                      
                      // Time constraint section
                      _buildSectionTitle('How much time do you have?', Icons.access_time),
                      const SizedBox(height: 12),
                      _buildTimeConstraintSelector(),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Generate button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _generateRecipes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Generate Recipes',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4CAF50), size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildServingsSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _servings > 1 ? () => setState(() => _servings--) : null,
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 32,
                color: _servings > 1 ? const Color(0xFF4CAF50) : Colors.grey,
              ),
              const SizedBox(width: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_servings',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              IconButton(
                onPressed: _servings < 12 ? () => setState(() => _servings++) : null,
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 32,
                color: _servings < 12 ? const Color(0xFF4CAF50) : Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _servings == 1 ? '1 person' : '$_servings people',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: MealType.values.map((mealType) {
          final isSelected = _selectedMealType == mealType;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedMealType = mealType),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF4CAF50)
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getMealIcon(mealType),
                      color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[600],
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mealType.value,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFF4CAF50) : Colors.black87,
                            ),
                          ),
                          Text(
                            mealType.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeConstraintSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: TimeConstraint.values.map((timeConstraint) {
          final isSelected = _selectedTimeConstraint == timeConstraint;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedTimeConstraint = timeConstraint),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF4CAF50)
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getTimeIcon(timeConstraint),
                      color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[600],
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            timeConstraint.value,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFF4CAF50) : Colors.black87,
                            ),
                          ),
                          Text(
                            timeConstraint.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getMealIcon(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return Icons.free_breakfast;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.fastfood;
      case MealType.any:
        return Icons.restaurant;
    }
  }

  IconData _getTimeIcon(TimeConstraint timeConstraint) {
    switch (timeConstraint) {
      case TimeConstraint.quick:
        return Icons.bolt;
      case TimeConstraint.moderate:
        return Icons.schedule;
      case TimeConstraint.noRush:
        return Icons.all_inclusive;
    }
  }

  Future<void> _generateRecipes() async {
    if (widget.ingredients.isEmpty) return;

    final preferences = RecipePreferences(
      servings: _servings,
      mealType: _selectedMealType,
      timeConstraint: _selectedTimeConstraint,
    );

    // Show loading dialog
    if (mounted) {
      LoadingDialog.show(
        context,
        message: 'Generating personalized recipes...\n\nOur AI chef is creating delicious Nigerian recipes for you. This may take 10-15 seconds.',
      );
    }

    try {
      // Generate recipe suggestions with preferences
      final ingredientNames = widget.ingredients.map((i) => i.name).toList();
      final recipes = await _recipeService.generateRecipeSuggestionsWithPreferences(
        ingredientNames,
        preferences,
      );
      
      // Hide loading dialog
      if (mounted) {
        LoadingDialog.hide(context);
      }
      
      // Save to history
      final historyEntry = HistoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        ingredients: widget.ingredients,
        suggestedRecipes: recipes,
        topRecipe: recipes.isNotEmpty ? recipes.first.title : null,
      );
      
      await _databaseService.saveHistoryEntry(historyEntry);

      // Navigate to recipe suggestions - keep only MainScreen in stack
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => RecipeSuggestionsScreen(
              ingredients: widget.ingredients,
              recipes: recipes,
            ),
          ),
          (route) => route.isFirst, // Keep the first route (MainScreen)
        );
      }
    } catch (e) {
      // Hide loading dialog
      if (mounted) {
        LoadingDialog.hide(context);
      }
      
      // Show error dialog with retry option
      if (mounted) {
        final shouldRetry = await ErrorDialog.show(
          context,
          title: 'Recipe Generation Failed',
          message: _getRecipeErrorMessage(e),
          showRetry: true,
          technicalDetails: e.toString(),
        );
        
        if (shouldRetry) {
          // Retry recipe generation
          await _generateRecipes();
        }
      }
    }
  }

  String _getRecipeErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('api key') || errorString.contains('unauthorized')) {
      return 'API authentication failed.\n\nPlease check the API configuration.';
    } else if (errorString.contains('timeout') || errorString.contains('connection')) {
      return 'Connection timeout.\n\nPlease check your internet connection and try again.';
    } else if (errorString.contains('rate limit') || errorString.contains('quota')) {
      return 'Service limit reached.\n\nPlease try again in a few moments.';
    } else if (errorString.contains('503') || errorString.contains('unavailable')) {
      return 'Our AI service is temporarily unavailable.\n\nPlease try again in a few moments.';
    } else {
      return 'Failed to generate recipes.\n\nPlease check your internet connection and try again.';
    }
  }
}
