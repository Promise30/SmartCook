import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../config/api_config.dart';

class RecipeAIService {
  final http.Client _client = http.Client();
  
  // Cache for storing generated recipes
  final Map<String, Recipe> _recipeCache = {};

  Future<List<RecipeSuggestion>> generateRecipeSuggestions(List<String> ingredients) async {
    try {
      print('🍳 Generating recipes for ingredients: $ingredients');
      print('📋 Config Check: useGemini=${ApiConfig.useGemini}, useOpenAI=${ApiConfig.useOpenAI}');
      print('📋 Gemini Key Length: ${ApiConfig.geminiApiKey.length} chars');
      print('📋 Key starts with: ${ApiConfig.geminiApiKey.substring(0, 10)}...');
      
      // Try Gemini first (FREE!)
      if (ApiConfig.useGemini && ApiConfig.geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE') {
        print('✅ Using Google Gemini API (${ApiConfig.geminiModel}) - FREE!');
        return await _generateGeminiRecipes(ingredients);
      } else {
        print('⚠️ Gemini check failed: useGemini=${ApiConfig.useGemini}, keyValid=${ApiConfig.geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE'}');
      }
      
      // Fall back to OpenAI if configured
      if (ApiConfig.useOpenAI && ApiConfig.openAiApiKey != 'YOUR_OPENAI_API_KEY_HERE') {
        print('✅ Using OpenAI API (${ApiConfig.openAiModel})');
        return await _generateAIRecipes(ingredients);
      }
      
      print('⚠️ Using mock recipes (No AI configured)');
      // Fallback to mock data
      return _generateMockRecipes(ingredients);
    } catch (e) {
      print('❌ Error generating AI recipes: $e');
      print('📋 Falling back to mock recipes');
      // Fallback to mock data on error
      return _generateMockRecipes(ingredients);
    }
  }

  Future<List<RecipeSuggestion>> _generateGeminiRecipes(List<String> ingredients) async {
    try {
      print('📡 Calling Google Gemini API...');
      print('   Model: ${ApiConfig.geminiModel}');
      print('   Ingredients: ${ingredients.join(", ")}');
      
      final prompt = '''${_getSystemPrompt()}

User Request: ${_getUserPrompt(ingredients)}''';
      
      // Use the geminiBaseUrl which already includes the full endpoint
      final response = await _client.post(
        Uri.parse(ApiConfig.geminiBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': ApiConfig.geminiApiKey,  // Using x-goog-api-key header
        },
        body: jsonEncode({
          'contents': [{
            'parts': [{'text': prompt}]
          }],
          'generationConfig': {
            'temperature': ApiConfig.temperature,
            'maxOutputTokens': ApiConfig.maxTokens,
          }
        }),
      );

      print('📬 Gemini Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully received recipes from Gemini');
        print('📄 Response structure: ${data.keys}');
        
        // Check if response has the expected structure
        if (data['candidates'] == null || (data['candidates'] as List).isEmpty) {
          print('❌ No candidates in response');
          print('   Full response: ${response.body}');
          throw Exception('Gemini API returned empty candidates');
        }
        
        // Extract text from Gemini response
        final candidate = data['candidates'][0];
        print('📄 Candidate structure: ${candidate.keys}');
        
        final text = candidate['content']['parts'][0]['text'] as String;
        print('📝 Extracted text length: ${text.length} characters');
        print('📝 First 200 chars: ${text.substring(0, text.length > 200 ? 200 : text.length)}');
        
        return _parseAIResponseFromText(text, ingredients);
      } else {
        print('❌ Gemini API Error: ${response.statusCode}');
        print('   Response: ${response.body}');
        throw Exception('Gemini API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception in _generateGeminiRecipes: $e');
      rethrow;
    }
  }

