import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/ai_constants.dart';
import '../core/exceptions/ai_exceptions.dart';

class OpenRouterService {
  static const String modelName = AIConstants.openRouterModel;
  late final Dio _dio;

  OpenRouterService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.openrouterBaseUrl,
      connectTimeout: const Duration(seconds: AIConstants.timeoutSeconds),
      receiveTimeout: const Duration(seconds: AIConstants.timeoutSeconds),
      headers: {
        ApiConstants.contentTypeHeader: 'application/json',
        ApiConstants.httpRefererHeader: ApiConstants.appUrl,
        ApiConstants.xTitleHeader: ApiConstants.appName,
      },
    ));

    // Add logger for debugging
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      compact: true,
    ));
  }

  Future<Map<String, dynamic>> analyze(String systemPrompt, String userMessage) async {
    // Validate API key
    if (ApiConstants.openrouterApiKey.isEmpty) {
      throw ApiKeyException('OpenRouter');
    }

    try {
      final response = await _dio.post(
        ApiConstants.chatCompletionsEndpoint,
        options: Options(
          headers: {
            ApiConstants.authorizationHeader: 'Bearer ${ApiConstants.openrouterApiKey}',
            ApiConstants.httpRefererHeader: ApiConstants.appUrl,
            ApiConstants.xTitleHeader: ApiConstants.appName,
          },
        ),
        data: {
          'model': modelName,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'temperature': AIConstants.temperature,
          'max_tokens': AIConstants.maxTokens,
          'top_p': AIConstants.topP,
          'response_format': {'type': 'json_object'},
          'stream': false, // Disabled for better reliability
        },
      );

      // Handle response
      if (response.data is Map && response.data['choices'] != null) {
        final choices = response.data['choices'] as List;
        if (choices.isNotEmpty) {
          final choice = choices[0];
          if (choice['message'] != null) {
            final message = choice['message'];
            final content = message['content'];
            
            // Handle content
            String cleanContent = content.toString();
            
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
          }
        }
      }
      
      throw ParseException('No choices returned from OpenRouter API');
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw RateLimitException('Rate limit exceeded', 'OpenRouter');
      } else if (e.response?.statusCode == 401) {
        throw ApiKeyException('OpenRouter');
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.connectionError) {
        throw NetworkException('Network timeout or connection error');
      } else {
        throw NetworkException('Dio error: ${e.message}');
      }
    } catch (e) {
      if (e is RateLimitException || e is ApiKeyException || e is ParseException || e is NetworkException) {
        rethrow;
      }
      throw ParseException('Unexpected error: $e');
    }
  }
}
