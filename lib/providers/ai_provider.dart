import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/legal_result_model.dart';
import '../services/ai_service.dart';
import '../core/exceptions/ai_exceptions.dart';

// Provider for AIService instance
final aiServiceProvider = Provider<AIService>((ref) => AIService());

// Analysis state
class AnalysisState {
  final AsyncValue<LegalResultModel>? result;
  final bool isLoading;

  AnalysisState({this.result, this.isLoading = false});

  AnalysisState copyWith({
    AsyncValue<LegalResultModel>? result,
    bool? isLoading,
  }) {
    return AnalysisState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// AsyncNotifier for analysis state management
class AnalysisNotifier extends AsyncNotifier<AnalysisState> {
  late final AIService _aiService;
  late final FirebaseAnalytics _analytics;

  @override
  AnalysisState build() {
    _aiService = ref.read(aiServiceProvider);
    _analytics = FirebaseAnalytics.instance;
    return AnalysisState();
  }

  Future<void> analyze(String problemText, String category) async {
    state = AsyncValue.data(AnalysisState(isLoading: true));

    try {
      // Log analysis started event
      await _analytics.logEvent(
        name: 'analysis_started',
        parameters: {
          'category': category,
          'problem_length': problemText.length,
        },
      );

      // Initialize AI service
      await _aiService.initialize();

      // Analyze the problem using backward compatibility method
      final analysisResult = await _aiService.analyze(problemText: problemText, selectedCategory: category);

      // Convert Map to LegalResultModel
      final legalResult = _mapToLegalResultModel(analysisResult);

      // Update both new and old providers
      ref.read(lastResultProvider.notifier).state = legalResult;

      // Log analysis completed event
      await _analytics.logEvent(
        name: 'analysis_completed',
        parameters: {
          'category': category,
          'confidence': legalResult.confidence,
        },
      );

      state = AsyncValue.data(AnalysisState(
        result: AsyncValue.data(legalResult),
        isLoading: false,
      ));
    } catch (e, stackTrace) {
      
      // Log analysis error event
      await _analytics.logEvent(
        name: 'analysis_error',
        parameters: {
          'category': category,
          'error_type': e.runtimeType.toString(),
        },
      );

      String errorMessage = _getErrorMessage(e);
      state = AsyncValue.error(errorMessage, stackTrace);
    }
  }

  LegalResultModel _mapToLegalResultModel(Map<String, dynamic> data) {
    // Extract authorities list - handle both string and map formats
    List<Map<String, String>> authorities = [];
    if (data['authorities'] is List) {
      final authList = data['authorities'] as List;
      authorities = authList.map((e) {
        if (e is String) {
          // Convert string to map format
          return {
            'name': e,
            'contact': _defaultContactFor(e),
            'action': _defaultActionFor(e),
          };
        } else if (e is Map) {
          return Map<String, String>.from(e);
        }
        return {'name': e.toString(), 'contact': '', 'action': ''};
      }).toList();
    }

    return LegalResultModel(
      category: data['category'] ?? '',
      applicableLaw: data['applicable_law'] ?? '',
      lawSummary: data['law_summary'] ?? '',
      userRights: data['user_rights'] ?? '',
      steps: List<String>.from(data['steps'] ?? []),
      authorities: authorities,
      documentsRequired: List<String>.from(data['documents_required'] ?? []),
      physicalVisitRequired: data['physical_visit_required'] ?? false,
      physicalVisitInstructions: data['physical_visit_instructions'],
      confidence: data['confidence'] ?? 0,
      isVerified: data['isVerified'] ?? false,
      complaintHint: data['complaint_hint'] ?? '',
    );
  }

  String _defaultContactFor(String name) {
    final map = {
      'National Consumer Helpline': '1800-11-4000',
      'Cyber Crime Portal': 'cybercrime.gov.in',
      'RBI Complaint Portal': 'cms.rbi.org.in',
      'DGCA': 'dgca.gov.in',
      'TRAI Consumer Portal': 'trai.gov.in',
      'FSSAI': 'fssai.gov.in',
      'Medical Council of India': 'mciindia.org',
      'District Consumer Commission': 'Find nearest',
      'Traffic Police (Local)': 'Find nearest',
      'Education Regulatory Authority': 'File Online',
      'Airline Grievance Officer': 'Contact airline',
      'Consumer Commission': 'File online',
    };
    return map[name] ?? '';
  }

  String _defaultActionFor(String name) {
    if (name.contains('Helpline') || name.contains('Police')) return 'Call Now';
    if (name.contains('Commission') ||
        name.contains('Portal') ||
        name.contains('DGCA') ||
        name.contains('TRAI') ||
        name.contains('Officer')) {
      return 'File Online';
    }
    return 'Visit Website';
  }

  String _getErrorMessage(dynamic error) {
    if (error is AllProvidersFailedException) {
      return "Service temporarily unavailable. Please try again in a few minutes.";
    } else if (error is NetworkException) {
      return "No internet connection. Please check your network and try again.";
    } else if (error is RateLimitException) {
      return "Too many requests. Please wait a moment and try again.";
    } else if (error is ApiKeyException) {
      return "Service configuration error. Please try again later.";
    } else if (error is ParseException) {
      return "Unable to process AI response. Please try again.";
    } else if (error is Exception) {
      // Handle generic exceptions from AI service
      final message = error.toString();
      if (message.contains('unavailable') || message.contains('temporarily')) {
        return "AI services are temporarily unavailable. Please try again in a few minutes.";
      } else if (message.contains('network') || message.contains('connection')) {
        return "Network connection issue. Please check your internet and try again.";
      } else if (message.contains('API key') || message.contains('configured')) {
        return "Service configuration error. Please try again later.";
      } else {
        return "Something went wrong. Please try again.";
      }
    } else {
      return "Something went wrong. Please try again.";
    }
  }

  void reset() {
    state = AsyncValue.data(AnalysisState());
  }
}

// Provider for the analysis notifier
final analysisProvider = AsyncNotifierProvider<AnalysisNotifier, AnalysisState>(() {
  return AnalysisNotifier();
});

// Convenience provider to watch only the result
final analysisResultProvider = Provider<AsyncValue<LegalResultModel>?>((ref) {
  final analysisState = ref.watch(analysisProvider);
  return analysisState.maybeWhen(
    data: (state) => state.result,
    orElse: () => null,
  );
});

// Convenience provider to watch loading state
final analysisLoadingProvider = Provider<bool>((ref) {
  final analysisState = ref.watch(analysisProvider);
  return analysisState.maybeWhen(
    data: (state) => state.isLoading,
    orElse: () => false,
  );
});

// Provider for last result (for backward compatibility)
final lastResultProvider = StateProvider<LegalResultModel?>((ref) => null);