  Future<List<RecipeSuggestion>> _generateAIRecipes(List<String> ingredients) async {
    try {
      print('📡 Calling OpenAI API...');
      print('   Model: ${ApiConfig.openAiModel}');
      print('   Ingredients: ${ingredients.join(", ")}');
      
      final response = await _client.post(
        Uri.parse('${ApiConfig.openAiBaseUrl}/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${ApiConfig.openAiApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': ApiConfig.openAiModel,
          'messages': [
            {
              'role': 'system',
              'content': _getSystemPrompt(),
            },
            {
              'role': 'user',
              'content': _getUserPrompt(ingredients),
            },
          ],
          'max_tokens': ApiConfig.maxTokens,
          'temperature': ApiConfig.temperature,
        }),
      );

      print('📬 OpenAI Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully received recipes from OpenAI');
        return _parseAIResponse(data, ingredients);
      } else {
        print('❌ OpenAI API Error: ${response.statusCode}');
        print('   Response: ${response.body}');
        throw Exception('OpenAI API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception in _generateAIRecipes: $e');
      rethrow;
    }
  }

  String _getSystemPrompt() {
    return '''You are an expert Nigerian chef specializing in South-Western Nigerian (Yoruba) cuisine. 
Given a list of ingredients, suggest 4 authentic and delicious recipes from South-Western Nigeria.

IMPORTANT: Focus on traditional Yoruba dishes and cooking methods. Use Nigerian ingredients, seasonings, and cooking techniques.
Include dishes like: Amala, Ewedu, Gbegiri, Ata dindin, Ofada rice, Asaro, Efo riro, Obe ata, Moin moin, Akara, Dodo, etc.

Common South-Western Nigerian ingredients to consider:
- Palm oil, groundnut oil, locust beans (iru), crayfish, stockfish
- Scotch bonnet peppers (ata rodo), bell peppers (tatashe), chili peppers
- Yam, cassava, plantain, cocoyam
- Ewedu, gbure (water leaf), efo shoko (Lagos spinach), efo tete
- Beans (ewa), rice (iresi), corn (agbado)
- Beef, chicken, fish (eja), snails (igbin), ponmo (cow skin)
- Traditional seasonings: iru (locust beans), dried fish, crayfish

For each recipe, provide:
1. A title (use Yoruba names where appropriate, with English translation)
2. A brief description highlighting Nigerian cooking style
3. List of ingredients (use Nigerian ingredient names and measurements)
4. Preparation time in minutes
5. Cooking time in minutes
6. Difficulty level (Easy, Medium, or Hard)
7. Rating (between 4.0 and 5.0)
8. Category (Breakfast, Lunch, Dinner, Snack, or Soup)

Format your response as a JSON array with this structure:
[
  {
    "title": "Recipe Name (Yoruba Name)",
    "description": "Brief description with Nigerian context",
    "ingredients": ["ingredient 1 with Nigerian measurements", "ingredient 2", ...],
    "prepTimeMinutes": 15,
    "cookTimeMinutes": 20,
    "difficulty": "Easy",
    "rating": 4.5,
    "category": "Dinner"
  }
]

Be authentic to South-Western Nigerian cuisine and cooking traditions!''';
  }

  String _getUserPrompt(List<String> ingredients) {
    return '''Create 4 authentic South-Western Nigerian (Yoruba) recipe suggestions using these ingredients: ${ingredients.join(", ")}.

Include traditional Nigerian ingredients like palm oil, crayfish, locust beans (iru), scotch bonnet peppers, and other common Nigerian pantry items.
Focus on popular Yoruba dishes and traditional cooking methods.
Use Nigerian measurements and ingredient names where applicable.''';
  }

  List<RecipeSuggestion> _parseAIResponseFromText(String text, List<String> ingredients) {
    try {
      print('🔍 Parsing AI response text...');
      
      // Extract JSON array from the response text
      final jsonStart = text.indexOf('[');
      final jsonEnd = text.lastIndexOf(']') + 1;
      
      print('   JSON start index: $jsonStart, end index: $jsonEnd');
      
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonString = text.substring(jsonStart, jsonEnd);
        print('   Extracted JSON length: ${jsonString.length} characters');
        
        final List<dynamic> recipesJson = jsonDecode(jsonString);
        print('   Parsed ${recipesJson.length} recipes');
        
        return recipesJson.asMap().entries.map((entry) {
          final index = entry.key;
          final json = entry.value as Map<String, dynamic>;
          
          return RecipeSuggestion(
            id: (index + 1).toString(),
            title: json['title'] as String,
            description: json['description'] as String,
            ingredients: (json['ingredients'] as List).map((i) => i.toString()).toList(),
            prepTimeMinutes: json['prepTimeMinutes'] as int,
            cookTimeMinutes: json['cookTimeMinutes'] as int,
            difficulty: json['difficulty'] as String,
            rating: (json['rating'] as num).toDouble(),
            category: json['category'] as String,
          );
        }).toList();
      } else {
        print('❌ No JSON array found in text');
        print('   Text content: $text');
        throw Exception('Invalid JSON format in AI response');
      }
    } catch (e, stackTrace) {
      print('❌ Failed to parse AI response: $e');
      print('   Stack trace: $stackTrace');
      rethrow;
    }
  }

  List<RecipeSuggestion> _parseAIResponse(Map<String, dynamic> data, List<String> ingredients) {
    try {
      final content = data['choices'][0]['message']['content'] as String;
      
      // Extract JSON array from the response
      final jsonStart = content.indexOf('[');
      final jsonEnd = content.lastIndexOf(']') + 1;
      
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonString = content.substring(jsonStart, jsonEnd);
        final List<dynamic> recipesJson = jsonDecode(jsonString);
        
        return recipesJson.asMap().entries.map((entry) {
          final index = entry.key;
          final json = entry.value as Map<String, dynamic>;
          
          return RecipeSuggestion(
            id: (index + 1).toString(),
            title: json['title'] as String,
            description: json['description'] as String,
            ingredients: (json['ingredients'] as List).map((i) => i.toString()).toList(),
            prepTimeMinutes: json['prepTimeMinutes'] as int,
            cookTimeMinutes: json['cookTimeMinutes'] as int,
            difficulty: json['difficulty'] as String,
            rating: (json['rating'] as num).toDouble(),
            category: json['category'] as String,
          );
        }).toList();
      } else {
        throw Exception('Invalid JSON format in AI response');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Recipe> _getRecipeDetailsFromAI(String recipeId) async {
    try {
      // Request detailed recipe from OpenAI
      final response = await _client.post(
        Uri.parse('${ApiConfig.openAiBaseUrl}/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${ApiConfig.openAiApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': ApiConfig.openAiModel,
          'messages': [
            {
              'role': 'system',
              'content': '''You are an expert Nigerian chef specializing in South-Western Nigerian (Yoruba) cuisine. 
Provide a detailed authentic Nigerian recipe in JSON format with this exact structure:
{
  "title": "Recipe Name (with Yoruba name if applicable)",
  "description": "Detailed description highlighting Nigerian cooking traditions",
  "ingredients": ["ingredient 1 with Nigerian measurements", "ingredient 2", ...],
  "instructions": ["step 1 with Nigerian cooking techniques", "step 2", ...],
  "prepTimeMinutes": 15,
  "cookTimeMinutes": 20,
  "servings": 4,
  "difficulty": "Easy",
  "rating": 4.5,
  "category": "Dinner"
}

Use Nigerian ingredients like palm oil, crayfish, locust beans, scotch bonnet peppers.
Include traditional Yoruba cooking methods and techniques.
Use Nigerian measurements (mudu, derica, paint rubber, etc.) where appropriate.''',
            },
            {
              'role': 'user',
              'content': 'Provide a complete South-Western Nigerian recipe for ID $recipeId. Include detailed instructions with traditional Nigerian cooking methods, precise ingredient measurements using Nigerian terms, and authentic Yoruba culinary techniques.',
            },
          ],
          'max_tokens': 1500,
          'temperature': ApiConfig.temperature,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        
        // Extract JSON from the response
        final jsonStart = content.indexOf('{');
        final jsonEnd = content.lastIndexOf('}') + 1;
        
        if (jsonStart != -1 && jsonEnd > jsonStart) {
          final jsonString = content.substring(jsonStart, jsonEnd);
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          
          return Recipe(
            id: recipeId,
            title: json['title'] as String,
            description: json['description'] as String,
            ingredients: (json['ingredients'] as List).map((i) => i.toString()).toList(),
            instructions: (json['instructions'] as List).map((i) => i.toString()).toList(),
            prepTimeMinutes: json['prepTimeMinutes'] as int,
            cookTimeMinutes: json['cookTimeMinutes'] as int,
            servings: json['servings'] as int,
            difficulty: json['difficulty'] as String,
            rating: (json['rating'] as num).toDouble(),
            category: json['category'] as String,
          );
        } else {
          throw Exception('Invalid JSON format in AI response');
        }
      } else {
        throw Exception('Failed to get recipe details from AI');
      }
    } catch (e) {
      rethrow;
    }
  }


  List<RecipeSuggestion> _generateMockRecipes(List<String> ingredients) {
    print('📋 Generating mock Nigerian recipes for: $ingredients');
    
    // Normalize ingredient names (lowercase for matching)
    final normalizedIngredients = ingredients.map((i) => i.toLowerCase()).toList();
    final ingredientStr = normalizedIngredients.join(', ');
    
    // Generate mock Nigerian recipes based on ACTUAL detected ingredients
    List<RecipeSuggestion> recipes = [];
    
    // Pattern 1: Tomato-based dishes
    if (normalizedIngredients.any((i) => ['tomato', 'ata_rodo', 'onion', 'pepper'].contains(i))) {
      recipes.add(RecipeSuggestion(
        id: '1',
        title: 'Obe Ata (Red Stew) with ${normalizedIngredients.take(3).join(", ")}',
        description: 'Classic Yoruba tomato-based stew using your detected ingredients: $ingredientStr',
        ingredients: [...ingredients, 'palm oil', 'crayfish', 'locust beans (iru)', 'seasoning'],
        prepTimeMinutes: 20,
        cookTimeMinutes: 40,
        difficulty: 'Medium',
        rating: 4.7,
        category: 'Dinner',
      ));
    }
    
    // Pattern 2: Rice dishes
    if (normalizedIngredients.contains('rice')) {
      final otherIngredients = ingredients.where((i) => i.toLowerCase() != 'rice').toList();
      recipes.add(RecipeSuggestion(
        id: '3',
        title: 'Jollof Rice with ${otherIngredients.isNotEmpty ? otherIngredients.join(" and ") : "vegetables"}',
        description: 'Nigerian one-pot rice dish featuring: $ingredientStr',
        ingredients: [...ingredients, 'groundnut oil', 'curry', 'thyme', 'bay leaves', 'stock'],
        prepTimeMinutes: 20,
        cookTimeMinutes: 45,
        difficulty: 'Medium',
        rating: 4.8,
        category: 'Dinner',
      ));
    }
    
    // Pattern 3: Beans dishes
    if (normalizedIngredients.contains('beans')) {
      recipes.add(RecipeSuggestion(
        id: '5',
        title: 'Ewa Agoyin (Mashed Beans) with ${ingredients.where((i) => i.toLowerCase() != 'beans').join(", ")}',
        description: 'Popular Lagos street food using: $ingredientStr',
        ingredients: [...ingredients, 'palm oil', 'dried pepper', 'crayfish', 'salt'],
        prepTimeMinutes: 15,
        cookTimeMinutes: 90,
        difficulty: 'Easy',
        rating: 4.5,
        category: 'Lunch',
      ));
    }
    
    // Pattern 4: Vegetable soups (ewedu, waterleaf, okra)
    if (normalizedIngredients.any((i) => ['ewedu', 'waterleaf', 'okra'].contains(i))) {
      final veggie = normalizedIngredients.firstWhere((i) => ['ewedu', 'waterleaf', 'okra'].contains(i), orElse: () => 'vegetable');
      recipes.add(RecipeSuggestion(
        id: '2',
        title: '${veggie.toUpperCase()} Soup with ${ingredients.where((i) => i.toLowerCase() != veggie).take(2).join(" and ")}',
        description: 'Traditional Yoruba soup using: $ingredientStr',
        ingredients: [...ingredients, 'palm oil', 'crayfish', 'locust beans (iru)', 'ponmo', 'stockfish'],
        prepTimeMinutes: 25,
        cookTimeMinutes: 35,
        difficulty: 'Medium',
        rating: 4.6,
        category: 'Soup',
      ));
    }
    
    // Pattern 5: Yam/Plantain dishes
    if (normalizedIngredients.any((i) => ['yam', 'plantain', 'potato'].contains(i))) {
      final starch = normalizedIngredients.firstWhere((i) => ['yam', 'plantain', 'potato'].contains(i), orElse: () => 'yam');
      recipes.add(RecipeSuggestion(
        id: '6',
        title: '${starch.toUpperCase()} Porridge with ${ingredients.where((i) => i.toLowerCase() != starch).take(2).join(", ")}',
        description: 'Comforting one-pot dish featuring: $ingredientStr',
        ingredients: [...ingredients, 'palm oil', 'crayfish', 'stockfish', 'seasoning'],
        prepTimeMinutes: 20,
        cookTimeMinutes: 30,
        difficulty: 'Easy',
        rating: 4.4,
        category: 'Dinner',
      ));
    }
    
    // Pattern 6: Protein dishes (chicken, catfish, ponmo)
    if (normalizedIngredients.any((i) => ['catfish', 'chicken', 'ponmo'].contains(i))) {
      final protein = normalizedIngredients.firstWhere((i) => ['catfish', 'chicken', 'ponmo'].contains(i), orElse: () => 'protein');
      recipes.add(RecipeSuggestion(
        id: '10',
        title: '${protein.toUpperCase()} Pepper Soup with ${ingredients.where((i) => i.toLowerCase() != protein).take(2).join(", ")}',
        description: 'Spicy Nigerian soup using: $ingredientStr',
        ingredients: [...ingredients, 'uziza seeds', 'ehuru', 'scent leaves', 'seasoning cubes'],
        prepTimeMinutes: 15,
        cookTimeMinutes: 25,
        difficulty: 'Easy',
        rating: 4.7,
        category: 'Soup',
      ));
    }
    
    // Generic recipe with ALL detected ingredients
    if (recipes.isEmpty || recipes.length < 3) {
      recipes.add(RecipeSuggestion(
        id: '11',
        title: 'Nigerian Mixed Dish with $ingredientStr',
        description: 'Creative recipe combining all your detected ingredients',
        ingredients: [...ingredients, 'palm oil', 'seasoning', 'salt', 'water'],
        prepTimeMinutes: 15,
        cookTimeMinutes: 30,
        difficulty: 'Easy',
        rating: 4.3,
        category: 'Dinner',
      ));
    }
    
    // Add popular Nigerian dishes if we need more suggestions
    if (recipes.length < 4) {
      recipes.addAll([
        RecipeSuggestion(
          id: '7',
          title: 'Moin Moin with your ingredients',
          description: 'Steamed bean pudding enhanced with: $ingredientStr',
          ingredients: ['black-eyed beans', ...ingredients.take(3), 'palm oil', 'eggs', 'crayfish'],
          prepTimeMinutes: 30,
          cookTimeMinutes: 45,
          difficulty: 'Medium',
          rating: 4.6,
          category: 'Snack',
        ),
        RecipeSuggestion(
          id: '8',
          title: 'Gizdodo (Gizzard and Plantain)',
          description: 'Popular Lagos dish that goes well with: $ingredientStr',
          ingredients: ['plantain', 'gizzard', ...ingredients.take(2), 'bell pepper', 'groundnut oil'],
          prepTimeMinutes: 20,
          cookTimeMinutes: 25,
          difficulty: 'Medium',
          rating: 4.5,
          category: 'Appetizer',
        ),
      ]);
    }
    
    print('✅ Generated ${recipes.length} mock recipes using detected ingredients');
    return recipes.take(6).toList();
  }

  Future<Recipe> getRecipeDetails(String recipeId) async {
    // Check cache first
    if (_recipeCache.containsKey(recipeId)) {
      return _recipeCache[recipeId]!;
    }

    // If using AI and recipe not in cache, fetch from AI
    if (ApiConfig.useOpenAI && ApiConfig.openAiApiKey != 'YOUR_OPENAI_API_KEY_HERE') {
      try {
        final recipe = await _getRecipeDetailsFromAI(recipeId);
        _recipeCache[recipeId] = recipe;
        return recipe;
      } catch (e) {
        // Fall through to mock data
      }
    }

    // Fallback to mock detailed Nigerian recipes
    // Return different recipes based on ID
    switch (recipeId) {
      case '1':
        return Recipe(
          id: '1',
          title: 'Obe Ata (Nigerian Red Stew)',
          description: 'Classic South-Western Nigerian tomato-based stew with rich pepper blend. This versatile stew is the foundation of many Nigerian dishes and can be served with rice, beans, yam, or plantain.',
          ingredients: [
            '8 large fresh tomatoes (or 1 tin tomato paste)',
            '4 red bell peppers (tatashe)',
            '3-4 scotch bonnet peppers (ata rodo) - adjust to taste',
            '2 large onions',
            '1/2 cup palm oil (or vegetable oil)',
            '3 tbsp ground crayfish',
            '2 tbsp locust beans (iru) - optional',
            '2 pieces stockfish (soaked and deboned)',
            '2 seasoning cubes',
            '1 tsp curry powder',
            '1 tsp thyme',
            'Salt to taste',
          ],
          instructions: [
            'Blend tomatoes, tatashe, scotch bonnet peppers, and 1 onion until smooth',
            'Pour the blended mixture into a pot and boil for 15-20 minutes to reduce the water content',
            'Heat palm oil in a large pot until it bleaches (turns clear)',
            'Add the remaining chopped onion and fry until golden',
            'Pour in the boiled pepper mixture and fry for 20-25 minutes, stirring occasionally',
            'Add crayfish, locust beans (iru), and stockfish',
            'Season with curry powder, thyme, seasoning cubes, and salt',
            'Continue cooking for another 10-15 minutes until the oil floats to the top',
            'Taste and adjust seasoning as needed',
            'Serve hot with rice, beans, yam, or fried plantain (dodo)',
          ],
          prepTimeMinutes: 20,
          cookTimeMinutes: 40,
          servings: 6,
          difficulty: 'Medium',
          rating: 4.7,
          category: 'Dinner',
        );
      case '2':
        return Recipe(
          id: '2',
          title: 'Efo Riro (Yoruba Vegetable Soup)',
          description: 'Traditional South-Western Nigerian vegetable soup with rich palm oil base. A nutritious and flavorful soup perfect with pounded yam, eba, or rice.',
          ingredients: [
            '4 bunches efo shoko (Lagos spinach) or any green leafy vegetable',
            '1/2 cup palm oil',
            '5 large tomatoes (blended)',
            '3 scotch bonnet peppers (blended)',
            '2 red bell peppers (blended)',
            '1 large onion (chopped)',
            '1/2 cup ground crayfish',
            '2 tbsp locust beans (iru)',
            '500g assorted meat (beef, goat meat)',
            '200g ponmo (cow skin)',
            '2 pieces stockfish (soaked)',
            '100g dried fish',
            '2 seasoning cubes',
            'Salt to taste',
          ],
          instructions: [
            'Wash and roughly chop the efo shoko, set aside',
            'Season and cook the assorted meat, ponmo, and stockfish until tender',
            'Heat palm oil in a large pot until slightly hot',
            'Add chopped onions and fry until fragrant',
            'Pour in the blended pepper mixture and fry for 15-20 minutes',
            'Add meat stock, crayfish, and locust beans (iru)',
            'Add the cooked meat, ponmo, stockfish, and dried fish',
            'Season with seasoning cubes and salt, stir well',
            'Let it simmer for 5 minutes to blend all flavors',
            'Add the chopped efo shoko and stir gently',
            'Cook for 3-5 minutes (don\'t overcook to maintain vitamins)',
            'Serve hot with your choice of swallow (pounded yam, eba, amala)',
          ],
          prepTimeMinutes: 25,
          cookTimeMinutes: 35,
          servings: 6,
          difficulty: 'Medium',
          rating: 4.6,
          category: 'Soup',
        );
      case '3':
        return Recipe(
          id: '3',
          title: 'Nigerian Jollof Rice',
          description: 'The iconic West African one-pot rice dish with rich tomato flavor and perfectly cooked rice. This party favorite is a must-have at any Nigerian celebration.',
          ingredients: [
            '4 cups long grain parboiled rice',
            '5-6 large tomatoes (blended)',
            '3 red bell peppers (tatashe - blended)',
            '2-3 scotch bonnet peppers (blended)',
            '1 large onion (half blended, half chopped)',
            '1/2 cup groundnut oil or vegetable oil',
            '3 tbsp tomato paste',
            '1 kg chicken or beef (seasoned and cooked)',
            '3 cups chicken/beef stock',
            '2 seasoning cubes',
            '2 bay leaves',
            '1 tsp curry powder',
            '1 tsp thyme',
            '1 tsp garlic powder',
            '1 tsp ginger powder',
            'Salt to taste',
          ],
          instructions: [
            'Parboil rice with a pinch of salt for 5 minutes, drain and set aside',
            'Heat oil in a large pot and fry chopped onions until soft',
            'Add tomato paste and fry for 2 minutes',
            'Pour in blended tomatoes and peppers, fry for 20-25 minutes until oil rises',
            'Add curry powder, thyme, bay leaves, and seasoning cubes',
            'Pour in chicken stock and bring to a boil',
            'Taste and adjust seasoning with salt if needed',
            'Add the parboiled rice and stir well to coat with the sauce',
            'Add the cooked chicken/beef on top',
            'Cover tightly with foil and then the pot lid to trap steam',
            'Cook on medium heat for 15 minutes, then reduce to low heat',
            'Cook for another 15-20 minutes until rice is tender and water is absorbed',
            'Turn off heat and let it sit covered for 5 minutes',
            'Fluff with a fork and serve hot with fried plantain, coleslaw, or moi moi',
          ],
          prepTimeMinutes: 20,
          cookTimeMinutes: 45,
          servings: 8,
          difficulty: 'Medium',
          rating: 4.8,
          category: 'Dinner',
        );
      case '4':
        return Recipe(
          id: '4',
          title: 'Ofada Rice with Ayamase (Designer Stew)',
          description: 'Local unpolished Nigerian rice served with spicy green pepper sauce. This delicacy from Ogun State is a favorite at parties and special occasions.',
          ingredients: [
            '4 cups Ofada rice (or any local brown rice)',
            '10 green bell peppers (green tatashe)',
            '3-4 scotch bonnet peppers (ata rodo)',
            '2 large onions (1 whole, 1 sliced)',
            '1 cup palm oil',
            '3 tbsp locust beans (iru)',
            '500g assorted meat (beef, goat meat, ponmo)',
            '200g shaki (tripe)',
            '4 hard-boiled eggs',
            '2 seasoning cubes',
            '1 tsp ground crayfish',
            'Salt to taste',
          ],
          instructions: [
            'Wash ofada rice thoroughly to remove excess starch and sand',
            'Cook rice with plenty of water until tender (about 30 minutes)',
            'Drain and rinse with cold water, set aside',
            'Roughly blend green peppers, scotch bonnet, and 1 onion (should be chunky, not smooth)',
            'Season and cook assorted meat and shaki until very tender',
            'Heat palm oil in a pot until it bleaches slightly',
            'Add sliced onions and fry until dark brown (this gives ayamase its unique taste)',
            'Add locust beans (iru) and ground crayfish, stir for 1 minute',
            'Pour in the blended green pepper mixture',
            'Fry on high heat for 10-15 minutes, stirring occasionally',
            'Add the cooked meat, shaki, and some meat stock',
            'Season with seasoning cubes and salt',
            'Simmer for 10 minutes until the sauce thickens',
            'Add hard-boiled eggs and cook for 2 more minutes',
            'Serve hot ofada rice with the ayamase sauce on the side',
          ],
          prepTimeMinutes: 25,
          cookTimeMinutes: 50,
          servings: 6,
          difficulty: 'Hard',
          rating: 4.7,
          category: 'Lunch',
        );
      default:
        // Default fallback recipe
        return Recipe(
          id: recipeId,
          title: 'Moin Moin (Nigerian Bean Pudding)',
          description: 'Steamed bean pudding - a popular Nigerian protein-rich dish perfect as a meal or snack. Traditionally steamed in leaves (ewe eran) but can be made in cups or aluminum containers.',
          ingredients: [
            '3 cups black-eyed beans (ewa oloyin)',
            '2 red bell peppers (tatashe)',
            '2 scotch bonnet peppers (adjust to taste)',
            '1 large onion',
            '1/2 cup palm oil or vegetable oil',
            '1/4 cup ground crayfish',
            '2 seasoning cubes',
            '4 hard-boiled eggs (sliced)',
            '100g smoked fish (deboned and flaked)',
            '1 cup warm water or stock',
            'Salt to taste',
            'Moin moin leaves or containers for steaming',
          ],
          instructions: [
            'Soak beans for 5 minutes, then rub to remove skins. Wash thoroughly',
            'Blend beans with peppers and onion until smooth (add minimal water)',
            'Pour blended mixture into a large bowl',
            'Add oil, crayfish, seasoning cubes, and salt. Mix well',
            'Add warm water gradually to achieve a thick but pourable consistency',
            'Taste and adjust seasoning',
            'Prepare your steaming containers (leaves, cups, or small bowls)',
            'Pour mixture into containers, filling 3/4 full',
            'Add pieces of egg and fish to each container',
            'Boil water in a large pot with a steaming rack',
            'Place moin moin containers in the pot',
            'Cover tightly and steam for 45-60 minutes on medium heat',
            'Check by inserting a skewer - it should come out clean when done',
            'Remove from heat and let cool for 5 minutes before serving',
            'Serve warm with pap, bread, custard, or as a side dish',
          ],
          prepTimeMinutes: 30,
          cookTimeMinutes: 60,
          servings: 8,
          difficulty: 'Medium',
          rating: 4.6,
          category: 'Snack',
        );
    }
  }
}
