# Nigerian South-Western Cuisine Integration

## Overview
This app is specifically tailored to generate authentic South-Western Nigerian (Yoruba) recipes using OpenAI's GPT model. The AI has been trained through custom prompts to understand Nigerian ingredients, cooking methods, and traditional Yoruba dishes.

## 🍲 Supported Nigerian Dishes

The AI can generate recipes for popular South-Western Nigerian dishes including:

### Main Dishes
- **Jollof Rice** - The iconic Nigerian one-pot rice dish
- **Ofada Rice with Ayamase** - Local rice with designer stew
- **Fried Rice (Nigerian style)** - With Nigerian seasonings
- **Coconut Rice**
- **Native Rice (Iwuk Edesi)**

### Soups
- **Efo Riro** - Yoruba vegetable soup
- **Ewedu** - Jute leaves soup
- **Gbegiri** - Bean soup
- **Egusi** - Melon seed soup
- **Obe Ata** - Traditional pepper soup
- **Ogbono** - Draw soup

### Swallow/Staples
- **Amala** - Yam flour swallow
- **Eba** - Garri (cassava) swallow
- **Pounded Yam** - Traditional swallow
- **Fufu** - Cassava swallow
- **Iyan** - Pounded yam

### Beans Dishes
- **Ewa Agoyin** - Mashed beans with pepper sauce
- **Moin Moin** - Steamed bean pudding
- **Akara** - Bean cakes/fritters
- **Gbegiri** - Bean soup

### Breakfast/Snacks
- **Akara** - Bean fritters
- **Moin Moin** - Bean pudding
- **Pap (Ogi)** - Fermented corn pudding
- **Yam Porridge (Asaro)**
- **Plantain Porridge (Boli)

### Sides
- **Dodo** - Fried plantain
- **Gizdodo** - Gizzard and plantain
- **Nigerian Coleslaw**
- **Fried Yam**

## 🌶️ Nigerian Ingredients Recognized

### Proteins
- Beef, Goat meat, Chicken
- Fish (Eja): Titus, Mackerel, Catfish
- Stockfish, Dried fish
- Ponmo (Cow skin)
- Shaki (Tripe)
- Snails (Igbin)

### Vegetables
- Efo Shoko (Lagos spinach)
- Efo Tete (African spinach)
- Ewedu (Jute leaves)
- Gbure (Water leaf)
- Ugwu (Pumpkin leaves)

### Peppers
- Ata Rodo (Scotch bonnet)
- Tatashe (Red bell pepper)
- Shombo (Long pepper)
- Bawa (Green pepper)

### Seasonings
- Iru (Locust beans)
- Crayfish
- Palm oil
- Groundnut oil

### Staples
- Rice (Iresi)
- Beans (Ewa)
- Yam (Isu)
- Plantain (Ogede)
- Cassava (Gbaguda)

## 📝 How the AI Generates Nigerian Recipes

### System Prompt Features
The AI is instructed to:
1. **Focus on Yoruba cuisine** - Traditional South-Western Nigerian dishes
2. **Use Nigerian ingredients** - Palm oil, locust beans, crayfish, Nigerian peppers
3. **Apply authentic cooking methods** - Traditional Yoruba techniques
4. **Include Yoruba names** - Recipe titles in Yoruba with English translations
5. **Use Nigerian measurements** - Mudu, derica, paint rubber, etc.
6. **Suggest proper pairings** - E.g., Amala with Ewedu and Gbegiri

### Example AI Prompt
When you upload images with tomato, pepper, and onion, the AI receives:

```
"Create 4 authentic South-Western Nigerian (Yoruba) recipe suggestions 
using these ingredients: tomato, pepper, onion.

Include traditional Nigerian ingredients like palm oil, crayfish, 
locust beans (iru), scotch bonnet peppers, and other common Nigerian 
pantry items.

Focus on popular Yoruba dishes and traditional cooking methods.
Use Nigerian measurements and ingredient names where applicable."
```

