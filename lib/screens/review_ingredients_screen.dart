import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/ingredient.dart';
import '../models/history_entry.dart';
import '../services/recipe_ai_service.dart';
import '../services/database_service.dart';
import 'recipe_suggestions_screen.dart';

class ReviewIngredientsScreen extends StatefulWidget {
  final List<Ingredient> ingredients;

  const ReviewIngredientsScreen({
    super.key,
    required this.ingredients,
  });

  @override
  State<ReviewIngredientsScreen> createState() => _ReviewIngredientsScreenState();
}

class _ReviewIngredientsScreenState extends State<ReviewIngredientsScreen> {
  late List<Ingredient> _ingredients;
  final RecipeAIService _recipeService = RecipeAIService();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ingredients = List.from(widget.ingredients);
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
                        'Review Ingredients',
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

              // Ingredients list
              Expanded(
                child: _ingredients.isEmpty
                    ? const Center(
                        child: Text(
                          'No ingredients to review.\nAdd some ingredients to get started!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _ingredients.length,
                        itemBuilder: (context, index) {
                          return _buildIngredientCard(index);
                        },
                      ),
              ),

              // Add ingredient manually button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addIngredientManually,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Add Ingredient Manually',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),

              // Continue button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _ingredients.isEmpty ? null : _continueToRecipes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Continue',
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

  Widget _buildIngredientCard(int index) {
    final ingredient = _ingredients[index];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          // Ingredient image/icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: ingredient.imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.file(
                      File(ingredient.imagePath!),
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    _getIngredientIcon(ingredient.name),
                    size: 30,
                    color: Colors.grey[600],
                  ),
          ),
          
          const SizedBox(width: 16),
          
          // Ingredient details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ingredient.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                // Only show confidence for ML-detected ingredients
                if (!ingredient.isManual)
                  Row(
                    children: [
                      Icon(
                        ingredient.confidence >= 0.85 
                            ? Icons.check_circle 
                            : Icons.warning_amber_rounded,
                        size: 16,
                        color: _getConfidenceColor(ingredient.confidence),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _getConfidenceText(ingredient.confidence),
                          style: TextStyle(
                            fontSize: 14,
                            color: _getConfidenceColor(ingredient.confidence),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else
                  // Show "Manually added" label for manual ingredients
                  Row(
                    children: [
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Manually added',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => _editIngredient(index),
                  icon: const Icon(
                    Icons.edit,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Delete button
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => _deleteIngredient(index),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIngredientIcon(String ingredientName) {
    final name = ingredientName.toLowerCase();
    if (name.contains('tomato')) return Icons.local_pizza;
    if (name.contains('onion')) return Icons.circle;
    if (name.contains('garlic')) return Icons.circle;
    if (name.contains('chicken')) return Icons.restaurant;
    if (name.contains('beef')) return Icons.restaurant;
    if (name.contains('fish')) return Icons.set_meal;
    if (name.contains('egg')) return Icons.egg;
    if (name.contains('cheese')) return Icons.circle;
    if (name.contains('milk')) return Icons.local_drink;
    if (name.contains('bread')) return Icons.bakery_dining;
    if (name.contains('rice')) return Icons.grain;
    if (name.contains('pasta')) return Icons.restaurant;
    if (name.contains('vegetable') || name.contains('spinach') || name.contains('lettuce')) {
      return Icons.eco;
    }
    return Icons.restaurant_menu;
  }

  String _getConfidenceText(double confidence) {
    if (confidence >= 0.85) return 'High confidence ✓';
    if (confidence >= 0.70) return 'Moderate confidence ⚠️';
    return 'Low - Please verify ⚠️';
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.85) return Colors.green[600]!;
    if (confidence >= 0.70) return Colors.orange[600]!;
    return Colors.red[600]!;
  }

  void _editIngredient(int index) async {
    final ingredient = _ingredients[index];
    final controller = TextEditingController(text: ingredient.name);
    File? selectedImage = ingredient.imagePath != null ? File(ingredient.imagePath!) : null;
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Ingredient'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Ingredient Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (selectedImage != null) ...[
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(selectedImage!, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.camera);
                          if (image != null) {
                            setDialogState(() {
                              selectedImage = File(image.path);
                            });
                          }
                        },
                        icon: const Icon(Icons.camera_alt, size: 20),
                        label: const Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setDialogState(() {
                              selectedImage = File(image.path);
                            });
                          }
                        },
                        icon: const Icon(Icons.photo_library, size: 20),
                        label: const Text('Gallery'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  if (selectedImage != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        setDialogState(() {
                          selectedImage = null;
                        });
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Remove Image', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop({
                    'name': controller.text,
                    'image': selectedImage,
                  });
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
    
    if (result != null) {
      setState(() {
        final File? imageFile = result['image'];
        _ingredients[index] = ingredient.copyWith(
          name: result['name'],
          imagePath: imageFile?.path,
          clearImagePath: imageFile == null && ingredient.imagePath != null,
        );
      });
    }
  }

  void _deleteIngredient(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ingredient'),
        content: Text('Are you sure you want to delete "${_ingredients[index].name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _ingredients.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addIngredientManually() async {
    final controller = TextEditingController();
    File? selectedImage;
    bool isValid = false;
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Update validation state when text changes
          controller.addListener(() {
            setDialogState(() {
              isValid = controller.text.isNotEmpty;
            });
          });
          
          return AlertDialog(
            title: const Text('Add Ingredient Manually'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Ingredient Name',
                    border: OutlineInputBorder(),
                    hintText: 'Enter ingredient name (required)',
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      isValid = value.isNotEmpty;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Image is optional - you can add one later',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                if (selectedImage != null) ...[
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(selectedImage!, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      setDialogState(() {
                        selectedImage = null;
                      });
                    },
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    label: const Text('Remove Image', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          setDialogState(() {
                            selectedImage = File(image.path);
                          });
                        }
                      },
                      icon: const Icon(Icons.camera_alt, size: 20),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setDialogState(() {
                            selectedImage = File(image.path);
                          });
                        }
                      },
                      icon: const Icon(Icons.photo_library, size: 20),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isValid
                    ? () => Navigator.of(context).pop({
                          'name': controller.text,
                          'image': selectedImage,
                        })
                    : null,
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) {
      final newIngredient = Ingredient(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: result['name'],
        confidence: 1.0, // Manual ingredients have 100% confidence
        imagePath: result['image']?.path,
        category: 'Manual',
        isManual: true,
      );

      setState(() {
        _ingredients.add(newIngredient);
      });
    }
  }

  Future<void> _continueToRecipes() async {
    if (_ingredients.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Generate recipe suggestions
      final ingredientNames = _ingredients.map((i) => i.name).toList();
      final recipes = await _recipeService.generateRecipeSuggestions(ingredientNames);
      
      // Save to history
      final historyEntry = HistoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        ingredients: _ingredients,
        suggestedRecipes: recipes,
        topRecipe: recipes.isNotEmpty ? recipes.first.title : null,
      );
      
      await _databaseService.saveHistoryEntry(historyEntry);

      // Navigate to recipe suggestions
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => RecipeSuggestionsScreen(
              ingredients: _ingredients,
              recipes: recipes,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating recipes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
