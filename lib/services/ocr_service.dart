import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// OCR Service for reading product labels on packaged ingredients
/// 
/// This service complements the Azure ML image recognition by handling
/// packaged/wrapped ingredients where visual recognition fails.
/// 
/// Use case: Rice bags, seasoning cubes, canned goods, pasta packages, etc.
class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Analyze text density in an image to determine if OCR is appropriate
  /// Returns true if image likely contains package labels (text coverage > 20% or 3+ text regions)
  Future<bool> shouldAttemptOCR(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Check if there's substantial text content
      final textBlocks = recognizedText.blocks;
      final textLength = recognizedText.text.length;
      
      // Criteria for package detection:
      // 1. At least 3 text regions/blocks (typical for product labels)
      // 2. Substantial text content (>20 characters suggests packaging)
      if (textBlocks.length >= 3 || textLength > 20) {
        print('Text density check: ${textBlocks.length} blocks, $textLength chars - likely package');
        return true;
      }
      
      print('Text density check: ${textBlocks.length} blocks, $textLength chars - likely fresh ingredient');
      return false;
    } catch (e) {
      print('Text density analysis failed: $e');
      return false; // Don't attempt OCR if pre-check fails
    }
  }

  /// Extract text from an image using Google ML Kit
  Future<String> extractTextFromImage(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      return recognizedText.text;
    } catch (e) {
      print('OCR extraction failed: $e');
      return '';
    }
  }

  /// Parse ingredient name from product label text
  /// 
  /// Handles common Nigerian packaged products and brands
  String? parseIngredientFromLabel(String ocrText) {
    if (ocrText.isEmpty) return null;
    
    final text = ocrText.toLowerCase();
    final lines = text.split('\n').map((line) => line.trim()).toList();
    
    // Try to extract ingredient from Nigerian products
    for (var line in lines) {
      // Skip very short lines (likely noise)
      if (line.length < 2) continue;
      
      // Nigerian Seasonings (very common)
      if (_containsAny(line, ['maggi', 'knorr', 'royco', 'onga', 'seasoning'])) {
        return 'seasoning cube';
      }
      
      // Rice products
      if (_containsAny(line, ['rice', 'iresi', 'long grain', 'basmati', 'ofada'])) {
        if (_containsAny(line, ['ofada', 'brown', 'local'])) return 'ofada rice';
        if (line.contains('basmati')) return 'basmati rice';
        return 'rice';
      }
      
      // Pasta/Noodles
      if (_containsAny(line, ['pasta', 'spaghetti', 'macaroni', 'noodles', 'indomie', 'dodo'])) {
        if (line.contains('spaghetti')) return 'spaghetti';
        if (line.contains('macaroni')) return 'macaroni';
        if (line.contains('noodle') || line.contains('indomie')) return 'noodles';
        return 'pasta';
      }
      
      // Tomato products
      if (_containsAny(line, ['tomato', 'gino', 'sachet'])) {
        if (_containsAny(line, ['paste', 'puree', 'pure'])) return 'tomato paste';
        if (line.contains('tomato')) return 'tomato paste';
      }
      
      // Oils
      if (_containsAny(line, ['oil', 'palm', 'groundnut', 'vegetable', 'cooking'])) {
        if (line.contains('palm')) return 'palm oil';
        if (line.contains('groundnut') || line.contains('peanut')) return 'groundnut oil';
        if (_containsAny(line, ['vegetable', 'cooking', 'oil'])) return 'vegetable oil';
      }
      
      // Spices & Seasonings
      if (_containsAny(line, ['curry', 'currie'])) return 'curry powder';
      if (_containsAny(line, ['thyme', 'tyme'])) return 'thyme';
      if (_containsAny(line, ['pepper', 'scotch bonnet', 'ata rodo', 'habanero'])) return 'pepper';
      if (_containsAny(line, ['ginger', 'atale'])) return 'ginger';
      if (_containsAny(line, ['garlic', 'ayuu'])) return 'garlic';
      if (_containsAny(line, ['locust', 'iru', 'dawadawa'])) return 'locust beans';
      if (_containsAny(line, ['crayfish', 'ede'])) return 'crayfish';
      
      // Flour/Grains
      if (_containsAny(line, ['flour', 'poundo', 'amala'])) {
        if (_containsAny(line, ['wheat', 'golden penny'])) return 'wheat flour';
        if (line.contains('yam')) return 'yam flour';
        if (line.contains('cassava')) return 'cassava flour';
        if (line.contains('poundo')) return 'poundo yam';
        return 'flour';
      }
      if (_containsAny(line, ['beans', 'ewa', 'honey beans'])) return 'beans';
      if (_containsAny(line, ['garri', 'gari'])) return 'garri';
      if (_containsAny(line, ['semovita', 'semo'])) return 'semovita';
      if (_containsAny(line, ['egusi', 'melon'])) return 'egusi';
      
      // Canned/Packaged Proteins
      if (_containsAny(line, ['sardine', 'titus', 'mackerel', 'geisha', 'canned fish'])) return 'canned fish';
      if (_containsAny(line, ['corned beef', 'exeter', 'bully beef'])) return 'corned beef';
      if (_containsAny(line, ['chicken', 'broiler'])) return 'chicken';
      if (_containsAny(line, ['fish', 'tuna', 'salmon'])) return 'fish';
      
      // Dairy
      if (_containsAny(line, ['milk', 'peak', 'three crowns', 'dano', 'cowbell'])) return 'milk';
      if (_containsAny(line, ['butter', 'margarine', 'blue band'])) return 'butter';
      if (_containsAny(line, ['cheese', 'kraft'])) return 'cheese';
      
      // Basic Ingredients
      if (_containsAny(line, ['sugar', 'dangote sugar'])) return 'sugar';
      if (_containsAny(line, ['salt', 'dangote salt'])) return 'salt';
      if (_containsAny(line, ['onion', 'alubosa'])) return 'onion';
      if (_containsAny(line, ['stock', 'cube', 'bouillon'])) return 'stock cube';
      
      // Vegetables (packaged/frozen)
      if (_containsAny(line, ['ewedu', 'jute', 'jew mallow'])) return 'ewedu';
      if (_containsAny(line, ['okra', 'okro', 'ilá'])) return 'okra';
      if (_containsAny(line, ['spinach', 'efo tete'])) return 'spinach';
    }
    
    // Fallback: Check entire text for common ingredients
    final commonIngredients = {
      'rice': ['rice', 'iresi'],
      'beans': ['beans', 'ewa'],
      'flour': ['flour'],
      'sugar': ['sugar'],
      'salt': ['salt'],
      'oil': ['oil'],
      'milk': ['milk'],
      'pasta': ['pasta', 'spaghetti', 'macaroni'],
      'noodles': ['noodles', 'indomie'],
      'yam': ['yam', 'isu'],
      'plantain': ['plantain', 'ogede'],
      'onion': ['onion', 'alubosa'],
      'tomato': ['tomato', 'tomati'],
      'pepper': ['pepper', 'ata'],
      'garlic': ['garlic'],
      'ginger': ['ginger'],
      'curry': ['curry'],
      'thyme': ['thyme'],
      'seasoning': ['seasoning', 'maggi', 'knorr'],
      'crayfish': ['crayfish'],
      'stockfish': ['stockfish', 'panla'],
      'ponmo': ['ponmo', 'kanda'],
    };
    
    for (var entry in commonIngredients.entries) {
      for (var variant in entry.value) {
        if (text.contains(variant)) {
          return entry.key;
        }
      }
    }
    
    return null;
  }

  /// Check if text contains any of the given keywords
  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  /// Check if text contains a word (not just substring)
  bool _containsWord(String text, String word) {
    final pattern = RegExp(r'\b' + word + r'\b', caseSensitive: false);
    return pattern.hasMatch(text);
  }

  /// Get confidence level for OCR detection
  /// Based on text clarity and ingredient match
  double getConfidenceLevel(String ocrText, String? parsedIngredient) {
    if (parsedIngredient == null) return 0.0;
    
    // Higher confidence if:
    // 1. Text is clear and substantial
    // 2. Ingredient name appears multiple times
    // 3. Text has product-like structure (brand names, measurements)
    
    final text = ocrText.toLowerCase();
    final textLength = ocrText.length;
    final ingredientCount = text.split(parsedIngredient).length - 1;
    
    double confidence = 0.65; // Base confidence for OCR (slightly higher)
    
    // Boost confidence for clear text
    if (textLength > 50) confidence += 0.10; // Substantial text
    if (textLength > 100) confidence += 0.05; // Very clear image
    
    // Boost for ingredient mentions
    if (ingredientCount > 1) confidence += 0.10; // Ingredient mentioned multiple times
    if (ingredientCount > 2) confidence += 0.05; // Very prominent
    
    // Boost for product indicators
    if (text.contains(RegExp(r'\d+g|\d+kg|\d+ml|\d+l'))) confidence += 0.05; // Has weight/volume
    if (_containsAny(text, ['brand', 'product', 'ingredients', 'net weight', 'made in'])) {
      confidence += 0.05; // Has product label structure
    }
    
    // Boost for known Nigerian brands
    if (_containsAny(text, ['maggi', 'knorr', 'royco', 'onga', 'golden penny', 'dangote', 
                             'gino', 'peak', 'dano', 'indomie', 'honeywell'])) {
      confidence += 0.05; // Recognized Nigerian brand
    }
    
    return confidence.clamp(0.0, 0.95); // Max 0.95 for OCR
  }

  void dispose() {
    _textRecognizer.close();
  }
}
