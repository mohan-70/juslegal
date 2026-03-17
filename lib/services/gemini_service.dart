import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart'; 
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

For every query, analyze the user's problem and provide a JSON response with these exact fields:
- category: The problem category
- applicable_law: Specific act name and section numbers that apply
- law_summary: Brief summary of the applicable law
- user_rights: What the user is legally entitled to
- steps: Array of numbered step-by-step actions to take
- authorities: Array of objects with authority name and contact details
- documents_required: Array of required documents
- physical_visit_required: Boolean indicating if physical visit is needed
- physical_visit_instructions: Instructions for physical visit (null if not required)
- confidence: Confidence score 0-100
- isVerified: Boolean indicating if information is verified
- complaint_hint: Brief hint for filing complaint
- order_number: Order/transaction number if mentioned (null if not)
- product_details: Description of product/service purchased (null if not)
- amount_paid: Amount paid with currency (e.g., "₹5000", "\$100")
- payment_method: Payment method used (e.g., "UPI", "credit card", "cash", "net banking")
- company_name: Name of company/platform involved (e.g., "Amazon", "Flipkart", "Meesho")
- incident_date: Date when incident occurred (e.g., "15 Jan 2024", "yesterday")
- location: Location of incident (e.g., "Mumbai", "online")

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

      // For web & mobile, get from .env file or environment
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
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> analyze(String problem, String category) async {
    try {
      if (kDebugMode) print('[GeminiService] Starting analysis for: ${problem.substring(0, 50)}...');
      
      if (_apiKey == null || _model == null) {
        await initialize();
      }
      
      if (_model == null) {
        throw Exception('Gemini service not initialized - no model available');
      }
      
      if (kDebugMode) print('[GeminiService] Generating content with Gemini...');
      final prompt = 'Category: $category\n\nUser Problem: $problem';
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

  Future<String> generateRaw(String prompt) async {
    try {
      if (_apiKey == null || _model == null) {
        await initialize();
      }

      if (_model == null) {
        throw Exception('Gemini service not initialized');
      }

      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null || text.trim().isEmpty) {
        throw Exception('Empty response from Gemini');
      }
      return text.trim();
    } catch (e) {
      if (kDebugMode) print('[GeminiService] Error generating raw text: $e');
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
      'order_number': null,
      'product_details': null,
      'amount_paid': null,
      'payment_method': null,
      'company_name': null,
      'incident_date': null,
      'location': null,
      '_model': 'gemini-2.0-flash',
      '_provider': 'google',
    };
  } 
}

