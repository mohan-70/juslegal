import 'package:google_generative_ai/google_generative_ai.dart'; 
import 'package:flutter/foundation.dart'; 
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

const String _systemPrompt = """
You are JusLegal, an AI legal assistant specialized in Indian consumer law.
You help Indian citizens understand their rights under:
- Consumer Protection Act 2019
- RERA Act
- RBI Banking Ombudsman guidelines
- IT Act 2000
- Food Safety and Standards Act 2006
- Motor Vehicles Act 1988
- Insurance Regulatory and Development Authority (IRDA) guidelines

For every query, always respond with these exact sections:
1. APPLICABLE LAW — Specific act name and section numbers that apply
2. YOUR RIGHTS — What the user is legally entitled to in this situation
3. ACTION PLAN — Numbered step-by-step actions to take (be specific)
4. AUTHORITY TO CONTACT — Exact body to approach (NCDRC, RBI Ombudsman, SEBI, RERA etc.) with how to contact them
5. TIMELINE — Realistic timeframe for resolution
6. SUCCESS PROBABILITY — Honest assessment (High/Medium/Low) with reason
7. DO YOU NEED A LAWYER — Yes/No with reason

Keep language simple, practical, and in plain English.
Always end with: ⚠️ This is AI-generated guidance only and does not constitute legal advice. Consult a qualified advocate for legal proceedings.
"""; 

class GeminiService { 
  String? _apiKey;
  GenerativeModel? _model;

