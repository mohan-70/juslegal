import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/exceptions/ai_exceptions.dart';
import 'groq_service.dart';
import 'openrouter_service.dart';
import 'lkb_service.dart';

class AIService {
  late final GroqService _groqService;
  late final OpenRouterService _openRouterService;
  late final LKBService _lkbService;

  AIService() {
    _groqService = GroqService();
    _openRouterService = OpenRouterService();
    _lkbService = LKBService();
  }

  Future<void> initialize() async {
    await _lkbService.load();
  }

  Future<Map<String, dynamic>> analyzeProblem(String problemText, String category) async {
    // Get legal context from LKB
    final String legalContext = await _lkbService.getContext(problemText, category);

    // Build system prompt
    final String systemPrompt = _buildSystemPrompt(legalContext);

    // Build user message
    final String userMessage = _buildUserMessage(category, problemText);

    // Try Groq first with retry logic
    try {
      if (kDebugMode) print('Attempting analysis with Groq (${GroqService.modelName})');
      final result = await _tryWithRetry(
        () => _groqService.analyze(systemPrompt, userMessage),
        'Groq',
      );
      if (kDebugMode) print('✅ Groq analysis successful');
      return result;
    } on RateLimitException {
      if (kDebugMode) print('⚠️ Groq rate limit exceeded, falling back to OpenRouter');
      // Silently fallback to OpenRouter on rate limit
    } catch (e) {
      if (kDebugMode) print('⚠️ Groq failed: $e, falling back to OpenRouter');
      // For other errors, continue to fallback
    }

    // Try OpenRouter as fallback with retry logic
    try {
      if (kDebugMode) print('Attempting analysis with OpenRouter (${OpenRouterService.modelName})');
      final result = await _tryWithRetry(
        () => _openRouterService.analyze(systemPrompt, userMessage),
        'OpenRouter',
      );
      if (kDebugMode) print('✅ OpenRouter analysis successful');
      return result;
    } on RateLimitException {
      if (kDebugMode) print('⚠️ OpenRouter rate limit exceeded, falling back to LKB');
      // Both providers hit rate limits
    } catch (e) {
      if (kDebugMode) print('⚠️ OpenRouter failed: $e, falling back to LKB');
      // Both providers failed, fallback to LKB
    }

    // Fallback to LKB-based analysis when APIs fail
    if (kDebugMode) print('📚 Using LKB fallback analysis');
    final lkbResult = await _lkbService.getAnalysis(problemText, category);
    lkbResult['_model'] = 'Legal Knowledge Base';
    lkbResult['_provider'] = 'lkb';
    return lkbResult;
  }

  // Backward compatibility method
  Future<Map<String, dynamic>> analyze({required String problemText, required String selectedCategory}) async {
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
          await Future.delayed(const Duration(milliseconds: ApiConstants.retryDelayMs));
        }
      }
    }

    throw Exception('All retries failed for $providerName. Last error: $lastError');
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
