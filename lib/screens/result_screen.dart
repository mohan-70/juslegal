import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/ai_provider.dart';
import '../providers/problem_provider.dart';
import '../providers/cases_provider.dart';
import '../models/saved_case_model.dart';
import '../models/legal_result_model.dart';
import '../widgets/confidence_bar.dart';
import '../widgets/verified_badge.dart';
import '../widgets/step_card.dart';
import '../widgets/physical_action_card.dart';
import '../widgets/authority_card.dart';
import '../widgets/legal_disclaimer.dart';
import '../core/constants/app_colors.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  void _saveCase(BuildContext context, WidgetRef ref) async {
    final result = ref.read(lastResultProvider);
    final problem = ref.read(problemProvider);
    if (result == null) return;

    final caseModel = SavedCaseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: result.category,
      problemSnippet: problem.description.length > 100
          ? '${problem.description.substring(0, 97)}...'
          : problem.description,
      date: DateTime.now(),
      status: 'Active',
      resultJson: result.toJson(),
    );

    await ref.read(casesProvider.notifier).add(caseModel);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Case saved to My Cases')),
      );
    }
  }

  void _share(LegalResultModel result) {
    final text = 'JusLegal Analysis for ${result.category}\n\n'
        'Law: ${result.applicableLaw}\n'
        'Rights: ${result.userRights}\n\n'
        'Steps:\n${result.steps.asMap().entries.map((e) => "${e.key + 1}. ${e.value}").join("\n")}';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(lastResultProvider);
    final problem = ref.watch(problemProvider);
    if (result == null) {
      return const Scaffold(body: Center(child: Text('No analysis available')));
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _share(result),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VerifiedBadge(),
              const SizedBox(height: 16),
              
              const LegalDisclaimer(showDetailed: true),
              const SizedBox(height: 24),
              
              ConfidenceBar(confidence: result.confidence),
              const SizedBox(height: 12),
              if (result.isVerified) 
                const Row(
                  children: [
                    VerifiedBadge(),
                    SizedBox(width: 8),
                    Text(
                      'Verified by Legal Expert',
                      style: TextStyle(
                        color: AppColors.verifiedBadge,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Problem',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.textDarkGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(problem.description),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    backgroundColor: AppColors.navyLight,
                    label: Text(
                      result.applicableLaw,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                result.lawSummary,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.verifiedBackground.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Legal Rights',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textDarkGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.userRights,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Recommended Steps',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textDarkGrey,
                ),
              ),
              const SizedBox(height: 6),
              ...List.generate(
                result.steps.length,
                (i) => StepCard(index: i, text: result.steps[i]),
              ),
              if (result.physicalVisitRequired) ...[
                const SizedBox(height: 16),
                PhysicalActionCard(
                  instructions: result.physicalVisitInstructions ?? '',
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Authorities to Contact',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              ...result.authorities.map((a) => AuthorityCard(
                    name: a['name'] ?? '',
                    contact: a['contact'],
                    action: a['action'] ?? 'Action',
                    onAction: () {},
                  )),
              const SizedBox(height: 16),
              const Text(
                'Documents Required',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              ...result.documentsRequired.map((d) => CheckboxListTile(
                    value: false,
                    onChanged: (_) {},
                    title: Text(d),
                  )),
              const SizedBox(height: 16),
              const LegalDisclaimer(showDetailed: false),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _saveCase(context, ref),
                      child: const Text('Save Case'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _share(result),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.justiceGold,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Generate Complaint'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
