import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Service for Nigerian Ingredients Recognition API
/// Connects to your Flask ML model server
class IngredientsAPIService {
  // IMPORTANT: Update this IP address to match your computer's local IP
  // For local testing: Use your computer's IP address (e.g., 192.168.1.197)
  // For production: Use your deployed API URL (e.g., https://your-api.render.com)
  
  // Azure Production API
  static const String baseUrl = 'https://food-ingredients-recogition-api.azurewebsites.net';
  
  // Uncomment below for local testing:
  // static const String baseUrl = 'http://192.168.1.197:5000';
  
  // Enable mock mode when Azure is down
  static const bool useMockMode = false;  // Azure is now working!
  
  final http.Client _client = http.Client();

  /// Predict multiple ingredients from images
  /// 
  /// Takes a list of image files and returns predictions for each one
  /// Perfect for mobile apps where users capture multiple ingredient photos
  Future<Map<String, dynamic>> predictMultiple(List<File> images) async {
    // Use mock data when Azure is down
    if (useMockMode) {
      return _generateMockPredictions(images.length);
    }
    
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict-multiple'),
      );

      // Add all images to the request
      for (var image in images) {
        var stream = http.ByteStream(image.openRead());
        var length = await image.length();
        var multipartFile = http.MultipartFile(
          'images',  // This must match the Flask endpoint parameter name
          stream,
          length,
          filename: image.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Predict single ingredient from image
  /// 
  /// For testing single images or when user captures one ingredient
  Future<Map<String, dynamic>> predictSingle(File image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );

      var stream = http.ByteStream(image.openRead());
      var length = await image.length();
      var multipartFile = http.MultipartFile(
        'image',  // Note: single 'image' not 'images'
        stream,
        length,
        filename: image.path.split('/').last,
      );
      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Test connection to API
  /// 
  /// Call this to verify the API is reachable before sending images
  Future<bool> testConnection() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['model_loaded'] == true;
      }
      return false;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  /// Get list of supported ingredients
  /// 
  /// Returns all 15 Nigerian ingredients the model can recognize
  Future<List<String>> getIngredients() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/ingredients'),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<String>.from(data['ingredients']);
        }
      }
      return [];
    } catch (e) {
      print('Failed to get ingredients: $e');
      return [];
    }
  }

  /// Submit feedback for incorrect prediction
  /// 
  /// Helps improve the model by reporting wrong predictions
  Future<bool> submitFeedback({
    required File image,
    required String predicted,
    required String actual,
    String? userNotes,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/feedback'),
      );

      // Add image
      var stream = http.ByteStream(image.openRead());
      var length = await image.length();
      var multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: image.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Add form fields
      request.fields['predicted'] = predicted;
      request.fields['actual'] = actual;
      if (userNotes != null) {
        request.fields['user_notes'] = userNotes;
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200;
    } catch (e) {
      print('Failed to submit feedback: $e');
      return false;
    }
  }

  /// Generate mock predictions for testing when API is unavailable
  Map<String, dynamic> _generateMockPredictions(int imageCount) {
    final mockIngredients = [
      'Tomato', 'Onion', 'Bell Pepper', 'Scotch Bonnet', 'Garlic',
      'Ginger', 'Palm Oil', 'Locust Beans', 'Stockfish', 'Crayfish'
    ];
    
    final predictions = <Map<String, dynamic>>[];
    for (int i = 0; i < imageCount && i < mockIngredients.length; i++) {
      predictions.add({
        'ingredient': mockIngredients[i],
        'confidence': 0.85 + (i * 0.03), // 85-97% confidence
      });
    }
    
    return {
      'success': true,
      'predictions': predictions,
      'model_version': 'mock-v1.0',
      'processing_time': '0.1s',
    };
  }

  void dispose() {
    _client.close();
  }
}


