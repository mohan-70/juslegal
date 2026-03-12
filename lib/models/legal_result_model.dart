class LegalResultModel {
  final String category;
  final String applicableLaw;
  final String lawSummary;
  final String userRights;
  final List<String> steps;
  final List<Map<String, String>> authorities;
  final List<String> documentsRequired;
  final bool physicalVisitRequired;
  final String? physicalVisitInstructions;
  final int confidence; // 0-100
  final bool isVerified;
  final String complaintHint;

  LegalResultModel({
    required this.category,
    required this.applicableLaw,
    required this.lawSummary,
    required this.userRights,
    required this.steps,
    required this.authorities,
    required this.documentsRequired,
    required this.physicalVisitRequired,
    this.physicalVisitInstructions,
    required this.confidence,
    required this.isVerified,
    required this.complaintHint,
  });

  factory LegalResultModel.fromJson(Map<String, dynamic> json) {
    return LegalResultModel(
      category: json['category'] as String,
      applicableLaw: json['applicable_law'] as String,
      lawSummary: json['law_summary'] as String,
      userRights: json['user_rights'] as String,
      steps: List<String>.from(json['steps'] as List<dynamic>),
      authorities: List<Map<String, String>>.from(
        (json['authorities'] as List<dynamic>)
            .map((e) => Map<String, String>.from(e as Map)),
      ),
      documentsRequired:
          List<String>.from(json['documents_required'] as List<dynamic>),
      physicalVisitRequired: json['physical_visit_required'] as bool,
      physicalVisitInstructions: json['physical_visit_instructions'] as String?,
      confidence: (json['confidence'] as num).toInt(),
      isVerified: json['isVerified'] as bool,
      complaintHint: json['complaint_hint'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'applicable_law': applicableLaw,
        'law_summary': lawSummary,
        'user_rights': userRights,
        'steps': steps,
        'authorities': authorities,
        'documents_required': documentsRequired,
        'physical_visit_required': physicalVisitRequired,
        'physical_visit_instructions': physicalVisitInstructions,
        'confidence': confidence,
        'isVerified': isVerified,
        'complaint_hint': complaintHint,
      };
}
