import 'dart:async';
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
  
  final http.Client _client = http.Client();

  /// Predict multiple ingredients from images
  /// 
  /// Takes a list of image files and returns predictions for each one
  /// Perfect for mobile apps where users capture multiple ingredient photos
  Future<Map<String, dynamic>> predictMultiple(List<File> images) async {
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

      // Send request with timeout
      var streamedResponse = await request.send().timeout(
        Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException('Request took too long. The service might be starting up.');
        },
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else if (response.statusCode == 503) {
        return {
          'success': false,
          'error': 'cold_start',
          'message': 'The AI service is starting up. Please wait 10-20 seconds and try again.',
        };
      } else {
        return {
          'success': false,
          'error': 'server_error',
          'message': 'The AI service encountered an error. Please try again.',
        };
      }
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'error': 'timeout',
        'message': e.message ?? 'Request timed out',
      };
    } on SocketException {
      return {
        'success': false,
        'error': 'network',
        'message': 'No internet connection. Please check your network.',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'unknown',
        'message': 'An unexpected error occurred. Please try again.',
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

  /// Test connection to API with retry logic for cold starts
  /// 
  /// Azure serverless functions may need 10-20 seconds to wake up from cold start
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 30)); // Increased timeout for cold starts
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['model_loaded'] == true,
          'cold_start': false,
        };
      } else if (response.statusCode == 503) {
        // Service unavailable - likely cold starting
        return {
          'success': false,
          'cold_start': true,
          'message': 'The AI service is waking up. This usually takes 10-20 seconds on first use.',
        };
      }
      return {
        'success': false,
        'cold_start': false,
        'message': 'Unable to connect to the AI service.',
      };
    } on TimeoutException {
      return {
        'success': false,
        'cold_start': true,
        'message': 'The AI service is taking longer than expected to wake up. Please try again in a moment.',
      };
    } on SocketException {
      return {
        'success': false,
        'cold_start': false,
        'message': 'No internet connection. Please check your network.',
      };
    } catch (e) {
      print('Connection test failed: $e');
      return {
        'success': false,
        'cold_start': false,
        'message': 'Connection error. Please check your internet and try again.',
      };
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

  void dispose() {
    _client.close();
  }
}

