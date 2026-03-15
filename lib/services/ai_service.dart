import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/exceptions/ai_exceptions.dart';
import 'gemini_service.dart';
import 'cloudflare_service.dart';
import 'lkb_service.dart';
import 'mock_ai_service.dart';

class AIService {
  late final GeminiService _geminiService;
  late final CloudflareService _cloudflareService;
  late final LKBService _lkbService;
  late final MockAIService _mockService;
  bool _useMockService = false;

  AIService() {
    _geminiService = GeminiService();
    _cloudflareService = CloudflareService();
    _lkbService = LKBService();
    _mockService = MockAIService();
  }

  Future<void> initialize() async {
    try {
      await _lkbService.load();
      await _geminiService.initialize();
    } catch (e) {
      // Continue even if Gemini fails to initialize
      if (kDebugMode) print('[AIService] Some services failed to initialize: $e');
    }
  }

  Future<Map<String, dynamic>> analyzeProblem(
      String problemText, String category) async {
    // If all real services failed, use mock service
    if (_useMockService) {
      if (kDebugMode) print('[AIService] Using mock service for analysis');
      return await _mockService.analyzeProblem(problemText, category);
    }

    // 1. Try Gemini first (direct, domain-restricted key)
    try {
      if (kDebugMode) print('Attempting analysis with Gemini 2.0 Flash');
      final result = await _geminiService.analyze(problemText, category);
      if (kDebugMode) print('✅ Gemini analysis successful');
      return result;
    } catch (e) {
      if (kDebugMode) print('[AIService] Gemini failed, trying fallback: $e');
    }

    // 2. Load legal context once for fallback services
    String legalContext;
    try {
      legalContext = await _lkbService.getContext(problemText, category);
    } catch (e) {
      if (kDebugMode) print('[AIService] Failed to load legal context: $e');
      legalContext = 'Consumer protection laws and regulations applicable to the case.';
    }

    // Build system prompt for fallback services
    final String systemPrompt = _buildSystemPrompt(legalContext);
    final String userMessage = _buildUserMessage(category, problemText);
    final String fullPrompt = '$systemPrompt\n\n$userMessage';

    // 3. Fallback to Cloudflare Worker (Groq)
    try {
      if (kDebugMode)
        print('Attempting analysis with Groq via Cloudflare Worker');
      final result = await _tryWithRetry(
        () => _cloudflareService.callGroq(fullPrompt, category: category),
        'Groq',
      );
      if (kDebugMode) print('✅ Groq fallback successful');
      return result;
    } catch (e) {
      if (kDebugMode) print('[AIService] Groq fallback failed, trying OpenRouter: $e');
    }

    // 4. Try OpenRouter as second fallback
    try {
      if (kDebugMode)
        print('Attempting analysis with OpenRouter via Cloudflare Worker');
      final result = await _tryWithRetry(
        () => _cloudflareService.callOpenRouter(fullPrompt, category: category),
        'OpenRouter',
      );
      if (kDebugMode) print('✅ OpenRouter fallback successful');
      return result;
    } catch (e) {
      if (kDebugMode) print('[AIService] All fallbacks failed: $e');
    }

    // 5. All real services failed - switch to mock service for development
    if (kDebugMode) print('[AIService] All real services failed, switching to mock service');
    _useMockService = true;
    return await _mockService.analyzeProblem(problemText, category);
  }

  // Backward compatibility method
  Future<Map<String, dynamic>> analyze(
      {required String problemText, required String selectedCategory}) async {
    return await analyzeProblem(problemText, selectedCategory);
  }

  Future<Map<String, dynamic>> _tryWithRetry(
    Future<Map<String, dynamic>> Function() operation,
    String providerName,
  ) async {
    String? lastError;

    for (int attempt = 0; attempt < ApiConstants.maxRetries; attempt++) {
      try {
        return await operation();
      } on RateLimitException {
        // Don't retry on rate limit, fail immediately
        rethrow;
      } catch (e) {
        lastError = e.toString();
        if (attempt < ApiConstants.maxRetries - 1) {
          // Wait before retrying
          await Future.delayed(
              const Duration(milliseconds: ApiConstants.retryDelayMs));
        }
      }
    }

    throw Exception(
        'All retries failed for $providerName. Last error: $lastError');
  }

  String _buildSystemPrompt(String legalContext) {
    return '''You are JusLegal, an AI-powered legal assistant specializing in Indian consumer protection laws. You help Indian citizens understand their legal rights and take action against consumer issues including e-commerce disputes, banking fraud, travel problems, and more. Always:
- Cite specific Indian laws (Consumer Protection Act 2019, IT Act 2000, RBI guidelines, etc.)
- Give clear numbered action steps
- Mention relevant authorities (NCLT, RBI, TRAI, etc.)
- Keep language simple and jargon-free
- Add a brief disclaimer that this is AI guidance, not legal advice

LEGAL CONTEXT:
$legalContext

CRITICAL RULES:
1. Answer based on the provided legal context and your knowledge of Indian consumer law
2. Always include exact law names and section numbers when applicable
3. Provide responses in valid JSON format only
4. Be concise, factual, and actionable
5. Include confidence score based on available information

REQUIRED JSON RESPONSE FORMAT:
{
  "category": "problem category",
  "applicable_law": "specific Indian law and section",
  "law_summary": "one sentence summary of the law",
  "user_rights": "user's legal rights in plain language",
  "steps": ["step 1", "step 2", "step 3", "step 4"],
  "authorities": ["authority 1", "authority 2", "authority 3"],
  "documents_required": ["document 1", "document 2", "document 3"],
  "physical_visit_required": true/false,
  "physical_visit_instructions": "instructions or null",
  "confidence": integer 0-100,
  "isVerified": true/false,
  "complaint_hint": "one line hint for effective complaint"
}''';
  }

  String _buildUserMessage(String category, String problemText) {
    return '''Analyze this legal problem:

Category: $category
Problem: $problemText

Provide a JSON response with the exact fields specified in the system prompt. Focus on practical, actionable advice for Indian consumers.''';
  }
}
