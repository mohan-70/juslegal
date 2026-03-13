import 'dart:convert';
import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import '../core/constants/ai_constants.dart';
import '../core/exceptions/ai_exceptions.dart';

class OpenRouterService {
  static const String modelName = AIConstants.openRouterModel;
  late final FirebaseFunctions _functions;

  OpenRouterService() {
    _functions = FirebaseFunctions.instance;
  }

  Future<Map<String, dynamic>> analyze(String systemPrompt, String userMessage, {String category = 'general'}) async {
    try {
      final callable = _functions.httpsCallable('callOpenRouter');
      final result = await callable.call({
        'prompt': userMessage,
        'category': category,
      });

      if (result.data == null) {
        throw ParseException('No response from server');
      }

      final responseData = result.data as Map<String, dynamic>;
      
      if (responseData['success'] != true) {
        throw NetworkException('Server error: ${responseData['error'] ?? 'Unknown error'}');
      }

      final data = responseData['data'] as Map<String, dynamic>;
      
      if (data['choices'] == null || (data['choices'] as List).isEmpty) {
        throw ParseException('No choices returned from OpenRouter API');
      }

      final choice = (data['choices'] as List)[0] as Map<String, dynamic>;
      final message = choice['message'] as Map<String, dynamic>;
      final content = message['content'] as String;
      
      // Handle content
      String cleanContent = content;
      
      // Strip markdown fences if present
      if (cleanContent.startsWith('```json')) {
        cleanContent = cleanContent.substring(7);
      }
      if (cleanContent.endsWith('```')) {
        cleanContent = cleanContent.substring(0, cleanContent.length - 3);
      }
      cleanContent = cleanContent.trim();

      try {
        final parsedJson = jsonDecode(cleanContent) as Map<String, dynamic>;
        // Add model metadata
        parsedJson['_model'] = modelName;
        parsedJson['_provider'] = 'openrouter';
        return parsedJson;
      } catch (e) {
        throw ParseException('Failed to parse JSON response: $e');
      }
      
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'resource-exhausted') {
        throw RateLimitException('Rate limit exceeded', 'OpenRouter');
      } else if (e.code == 'permission-denied') {
        throw ApiKeyException('OpenRouter');
      } else if (e.code == 'unavailable') {
        throw NetworkException('Service unavailable');
      } else {
        throw NetworkException('Firebase Functions error: ${e.message}');
      }
    } catch (e) {
      if (e is RateLimitException || e is ApiKeyException || e is ParseException || e is NetworkException) {
        rethrow;
      }
      throw ParseException('Unexpected error: $e');
    }
  }
}