  Future<void> initialize() async {
    // Try to get API key from environment variable or platform-specific secure storage
    try {
      // Load .env file
      await dotenv.load(fileName: ".env");
      
      // For web, we'll use a proxy approach - don't expose API key directly
      if (kIsWeb) {
        throw Exception('Gemini API should be called through proxy on web platform');
      }
      
      // For mobile builds, get from .env file or environment
      _apiKey = dotenv.env['GEMINI_API_KEY'] ?? const String.fromEnvironment('GEMINI_API_KEY');
      
      if (_apiKey == null || _apiKey!.isEmpty) {
        throw Exception('Gemini API key not configured. Please add GEMINI_API_KEY to your .env file');
      }
      
      _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey!,
        systemInstruction: Content.system(_systemPrompt),
        generationConfig: GenerationConfig(
          temperature: 0.3,
          maxOutputTokens: 1024,
        ),
      );
    } catch (e) {
      if (kDebugMode) print('[GeminiService] Initialization failed: $e');
      // Don't rethrow for web platform - allow fallback to other services
      if (!kIsWeb) {
        rethrow;
      }
    }
  } 
 
  Future<Map<String, dynamic>> analyze(String problem, String category) async { 
    try { 
      if (kDebugMode) print('[GeminiService] Starting analysis for: ${problem.substring(0, 50)}...');
      
      // For web platform, try to use API key from .env if available
      if (kIsWeb && _model == null) {
        try {
          if (kDebugMode) print('[GeminiService] Loading .env file for web...');
          await dotenv.load(fileName: ".env");
          _apiKey = dotenv.env['GEMINI_API_KEY'];
          
          if (kDebugMode) print('[GeminiService] API key found: ${_apiKey != null ? "YES" : "NO"}');
          if (kDebugMode) print('[GeminiService] API key length: ${_apiKey?.length ?? 0}');
          
          if (_apiKey != null && _apiKey!.isNotEmpty) {
            // Initialize model for web if API key is available
            _model = GenerativeModel(
              model: 'gemini-2.0-flash',
              apiKey: _apiKey!,
              systemInstruction: Content.system(_systemPrompt),
              generationConfig: GenerationConfig(
                temperature: 0.3,
                maxOutputTokens: 1024,
              ),
            );
            if (kDebugMode) print('[GeminiService] Web model initialized successfully');
          } else {
            if (kDebugMode) print('[GeminiService] No API key found in .env file');
          }
        } catch (e) {
          if (kDebugMode) print('[GeminiService] Web initialization failed: $e');
        }
      }
      
      if (_model == null) {
        throw Exception('Gemini service not initialized - no model available');
      }
      
      if (kDebugMode) print('[GeminiService] Generating content with Gemini...');
      final prompt = 'Category: $category\n\nUser Problem: $problem\n\nProvide a JSON response with these exact fields: category, applicable_law, law_summary, user_rights, steps (array), authorities (array), documents_required (array), physical_visit_required (boolean), physical_visit_instructions (string or null), confidence (0-100), isVerified (boolean), complaint_hint (string).'; 
      final response = await _model!.generateContent([Content.text(prompt)]); 
      final text = response.text; 
      
      if (text == null || text.trim().isEmpty) { 
        throw Exception('Empty response from Gemini'); 
      }
      
      if (kDebugMode) print('[GeminiService] Got response from Gemini, parsing...');
      // Parse the response to match expected format
      return _parseGeminiResponse(text, category);
    } catch (e) { 
      if (kDebugMode) print('[GeminiService] Error: $e'); 
      rethrow; 
    } 
  }
  
  Map<String, dynamic> _parseGeminiResponse(String response, String category) {
    try {
      // Try to extract JSON from the response
      String cleanResponse = response.trim();
      
      // Remove markdown code blocks if present
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.startsWith('```')) {
        cleanResponse = cleanResponse.substring(3);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }
      cleanResponse = cleanResponse.trim();
      
      // Try to parse as JSON first
      try {
        final Map<String, dynamic> jsonData = jsonDecode(cleanResponse) as Map<String, dynamic>;
        return jsonData;
      } catch (e) {
        // If JSON parsing fails, create a structured response from the text
        return _createStructuredResponse(response, category);
      }
    } catch (e) {
      if (kDebugMode) print('[GeminiService] Response parsing failed: $e');
      // Fallback to basic structured response
      return _createStructuredResponse(response, category);
    }
  }
  
  Map<String, dynamic> _createStructuredResponse(String response, String category) {
    // Extract key information from the text response
    final lines = response.split('\n');
    String applicableLaw = '';
    String userRights = '';
    List<String> steps = [];
    List<String> authorities = [];
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.contains('APPLICABLE LAW') || trimmedLine.contains('Law:')) {
        applicableLaw = trimmedLine.split(':').length > 1 ? trimmedLine.split(':').skip(1).join(':').trim() : trimmedLine;
      } else if (trimmedLine.contains('YOUR RIGHTS') || trimmedLine.contains('Rights:')) {
        userRights = trimmedLine.split(':').length > 1 ? trimmedLine.split(':').skip(1).join(':').trim() : trimmedLine;
      } else if (trimmedLine.contains(RegExp(r'^\d+\.'))) {
        steps.add(trimmedLine);
      } else if (trimmedLine.contains('AUTHORITY') || trimmedLine.contains('CONTACT')) {
        authorities.add(trimmedLine);
      }
    }
    
    return {
      'category': category,
      'applicable_law': applicableLaw.isNotEmpty ? applicableLaw : 'Consumer Protection Act 2019',
      'law_summary': 'Protects consumer rights and provides remedies for grievances',
      'user_rights': userRights.isNotEmpty ? userRights : 'Right to seek redressal for consumer grievances',
      'steps': steps.isNotEmpty ? steps : ['File complaint with consumer forum', 'Gather evidence', 'Seek legal advice if needed'],
      'authorities': authorities.isNotEmpty ? authorities : ['National Consumer Helpline: 1800-11-4000'],
      'documents_required': ['Purchase receipts', 'Communication records', 'Evidence of defect/service failure'],
      'physical_visit_required': false,
      'physical_visit_instructions': null,
      'confidence': 75,
      'isVerified': false,
      'complaint_hint': 'Be specific about dates, amounts, and communication attempts',
      '_model': 'gemini-2.0-flash',
      '_provider': 'google',
    };
  } 
} 
