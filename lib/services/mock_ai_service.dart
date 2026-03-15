import 'package:flutter/foundation.dart';

class MockAIService {
  Future<void> initialize() async {
    if (kDebugMode) print('[MockAIService] Initialized');
  }

  Future<Map<String, dynamic>> analyzeProblem(String problemText, String category) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (kDebugMode) print('[MockAIService] Analyzing: $category - $problemText');

    // Return mock response based on category
    return _getMockResponse(category, problemText);
  }

  Map<String, dynamic> _getMockResponse(String category, String problemText) {
    final baseResponse = {
      'category': category,
      'applicable_law': 'Consumer Protection Act 2019, Section 2(9)',
      'law_summary': 'Protects consumer rights against defective goods and deficient services',
      'user_rights': 'Right to seek refund, replacement, or compensation for defective products/services',
      'steps': [
        'Send written complaint to service provider',
        'Wait for 15 days for response',
        'File complaint on National Consumer Helpline',
        'Approach Consumer Commission if unresolved'
      ],
      'authorities': [
        'National Consumer Helpline: 1800-11-4000',
        'Consumer Commission: File online at consumerhelpline.gov.in'
      ],
      'documents_required': [
        'Purchase receipt or invoice',
        'Communication records with seller',
        'Photos/videos of defect (if applicable)',
        'Warranty card (if applicable)'
      ],
      'physical_visit_required': false,
      'physical_visit_instructions': null,
      'confidence': 85,
      'isVerified': true,
      'complaint_hint': 'Be specific about dates, amounts, and previous communication attempts',
      'order_number': 'ORD123456',
      'product_details': 'Sample Product',
      'amount_paid': '₹5000',
      'payment_method': 'UPI',
      'company_name': 'Sample Company',
      'incident_date': '15 Jan 2024',
      'location': 'Online',
      '_model': 'mock-service',
      '_provider': 'mock'
    };

    // Customize response based on category
    switch (category.toLowerCase()) {
      case 'ecommerce & shopping':
        return {
          ...baseResponse,
          'applicable_law': 'Consumer Protection Act 2019, Section 18 and E-commerce Rules 2020',
          'law_summary': 'Protects buyers in online transactions including refund rights and delivery timelines',
          'user_rights': 'Right to timely delivery, accurate product description, and easy returns/refunds',
          'authorities': [
            'National Consumer Helpline: 1800-11-4000',
            'E-commerce Portal: consumerhelpline.gov.in'
          ]
        };
      
      case 'banking & upi fraud':
        return {
          ...baseResponse,
          'applicable_law': 'Payment and Settlement Systems Act 2007 and RBI Guidelines',
          'law_summary': 'Protects against unauthorized electronic transactions and banking fraud',
          'user_rights': 'Right to dispute unauthorized transactions and get refund within 90 days',
          'authorities': [
            'Banking Ombudsman: cms.rbi.org.in',
            'Cyber Crime Cell: cybercrime.gov.in'
          ]
        };
      
      case 'flights & travel issues':
        return {
          ...baseResponse,
          'applicable_law': 'Aircraft Act 1934 and DGCA Regulations',
          'law_summary': 'Protects air passengers against flight delays, cancellations, and overbooking',
          'user_rights': 'Right to compensation for delays and alternative flights for cancellations',
          'authorities': [
            'DGCA: dgca.gov.in',
            'Airline Grievance Officer: Contact airline directly'
          ]
        };
      
      default:
        return baseResponse;
    }
  }

  // Backward compatibility method
  Future<Map<String, dynamic>> analyze({
    required String problemText,
    required String selectedCategory,
  }) async {
    return await analyzeProblem(problemText, selectedCategory);
  }
}
