import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Quick test to verify Azure API connection
/// Run this with: flutter test test/azure_connection_test.dart
void main() {
  const String azureUrl = 'https://food-ingredients-recogition-api.azurewebsites.net';

  group('Azure API Connection Tests', () {
    test('Health endpoint returns model loaded', () async {
      final response = await http.get(
        Uri.parse('$azureUrl/health'),
        headers: {'Accept': 'application/json'},
      );

      expect(response.statusCode, 200);
      
      final data = jsonDecode(response.body);
      expect(data['model_loaded'], true);
      expect(data['status'], 'healthy');
      
      print('✅ Health check passed!');
      print('   Model loaded: ${data['model_loaded']}');
      print('   Status: ${data['status']}');
    });

    test('Ingredients endpoint returns 15 ingredients', () async {
      final response = await http.get(
        Uri.parse('$azureUrl/ingredients'),
        headers: {'Accept': 'application/json'},
      );

      expect(response.statusCode, 200);
      
      final data = jsonDecode(response.body);
      expect(data['success'], true);
      expect(data['ingredients'], isList);
      expect(data['count'], 15);
      
      print('✅ Ingredients endpoint passed!');
      print('   Found ${data['count']} ingredients:');
      for (var ingredient in data['ingredients']) {
        print('   - $ingredient');
      }
    });

    test('Root endpoint returns welcome message', () async {
      final response = await http.get(
        Uri.parse('$azureUrl/'),
        headers: {'Accept': 'application/json'},
      );

      expect(response.statusCode, 200);
      
      print('✅ Root endpoint passed!');
      print('   API is accessible and responding');
    });
  });
}
