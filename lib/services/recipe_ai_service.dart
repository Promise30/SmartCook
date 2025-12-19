import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../config/api_config.dart';

class RecipeAIService {
  final http.Client _client = http.Client();
  
  // Cache for storing generated recipes
  final Map<String, Recipe> _recipeCache = {};

  Future<List<RecipeSuggestion>> generateRecipeSuggestions(List<String> ingredients) async {
    print('Generating recipes for ingredients: $ingredients');
    print('Using Google Gemini API (${ApiConfig.geminiModel}) - FREE!');
    
    // No fallback - let errors propagate so failures are explicit
    return await _generateGeminiRecipes(ingredients);
  }

  Future<List<RecipeSuggestion>> _generateGeminiRecipes(List<String> ingredients) async {
    try {
      print('Calling Google Gemini API...');
      print('   Model: ${ApiConfig.geminiModel}');
      print('   Ingredients: ${ingredients.join(", ")}');
      
      final prompt = '''${_getSystemPrompt()}

User Request: ${_getUserPrompt(ingredients)}''';
      
      // Use the geminiBaseUrl which already includes the full endpoint
      final response = await _client.post(
        Uri.parse(ApiConfig.geminiBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': ApiConfig.geminiApiKey,
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

      print('Gemini Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Successfully received recipes from Gemini');
        print('Response structure: ${data.keys}');
        
        // Check if response has the expected structure
        if (data['candidates'] == null || (data['candidates'] as List).isEmpty) {
          print('ERROR: No candidates in response');
          print('   Full response: ${response.body}');
          throw Exception('Gemini API returned empty candidates');
        }
        
        // Extract text from Gemini response
        final candidate = data['candidates'][0];
        print('Candidate structure: ${candidate.keys}');
        
        final text = candidate['content']['parts'][0]['text'] as String;
        print('Extracted text length: ${text.length} characters');
        print('First 200 chars: ${text.substring(0, text.length > 200 ? 200 : text.length)}');
        
        return _parseAIResponseFromText(text, ingredients);
      } else {
        print('ERROR: Gemini API Error: ${response.statusCode}');
        print('   Response: ${response.body}');
        throw Exception('Gemini API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR: Exception in _generateGeminiRecipes: $e');
      rethrow;
    }
  }

  String _getSystemPrompt() {
    return '''You are an expert Nigerian chef specializing in South-Western Nigerian (Yoruba) cuisine. 
Given a list of ingredients, suggest 3 authentic and delicious recipes from South-Western Nigeria.

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
4. DETAILED step-by-step cooking instructions (at least 6-10 steps)
5. Preparation time in minutes
6. Cooking time in minutes
7. Difficulty level (Easy, Medium, or Hard)
8. Rating (between 4.0 and 5.0)
9. Nutritional information per serving (realistic estimates based on typical Nigerian portions)

Format your response as a JSON array with this structure:
[
  {
    "title": "Recipe Name (Yoruba Name)",
    "description": "Brief description with Nigerian context",
    "ingredients": ["ingredient 1 with Nigerian measurements", "ingredient 2", ...],
    "instructions": [
      "Step 1: Detailed instruction...",
      "Step 2: Detailed instruction...",
      "Step 3: Detailed instruction...",
      ...
    ],
    "prepTimeMinutes": 15,
    "cookTimeMinutes": 20,
    "difficulty": "Easy",
    "rating": 4.5,
    "nutritionalInfo": {
      "servings": 4,
      "calories": 450,
      "protein": 25,
      "carbs": 60,
      "fat": 15,
      "fiber": 8
    }
  }
]

IMPORTANT for servings: Provide realistic portion estimates based on:
- Typical Nigerian family meal sizes (usually 4-8 servings)
- Single-person snacks (1-2 servings)
- Party/celebration dishes (6-12 servings)
Be conservative and realistic - it's better to say "Serves 4-6" by using the lower number (4).

Be authentic to South-Western Nigerian cuisine and cooking traditions!''';
  }

  String _getUserPrompt(List<String> ingredients) {
    return '''Create 3 authentic South-Western Nigerian (Yoruba) recipe suggestions using these ingredients: ${ingredients.join(", ")}.

Include traditional Nigerian ingredients like palm oil, crayfish, locust beans (iru), scotch bonnet peppers, and other common Nigerian pantry items.
Focus on popular Yoruba dishes and traditional cooking methods.
Use Nigerian measurements and ingredient names where applicable.''';
  }

  List<RecipeSuggestion> _parseAIResponseFromText(String text, List<String> ingredients) {
    try {
      print('Parsing AI response text...');
      
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
          
          // Parse nutritional info if present
          NutritionalInfo? nutritionalInfo;
          if (json['nutritionalInfo'] != null) {
            final nutritionJson = json['nutritionalInfo'] as Map<String, dynamic>;
            nutritionalInfo = NutritionalInfo(
              servings: nutritionJson['servings'] as int,
              calories: nutritionJson['calories'] as int,
              protein: nutritionJson['protein'] as int,
              carbs: nutritionJson['carbs'] as int,
              fat: nutritionJson['fat'] as int,
              fiber: nutritionJson['fiber'] as int,
            );
          }
          
          return RecipeSuggestion(
            id: (index + 1).toString(),
            title: json['title'] as String,
            description: json['description'] as String,
            ingredients: (json['ingredients'] as List).map((i) => i.toString()).toList(),
            instructions: (json['instructions'] as List).map((i) => i.toString()).toList(),
            prepTimeMinutes: json['prepTimeMinutes'] as int,
            cookTimeMinutes: json['cookTimeMinutes'] as int,
            difficulty: json['difficulty'] as String,
            rating: (json['rating'] as num).toDouble(),
            nutritionalInfo: nutritionalInfo,
          );
        }).toList();
      } else {
        print('ERROR: No JSON array found in text');
        print('   Text content: $text');
        throw Exception('Invalid JSON format in AI response');
      }
    } catch (e, stackTrace) {
      print('ERROR: Failed to parse AI response: $e');
      print('   Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Recipe> getRecipeDetails(String recipeId) async {
    // Check cache only - no fallback
    if (_recipeCache.containsKey(recipeId)) {
      return _recipeCache[recipeId]!;
    }

    // Recipe not found in cache
    throw Exception('Recipe $recipeId not found in cache. Recipes must be generated from Gemini first.');
  }
}
