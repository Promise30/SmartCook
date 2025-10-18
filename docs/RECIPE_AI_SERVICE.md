# Recipe AI Service - Technical Documentation

## Overview
The `RecipeAIService` integrates OpenAI's GPT-3.5-turbo model to generate personalized recipe suggestions based on detected ingredients.

## Architecture

### Configuration (`lib/config/api_config.dart`)
Centralized configuration for API settings:
- API key management
- Feature toggle (useOpenAI)
- Model settings (temperature, max tokens)

### Service (`lib/services/recipe_ai_service.dart`)

#### Key Methods

**`generateRecipeSuggestions(List<String> ingredients)`**
- Input: List of ingredient names
- Output: List of 4 RecipeSuggestion objects
- Behavior:
  - If AI enabled: Calls OpenAI API
  - If AI disabled or error: Returns mock recipes
  - Automatic fallback on failure

**`getRecipeDetails(String recipeId)`**
- Input: Recipe ID
- Output: Full Recipe object with instructions
- Features:
  - Recipe caching for performance
  - AI-generated or mock details
  - Fallback mechanism

**`_generateAIRecipes(List<String> ingredients)` (private)**
- Constructs OpenAI API request
- Parses JSON response
- Converts to RecipeSuggestion objects

**`_getRecipeDetailsFromAI(String recipeId)` (private)**
- Fetches detailed recipe from AI
- Parses structured JSON response
- Caches result

## API Integration

### Request Format
```json
{
  "model": "gpt-3.5-turbo",
  "messages": [
    {
      "role": "system",
      "content": "Expert chef instructions..."
    },
    {
      "role": "user",
      "content": "Create recipes with: tomato, onion, garlic"
    }
  ],
  "max_tokens": 2000,
  "temperature": 0.7
}
```

### Response Parsing
The service extracts JSON arrays/objects from AI responses and maps them to:
- `RecipeSuggestion`: Summary for listing
- `Recipe`: Full details with instructions

## Error Handling

1. **API Key Missing**: Falls back to mock recipes
2. **Network Error**: Returns mock recipes
3. **Invalid Response**: Throws exception, caught by caller
4. **Rate Limiting**: Handled by OpenAI SDK

## Caching Strategy

- In-memory cache (`_recipeCache`)
- Key: Recipe ID
- Lifetime: Application session
- Purpose: Reduce API calls and costs

## Data Models

### RecipeSuggestion
```dart
{
  id: String,
  title: String,
  description: String,
  ingredients: List<String>,
  prepTimeMinutes: int,
  cookTimeMinutes: int,
  difficulty: String,
  rating: double,
  category: String
}
```

### Recipe (Full Details)
```dart
{
  id: String,
  title: String,
  description: String,
  ingredients: List<String>,
  instructions: List<String>,
  prepTimeMinutes: int,
  cookTimeMinutes: int,
  servings: int,
  difficulty: String,
  rating: double,
  category: String
}
```

## Prompt Engineering

### System Prompt (Suggestions)
Instructs AI to:
- Act as expert chef
- Generate 4 creative recipes
- Use specific JSON format
- Include ratings and difficulty

### User Prompt
Simply lists ingredients: "Create 4 recipe suggestions using these ingredients: ..."

### System Prompt (Details)
Instructs AI to:
- Provide detailed recipe
- Include precise measurements
- Step-by-step instructions
- Structured JSON format

## Testing

### With Mock Data (Default)
1. Set `useOpenAI = false`
2. App uses hardcoded recipes
3. No API calls made

### With OpenAI (Production)
1. Add API key to `api_config.dart`
2. Set `useOpenAI = true`
3. Test with various ingredient combinations
4. Monitor API usage on OpenAI dashboard

## Performance Considerations

- **Caching**: Reduces redundant API calls
- **Token Optimization**: Concise prompts save costs
- **Async Operations**: Non-blocking UI
- **Error Recovery**: Graceful fallback to mock data

## Future Enhancements

- [ ] Recipe personalization (dietary restrictions)
- [ ] Image generation for recipes
- [ ] Multi-language support
- [ ] User feedback integration
- [ ] Advanced caching (persistent storage)
- [ ] Batch recipe generation
- [ ] Nutritional information