### AI Response Example
The AI might suggest:
1. **Obe Ata (Red Stew)** - Classic tomato-pepper stew
2. **Efo Riro** - Vegetable soup with tomato base
3. **Jollof Rice** - Using the tomato-pepper blend
4. **Ayamase** - Green pepper stew

## 🎯 Customization Options

You can further customize the recipes by modifying the prompts in `lib/services/recipe_ai_service.dart`:

### For Specific Diets
```dart
String _getUserPrompt(List<String> ingredients) {
  return '''Create 4 vegetarian South-Western Nigerian recipes using: 
  ${ingredients.join(", ")}. Exclude all meat and fish.''';
}
```

### For Quick Meals
```dart
String _getUserPrompt(List<String> ingredients) {
  return '''Create 4 quick Nigerian recipes (under 30 minutes) using: 
  ${ingredients.join(", ")}. Focus on easy weeknight meals.''';
}
```

### For Party Dishes
```dart
String _getUserPrompt(List<String> ingredients) {
  return '''Create 4 party-style Nigerian recipes using: 
  ${ingredients.join(", ")}. Focus on dishes suitable for celebrations 
  and large gatherings.''';
}
```

### For Specific Occasions
```dart
String _getUserPrompt(List<String> ingredients) {
  return '''Create 4 traditional Yoruba breakfast recipes using: 
  ${ingredients.join(", ")}. Include dishes commonly eaten in 
  South-Western Nigeria for breakfast.''';
}
```

## 🔧 Testing with Nigerian Recipes

### Test Cases

1. **Test with Common Ingredients:**
   - Upload: Tomato, Pepper, Onion
   - Expected: Obe Ata, Efo Riro, Jollof Rice, Ayamase

2. **Test with Beans:**
   - Upload: Beans, Plantain
   - Expected: Ewa Agoyin, Moin Moin, Akara, Beans Porridge

3. **Test with Rice:**
   - Upload: Rice, Chicken, Vegetables
   - Expected: Jollof Rice, Fried Rice, Coconut Rice, Native Rice

4. **Test with Yam:**
   - Upload: Yam, Palm Oil
   - Expected: Asaro, Fried Yam, Yam Porridge, Yam Pepper Soup

## 📚 Nigerian Cooking Techniques

The AI understands these traditional methods:
- **Bleaching palm oil** - Heating until clear
- **Making pepper base** - Frying tomato-pepper blend
- **Steaming in leaves** - Traditional moin moin method
- **Pounding** - For yam, fufu
- **Smoking** - For fish preparation
- **Drawing** - For ogbono, okra soups

## 🌍 Regional Variations

While focused on South-Western (Yoruba) cuisine, the AI can also suggest variations from:
- **Lagos style** - Urban variations
- **Ibadan style** - Traditional Oyo recipes
- **Abeokuta style** - Ogun State specialties
- **Ondo style** - Coastal recipes
- **Ekiti style** - Hill region dishes

## 💡 Tips for Best Results

1. **Use specific Nigerian ingredients** in your images
2. **Include traditional seasonings** like locust beans, crayfish
3. **Specify meal type** if you want breakfast, lunch, or dinner recipes
4. **Mention dietary restrictions** in custom prompts if needed
5. **Check recipe details** for authentic Nigerian measurements

## 🎓 Educational Value

The app helps users:
- **Learn Yoruba names** for dishes
- **Understand traditional cooking** methods
- **Discover ingredient substitutions** in Nigerian context
- **Explore regional variations** of dishes
- **Preserve culinary heritage** through documentation

## 🔄 Continuous Improvement

The AI prompts can be updated to:
- Add more regional Nigerian cuisines (Igbo, Hausa)
- Include nutritional information
- Suggest healthier cooking methods
- Provide ingredient substitutions for diaspora users
- Add cultural context and history of dishes

---

**Ẹ kú àárọ̀! (Good morning!) Welcome to authentic Nigerian cooking!** 🇳🇬🍲
