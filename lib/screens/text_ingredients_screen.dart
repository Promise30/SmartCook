import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../widgets/error_dialog.dart';
import 'recipe_preferences_screen.dart';

class TextIngredientsScreen extends StatefulWidget {
  const TextIngredientsScreen({super.key});

  @override
  State<TextIngredientsScreen> createState() => _TextIngredientsScreenState();
}

class _TextIngredientsScreenState extends State<TextIngredientsScreen> {
  final List<String> _ingredients = [];
  final TextEditingController _textController = TextEditingController();
  
  // Common Nigerian ingredients for suggestions
  final List<String> _commonIngredients = [
    'tomato', 'onion', 'pepper', 'rice', 'beans', 'plantain',
    'yam', 'chicken', 'beef', 'fish', 'palm oil', 'crayfish',
    'ewedu', 'okra', 'egusi', 'stockfish', 'ponmo', 'locust beans',
    'ata rodo', 'tatashe', 'garlic', 'ginger', 'curry', 'thyme',
    'seasoning', 'salt', 'vegetable oil', 'groundnut oil',
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50),
              Color(0xFF45a049),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Type Your Ingredients',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      
                      // Instructions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Enter ingredient names one at a time or separate with commas',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Input field with autocomplete
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Autocomplete<String>(
                                optionsBuilder: (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return const Iterable<String>.empty();
                                  }
                                  return _commonIngredients.where((ingredient) {
                                    return ingredient.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase(),
                                    );
                                  });
                                },
                                onSelected: (String selection) {
                                  _textController.text = selection;
                                  _addIngredient();
                                },
                                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                  _textController.text = controller.text;
                                  _textController.selection = controller.selection;
                                  
                                  return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: InputDecoration(
                                      hintText: 'e.g., tomato, onion, rice',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF4CAF50),
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _addIngredients(),
                                    onChanged: (value) {
                                      _textController.text = value;
                                      _textController.selection = TextSelection.fromPosition(
                                        TextPosition(offset: value.length),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _addIngredients,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Add',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Ingredients count
                      if (_ingredients.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_ingredients.length} ingredient${_ingredients.length == 1 ? '' : 's'} added',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _ingredients.clear();
                                  });
                                },
                                child: const Text(
                                  'Clear All',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 12),
                      
                      // List of added ingredients (chips)
                      Expanded(
                        child: _ingredients.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.edit_note,
                                      size: 80,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No ingredients added yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Start typing to add ingredients',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _ingredients.map((ingredient) {
                                    return Chip(
                                      label: Text(
                                        ingredient,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFFE8F5E9),
                                      deleteIcon: const Icon(
                                        Icons.close,
                                        size: 18,
                                      ),
                                      onDeleted: () => _removeIngredient(ingredient),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),
                      
                      // Continue button
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _ingredients.isEmpty ? null : _generateRecipes,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[300],
                              disabledForegroundColor: Colors.grey[500],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Generate Recipes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addIngredients() {
    final input = _textController.text.trim();
    if (input.isEmpty) return;
    
    // Support comma-separated input
    final ingredients = input.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
    
    setState(() {
      for (var ingredient in ingredients) {
        final normalizedIngredient = ingredient.toLowerCase();
        if (!_ingredients.contains(normalizedIngredient)) {
          _ingredients.add(normalizedIngredient);
        }
      }
      _textController.clear();
    });
  }

  void _addIngredient() {
    final ingredient = _textController.text.trim();
    if (ingredient.isNotEmpty) {
      final normalizedIngredient = ingredient.toLowerCase();
      if (!_ingredients.contains(normalizedIngredient)) {
        setState(() {
          _ingredients.add(normalizedIngredient);
          _textController.clear();
        });
      }
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _ingredients.remove(ingredient);
    });
  }

  Future<void> _generateRecipes() async {
    // Validate minimum ingredients
    if (_ingredients.length < 2) {
      ErrorDialog.showSimple(
        context,
        title: 'More Ingredients Needed',
        message: 'Please add at least 2 ingredients to generate recipes.',
      );
      return;
    }

    // Convert ingredient names to Ingredient objects
    final ingredientObjects = _ingredients.map((name) {
      return Ingredient(
        id: DateTime.now().millisecondsSinceEpoch.toString() + name.hashCode.toString(),
        name: name,
        confidence: 1.0, // Manual ingredients have 100% confidence
        imagePath: null,
        category: 'Manual',
        isManual: true,
        detectionMethod: 'manual',
      );
    }).toList();

    // Navigate to recipe preferences screen
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RecipePreferencesScreen(
            ingredients: ingredientObjects,
          ),
        ),
      );
    }
  }
}
