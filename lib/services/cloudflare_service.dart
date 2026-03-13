import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/exceptions/ai_exceptions.dart';

class CloudflareService {
  static const String _workerUrl = 'https://juslegal-proxy.workers.dev';
  static const int _timeoutSeconds = 30;

  final Dio _dio;

  CloudflareService() : _dio = Dio() {
    _dio.options.connectTimeout = Duration(seconds: _timeoutSeconds);
    _dio.options.receiveTimeout = Duration(seconds: _timeoutSeconds);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> callGroq(String prompt, {String category = 'general'}) async {
    try {
      final response = await _dio.post(
        _workerUrl,
        data: {
          'service': 'groq',
          'prompt': prompt,
          'category': category,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Safe type checking and casting
        if (data is! Map<String, dynamic>) {
          throw ParseException('Invalid response format: expected object');
        }
        
        final choices = data['choices'];
        if (choices is! List || choices.isEmpty) {
          throw ParseException('No choices returned from Groq API');
        }
        
        final firstChoice = choices[0];
        if (firstChoice is! Map<String, dynamic>) {
          throw ParseException('Invalid choice format: expected object');
        }
        
        final message = firstChoice['message'];
        if (message is! Map<String, dynamic>) {
          throw ParseException('Invalid message format: expected object');
        }
        
        final content = message['content'];
        if (content is! String || content.isEmpty) {
          throw ParseException('Invalid or missing content in response');
        }
        
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
          // Add model metadata from worker response
          parsedJson['_model'] = data['_model'] as String? ?? 'unknown-groq-model';
          parsedJson['_provider'] = data['_provider'] as String? ?? 'groq';
          return parsedJson;
        } catch (e) {
          throw ParseException('Failed to parse JSON response: $e');
        }
      } else {
        throw NetworkException('HTTP Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Request timeout');
      } else if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 429) {
          throw RateLimitException('Rate limit exceeded', 'Groq');
        } else if (statusCode == 401) {
          throw ApiKeyException('Groq');
        } else {
          throw NetworkException('HTTP Error: $statusCode');
        }
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      if (e is RateLimitException || e is ApiKeyException || e is ParseException || e is NetworkException) {
        rethrow;
      }
      throw ParseException('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> callOpenRouter(String prompt, {String category = 'general'}) async {
    try {
      final response = await _dio.post(
        _workerUrl,
        data: {
          'service': 'openrouter',
          'prompt': prompt,
          'category': category,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Safe type checking and casting
        if (data is! Map<String, dynamic>) {
          throw ParseException('Invalid response format: expected object');
        }
        
        final choices = data['choices'];
        if (choices is! List || choices.isEmpty) {
          throw ParseException('No choices returned from OpenRouter API');
        }
        
        final firstChoice = choices[0];
        if (firstChoice is! Map<String, dynamic>) {
          throw ParseException('Invalid choice format: expected object');
        }
        
        final message = firstChoice['message'];
        if (message is! Map<String, dynamic>) {
          throw ParseException('Invalid message format: expected object');
        }
        
        final content = message['content'];
        if (content is! String || content.isEmpty) {
          throw ParseException('Invalid or missing content in response');
        }
        
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
          // Add model metadata from worker response
          parsedJson['_model'] = data['_model'] as String? ?? 'unknown-openrouter-model';
          parsedJson['_provider'] = data['_provider'] as String? ?? 'openrouter';
          return parsedJson;
        } catch (e) {
          throw ParseException('Failed to parse JSON response: $e');
        }
      } else {
        throw NetworkException('HTTP Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Request timeout');
      } else if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 429) {
          throw RateLimitException('Rate limit exceeded', 'OpenRouter');
        } else if (statusCode == 401) {
          throw ApiKeyException('OpenRouter');
        } else {
          throw NetworkException('HTTP Error: $statusCode');
        }
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      if (e is RateLimitException || e is ApiKeyException || e is ParseException || e is NetworkException) {
        rethrow;
      }
      throw ParseException('Unexpected error: $e');
    }
  }
}
