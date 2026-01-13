import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ml_app/config/api_config.dart';

void main() async {
  print('Testing Gemini 3.5 Pro Configuration...\n');
  
  // Test configuration
  print('Current Configuration:');
  print('   Model: ${ApiConfig.geminiModel}');
  print('   Endpoint: ${ApiConfig.geminiBaseUrl}');
  print('   API Key: ${ApiConfig.geminiApiKey.substring(0, 10)}...${ApiConfig.geminiApiKey.substring(ApiConfig.geminiApiKey.length - 5)}');
  print('   Max Tokens: ${ApiConfig.maxTokens}');
  print('   Temperature: ${ApiConfig.temperature}\n');
  
  // Simple test prompt
  final testPrompt = 'Generate 1 simple Nigerian recipe using tomato and onion. Return as JSON with fields: title, description, ingredients (array), instructions (array). Keep it brief.';
  
  try {
    print('Sending test request to Gemini...');
    
    final response = await http.post(
      Uri.parse(ApiConfig.geminiBaseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': ApiConfig.geminiApiKey,
      },
      body: jsonEncode({
        'contents': [{
          'parts': [{'text': testPrompt}]
        }],
        'generationConfig': {
          'temperature': ApiConfig.temperature,
          'maxOutputTokens': ApiConfig.maxTokens,
        }
      }),
    ).timeout(Duration(seconds: 30));
    
    print('Response Status: ${response.statusCode}\n');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Check response structure
      if (data['candidates'] != null && (data['candidates'] as List).isNotEmpty) {
        final candidate = data['candidates'][0];
        final text = candidate['content']['parts'][0]['text'] as String;
        
        print('SUCCESS! Gemini 2.5 Pro is responding correctly\n');
        print('Response Preview (first 500 chars):');
        print('─' * 60);
        print(text.substring(0, text.length > 500 ? 500 : text.length));
        if (text.length > 500) print('...(truncated)');
        print('─' * 60);
        print('\nToken Usage:');
        if (data['usageMetadata'] != null) {
          final usage = data['usageMetadata'];
          print('   Prompt tokens: ${usage["promptTokenCount"]}');
          print('   Response tokens: ${usage["candidatesTokenCount"]}');
          print('   Total tokens: ${usage["totalTokenCount"]}');
        }
        
        print('\nConfiguration is CORRECT and working!');
      } else {
        print('ERROR: FAILED - Empty response from Gemini');
        print('Full response: ${response.body}');
      }
    } else if (response.statusCode == 400) {
      print('ERROR: FAILED - Bad Request (400)');
      print('Response: ${response.body}');
      print('\nPossible issues:');
      print('   - Check if geminiBaseUrl is correct for gemini-2.5-pro');
      print('   - Verify maxTokens is not too high');
    } else if (response.statusCode == 403) {
      print('ERROR: FAILED - Permission Denied (403)');
      print('Response: ${response.body}');
      print('\nPossible issues:');
      print('   - API key is invalid or expired');
      print('   - API key does not have access to gemini-2.5-pro');
    } else if (response.statusCode == 429) {
      print('ERROR: FAILED - Rate Limit Exceeded (429)');
      print('Response: ${response.body}');
      print('\nYou\'ve hit the rate limit. Wait a moment and try again.');
    } else {
      print('ERROR: FAILED - HTTP ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('ERROR: $e');
    print('\nPossible issues:');
    print('   - Network connection problem');
    print('   - API endpoint URL is incorrect');
    print('   - Request timeout (>30s)');
  }
}
