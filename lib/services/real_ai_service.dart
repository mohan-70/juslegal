import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/legal_result_model.dart';

class RealAIService {
  final Dio _dio;
  final String _apiKey;
  
  RealAIService() : _dio = Dio(), _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '' {
    _dio.options.baseUrl = 'https://api.openai.com/v1';
    _dio.options.headers['Authorization'] = 'Bearer $_apiKey';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<LegalResultModel> analyzeWithAI({
    required String problemText,
    required String selectedCategory,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }

    final prompt = _buildLegalPrompt(problemText, selectedCategory);
    
    try {
      final response = await _dio.post('/chat/completions', data: {
        'model': 'gpt-4-turbo-preview',
        'messages': [
          {
            'role': 'system',
            'content': 'You are an expert Indian legal analyst specializing in consumer rights and grievance redressal. Provide accurate, actionable legal advice based on Indian laws and regulations.'
          },
          {
            'role': 'user',
            'content': prompt
          }
        ],
        'temperature': 0.3,
        'max_tokens': 2000,
      });

      final content = response.data['choices'][0]['message']['content'];
      return _parseAIResponse(content, selectedCategory);
      
    } catch (e) {
      throw Exception('AI analysis failed: $e');
    }
  }

  String _buildLegalPrompt(String problemText, String category) {
    return '''
Analyze the following consumer problem and provide structured legal guidance:

CATEGORY: $category
PROBLEM: $problemText

Please provide a detailed analysis in the following JSON format:

{
  "category": "$category",
  "applicable_law": "Specific Indian law or regulation applicable",
  "law_summary": "Brief summary of the law in simple terms",
  "user_rights": "Detailed explanation of consumer rights in this situation",
  "steps": [
    "Step 1: What to do first",
    "Step 2: Next action",
    "Step 3: Follow-up action",
    "Step 4: Escalation if needed"
  ],
  "authorities": [
    {"name": "Authority Name", "contact": "Contact details", "action": "How to approach"}
  ],
  "documents_required": [
    "Document 1",
    "Document 2",
    "Document 3"
  ],
  "physical_visit_required": true/false,
  "physical_visit_instructions": "If visit required, detailed instructions",
  "confidence": 85,
  "isVerified": true
}

Important:
- Focus on Indian consumer laws and regulations
- Provide practical, actionable steps
- Include relevant authorities with contact information
- Consider both online and offline resolution options
- Be specific about document requirements
- Set confidence based on clarity of applicable law
- Only mark as verified if clearly established legal principle
''';
  }

  LegalResultModel _parseAIResponse(String aiResponse, String category) {
    try {
      // Extract JSON from AI response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(aiResponse);
      if (jsonMatch == null) {
        throw Exception('Could not parse AI response');
      }

      final jsonStr = jsonMatch.group(0)!;
      final jsonData = json.decode(jsonStr) as Map<String, dynamic>;

      // Ensure all required fields are present
      return LegalResultModel(
        category: jsonData['category'] ?? category,
        applicableLaw: jsonData['applicable_law'] ?? 'Consumer Protection Act 2019',
        lawSummary: jsonData['law_summary'] ?? 'Consumer protection laws apply to this case.',
        userRights: jsonData['user_rights'] ?? 'You have the right to fair treatment and redressal.',
        steps: List<String>.from(jsonData['steps'] ?? [
          'Document the issue thoroughly',
          'Contact the service provider',
          'Escalate to higher authorities',
          'Seek legal advice if unresolved'
        ]),
        authorities: List<Map<String, String>>.from(
          (jsonData['authorities'] ?? [
            {'name': 'National Consumer Helpline', 'contact': '1800-11-4000', 'action': 'File Online'}
          ]).map((e) => Map<String, String>.from(e)),
        ),
        documentsRequired: List<String>.from(jsonData['documents_required'] ?? [
          'Complaint copy',
          'Supporting documents',
          'Communication records'
        ]),
        physicalVisitRequired: jsonData['physical_visit_required'] ?? false,
        physicalVisitInstructions: jsonData['physical_visit_instructions'],
        confidence: (jsonData['confidence'] as num?)?.toInt() ?? 75,
        isVerified: jsonData['isVerified'] ?? false,
        complaintHint: _generateComplaintHint(category),
      );
    } catch (e) {
      // Fallback to basic response if parsing fails
      return _createFallbackResponse(category);
    }
  }

  LegalResultModel _createFallbackResponse(String category) {
    return LegalResultModel(
      category: category,
      applicableLaw: 'Consumer Protection Act 2019',
      lawSummary: 'Consumers have the right to fair treatment and redressal for grievances.',
      userRights: 'Right to be heard, right to seek redressal, right to consumer education.',
      steps: [
        'Document the issue thoroughly',
        'Contact the service provider',
        'Escalate to higher authorities if needed',
        'Seek legal advice if unresolved'
      ],
      authorities: [
        {'name': 'National Consumer Helpline', 'contact': '1800-11-4000', 'action': 'Call Now'},
        {'name': 'District Consumer Commission', 'contact': 'Find nearest', 'action': 'Visit Website'}
      ],
      documentsRequired: ['Complaint copy', 'Supporting documents', 'Communication records'],
      physicalVisitRequired: false,
      confidence: 60,
      isVerified: false,
      complaintHint: _generateComplaintHint(category),
    );
  }

  String _generateComplaintHint(String category) {
    if (category.contains('E-commerce')) return 'Generate formal email to company support';
    if (category.contains('Banking')) return 'Draft letter for RBI Ombudsman';
    if (category.contains('Traffic')) return 'Prepare contest for Virtual Court';
    if (category.contains('Flight')) return 'Prepare DGCA complaint';
    if (category.contains('Restaurant')) return 'Draft FSSAI complaint';
    return 'Draft consumer grievance letter';
  }
}
