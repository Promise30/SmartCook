import '../lib/services/recipe_ai_service.dart';

void main() async {
  print('🧪 Testing Gemini Recipe Generation...\n');
  
  final service = RecipeAIService();
  
  // Test with common Nigerian ingredients
  final testIngredients = ['tomatoes', 'rice', 'chicken', 'onions'];
  
  print('📝 Test Ingredients: ${testIngredients.join(", ")}\n');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  
  try {
    final recipes = await service.generateRecipeSuggestions(testIngredients);
    
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ SUCCESS! Generated ${recipes.length} recipes\n');
    
    for (var i = 0; i < recipes.length; i++) {
      final recipe = recipes[i];
      print('📋 Recipe ${i + 1}: ${recipe.title}');
      print('   Difficulty: ${recipe.difficulty}');
      print('   Time: ${recipe.prepTimeMinutes + recipe.cookTimeMinutes} minutes');
      print('   Rating: ${recipe.rating}/5.0');
      print('   Ingredients: ${recipe.ingredients.length} items');
      print('   Instructions: ${recipe.instructions.length} steps');
      
      if (recipe.nutritionalInfo != null) {
        final nutrition = recipe.nutritionalInfo!;
        print('   Nutrition (per serving): ${nutrition.calories} cal, ${nutrition.protein}g protein, ${nutrition.carbs}g carbs, ${nutrition.fat}g fat');
      }
      
      if (recipe.description.isNotEmpty) {
        print('   Description: ${recipe.description.substring(0, recipe.description.length > 80 ? 80 : recipe.description.length)}...');
      }
      
      // Print first recipe's full instructions for review
      if (i == 0) {
        print('\n   📝 DETAILED COOKING INSTRUCTIONS:');
        for (var j = 0; j < recipe.instructions.length; j++) {
          print('   ${j + 1}. ${recipe.instructions[j]}');
        }
      }
      
      print('');
    }
    
    // Verify recipe quality
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📊 Quality Check:');
    
    final hasValidTitles = recipes.every((r) => r.title.isNotEmpty);
    final hasIngredients = recipes.every((r) => r.ingredients.isNotEmpty);
    final hasInstructions = recipes.every((r) => r.instructions.isNotEmpty);
    final hasNigerianTheme = recipes.any((r) => r.title.toLowerCase().contains('nigerian') || 
                                                  r.title.toLowerCase().contains('yoruba') ||
                                                  r.title.toLowerCase().contains('jollof') ||
                                                  r.title.toLowerCase().contains('obe') ||
                                                  r.title.toLowerCase().contains('iresi'));
    
    print('   ✓ Valid titles: ${hasValidTitles ? "YES" : "NO"}');
    print('   ✓ Has ingredients: ${hasIngredients ? "YES" : "NO"}');
    print('   ✓ Has instructions: ${hasInstructions ? "YES" : "NO"}');
    print('   ✓ Nigerian/Yoruba theme: ${hasNigerianTheme ? "YES" : "NO"}');
    
    if (hasValidTitles && hasIngredients && hasInstructions && hasNigerianTheme) {
      print('\n🎉 ALL CHECKS PASSED! Gemini is generating accurate Nigerian recipes with detailed instructions!');
    } else {
      print('\n⚠️ Some quality checks failed. Review recipe output above.');
    }
    
  } catch (e, stackTrace) {
    print('\n❌ TEST FAILED!');
    print('Error: $e');
    print('\nStack trace:');
    print(stackTrace);
  }
}
