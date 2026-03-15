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
  
  // Complaint details extracted from user input
  final String? orderNumber;
  final String? productDetails;
  final String? amountPaid;
  final String? paymentMethod;
  final String? companyName;
  final String? incidentDate;
  final String? location;

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
    this.orderNumber,
    this.productDetails,
    this.amountPaid,
    this.paymentMethod,
    this.companyName,
    this.incidentDate,
    this.location,
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
      orderNumber: json['order_number'] as String?,
      productDetails: json['product_details'] as String?,
      amountPaid: json['amount_paid'] as String?,
      paymentMethod: json['payment_method'] as String?,
      companyName: json['company_name'] as String?,
      incidentDate: json['incident_date'] as String?,
      location: json['location'] as String?,
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
