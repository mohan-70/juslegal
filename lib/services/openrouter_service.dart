import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/constants/ai_constants.dart';
import '../core/exceptions/ai_exceptions.dart';

class OpenRouterService {
  late final Dio _dio;

  OpenRouterService() {
    _dio = Dio(BaseOptions(
      baseUrl: AIConstants.openRouterBaseUrl,
      connectTimeout: const Duration(seconds: AIConstants.timeoutSeconds),
      receiveTimeout: const Duration(seconds: AIConstants.timeoutSeconds),
      headers: {
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://juslegal-2196.web.app',
        'X-Title': 'JusLegal'
      },
    ));
  }

  Future<String> _getApiKey() async {
    await dotenv.load(fileName: ".env");
    final apiKey = dotenv.env['OPENROUTER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_openrouter_api_key_here') {
      throw ApiKeyException('OpenRouter API Key not found or invalid');
    }
    return apiKey;
  }

  Future<Map<String, dynamic>> analyze(String systemPrompt, String problemText, {String category = 'general'}) async {
    try {
      final apiKey = await _getApiKey();
      
      final response = await _dio.post(
        '', // URL is set in BaseOptions
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
        data: {
          'model': AIConstants.openRouterModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': 'Category: $category\n\nProblem: $problemText'},
          ],
          'temperature': AIConstants.temperature,
          'max_tokens': AIConstants.maxTokens,
          'top_p': AIConstants.topP,
          'stream': false,
        },
      );

      return _parseJsonResponse(response, 'openrouter', AIConstants.openRouterModel);
    } catch (e) {
      _handleDioError(e, 'OpenRouter');
    }
  }

  Future<String> generateRaw(String systemPrompt, String prompt) async {
    try {
      final apiKey = await _getApiKey();
      
      final response = await _dio.post(
        '', // URL is set in BaseOptions
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
        data: {
          'model': AIConstants.openRouterModel,
          'messages': [
            if (systemPrompt.isNotEmpty) {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': AIConstants.temperature,
          'max_tokens': AIConstants.maxTokens,
          'top_p': AIConstants.topP,
          'stream': false,
        },
      );

      return _parseRawResponse(response);
    } catch (e) {
      _handleDioError(e, 'OpenRouter');
    }
  }

  Map<String, dynamic> _parseJsonResponse(Response response, String provider, String modelName) {
    if (response.statusCode == 200) {
      final data = response.data;
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw ParseException('No choices returned from $provider API');
      }
      
      final content = choices[0]['message']['content'] as String;
      String cleanContent = content;
      
      if (cleanContent.startsWith('```json')) {
        cleanContent = cleanContent.substring(7);
      }
      if (cleanContent.endsWith('```')) {
        cleanContent = cleanContent.substring(0, cleanContent.length - 3);
      }
      cleanContent = cleanContent.trim();

      try {
        final parsedJson = jsonDecode(cleanContent) as Map<String, dynamic>;
        parsedJson['_model'] = modelName;
        parsedJson['_provider'] = provider;
        return parsedJson;
      } catch (e) {
        throw ParseException('Failed to parse JSON response: $e');
      }
    } else {
      throw NetworkException('HTTP Error: ${response.statusCode}');
    }
  }

  String _parseRawResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data;
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw ParseException('No choices returned from API');
      }
      return (choices[0]['message']['content'] as String).trim();
    } else {
      throw NetworkException('HTTP Error: ${response.statusCode}');
    }
  }

  Never _handleDioError(dynamic e, String provider) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Request timeout');
      } else if (e.response?.statusCode == 429) {
        throw RateLimitException('Rate limit exceeded', provider);
      } else if (e.response?.statusCode == 401) {
        throw ApiKeyException('Invalid $provider API Key');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } else if (e is RateLimitException || e is ApiKeyException || e is ParseException || e is NetworkException) {
      throw e;
    }
    throw ParseException('Unexpected error: $e');
  }
}
