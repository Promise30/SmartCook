import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import 'recipe_details_screen.dart';
import 'history_screen.dart';
import 'main_screen.dart';
import 'bookmarks_screen.dart';

class RecipeSuggestionsScreen extends StatefulWidget {
  final List<Ingredient> ingredients;
  final List<RecipeSuggestion> recipes;

  const RecipeSuggestionsScreen({
    super.key,
    required this.ingredients,
    required this.recipes,
  });

  @override
  State<RecipeSuggestionsScreen> createState() => _RecipeSuggestionsScreenState();
}

class _RecipeSuggestionsScreenState extends State<RecipeSuggestionsScreen> {
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
                        'Recipe Suggestions',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const HistoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history, color: Colors.black),
                    ),
                  ],
                ),
              ),

              // Ingredients summary
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Based on your ingredients:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: widget.ingredients.map((ingredient) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            ingredient.name,
                            style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Recipe suggestions list
              Expanded(
                child: widget.recipes.isEmpty
                    ? const Center(
                        child: Text(
                          'No recipe suggestions available.\nTry adding more ingredients!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: widget.recipes.length,
                        itemBuilder: (context, index) {
                          return _buildRecipeCard(widget.recipes[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', false),
                _buildNavItem(Icons.bookmark, 'Bookmarks', false),
                _buildNavItem(Icons.history, 'History', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(RecipeSuggestion recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewRecipeDetails(recipe),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Recipe image placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getDifficultyColor(recipe.difficulty).withValues(alpha: 0.8),
                        _getDifficultyColor(recipe.difficulty).withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: _getDifficultyColor(recipe.difficulty).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getRecipeIcon(recipe.difficulty),
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Recipe details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recipe.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip(Icons.access_time, recipe.totalTime),
                          const SizedBox(width: 8),
                          _buildInfoChip(Icons.restaurant, '4'),
                          const SizedBox(width: 8),
                          _buildInfoChip(Icons.star, recipe.rating.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRecipeIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.sentiment_satisfied_alt;
      case 'medium':
        return Icons.restaurant_menu;
      case 'hard':
        return Icons.emoji_events;
      default:
        return Icons.restaurant_menu;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF4CAF50); // Green
      case 'medium':
        return const Color(0xFFFF9800); // Orange
      case 'hard':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF607D8B); // Blue Grey
    }
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () => _handleNavigation(label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF424242) : Colors.grey,
            size: 24,
          ),
          if (isActive)
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF424242),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  void _handleNavigation(String label) {
    switch (label) {
      case 'Home':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
        break;
      case 'Bookmarks':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const BookmarksScreen(),
          ),
        );
        break;
      case 'History':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const HistoryScreen(),
          ),
        );
        break;
    }
  }

  Future<void> _viewRecipeDetails(RecipeSuggestion recipe) async {
    // Convert RecipeSuggestion to Recipe directly (no need to fetch from API)
    final detailedRecipe = Recipe(
      id: recipe.id,
      title: recipe.title,
      description: recipe.description,
      ingredients: recipe.ingredients,
      instructions: recipe.instructions,
      prepTimeMinutes: recipe.prepTimeMinutes,
      cookTimeMinutes: recipe.cookTimeMinutes,
      servings: recipe.nutritionalInfo?.servings ?? 4,
      difficulty: recipe.difficulty,
      rating: recipe.rating,
      nutritionalInfo: recipe.nutritionalInfo,
    );
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeDetailsScreen(
          recipe: detailedRecipe,
        ),
      ),
    );
  }
}
