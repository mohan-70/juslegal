import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import '../providers/ai_provider.dart';
import '../providers/problem_provider.dart';
import '../providers/cases_provider.dart';
import '../models/saved_case_model.dart';
import '../models/legal_result_model.dart';
import '../core/constants/app_colors.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _bannerController;
  late AnimationController _loadingController;
  late Animation<Offset> _bannerAnimation;
  final List<bool> _expandedSteps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bannerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bannerAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bannerController,
      curve: Curves.easeOutQuart,
    ));

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize loading state
    _simulateLoading();
    
    // Start banner animation after loading
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _bannerController.forward();
      }
    });
  }

  void _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      setState(() {
        _isLoading = false;
        // Initialize expanded steps state
        final result = ref.read(lastResultProvider);
        if (result != null) {
          _expandedSteps.addAll(List.generate(result.steps.length, (_) => false));
        }
      });
    }
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

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

  void _generateComplaint(BuildContext context) {
    context.push('/home/complaint');
  }

  void _toggleStep(int index) {
    setState(() {
      _expandedSteps[index] = !_expandedSteps[index];
    });
  }

  void _showLawBottomSheet(String lawName, String lawSummary) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.trustNavy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.book,
                    color: AppColors.trustNavy,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lawName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.trustNavy,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              lawSummary,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppColors.textDarkGrey,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  LinearGradient _getCaseStrengthGradient(int confidence) {
    if (confidence >= 85) {
      return const LinearGradient(
        colors: [AppColors.successEmerald, Color(0xFF27AE60)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else if (confidence >= 60) {
      return const LinearGradient(
        colors: [AppColors.justiceGold, Color(0xFFE67E22)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else {
      return const LinearGradient(
        colors: [AppColors.warningSoftRed, Color(0xFFC0392B)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
  }

  String _getCaseStrengthTitle(int confidence) {
    if (confidence >= 85) return 'Strong Case';
    if (confidence >= 60) return 'Moderate Case';
    return 'Weak Case';
  }

  Widget _buildLoadingState() {
    return Container(
      color: AppColors.backgroundOffWhite,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  final progress = _loadingController.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (progress > 0.0)
                        Opacity(
                          opacity: progress > 0.0 ? 1.0 : 0.0,
                          child: const Text(
                            '🔍  Analyzing your case...',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.trustNavy,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (progress > 0.2)
                        Opacity(
                          opacity: progress > 0.2 ? 1.0 : 0.0,
                          child: const Text(
                            '📚  Checking Consumer Protection Act 2019...',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.trustNavy,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (progress > 0.4)
                        Opacity(
                          opacity: progress > 0.4 ? 1.0 : 0.0,
                          child: const Text(
                            '⚖️   Calculating case strength...',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.trustNavy,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (progress > 0.6)
                        Opacity(
                          opacity: progress > 0.6 ? 1.0 : 0.0,
                          child: const Text(
                            '📋  Preparing action steps...',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.trustNavy,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (progress > 0.8)
                        Opacity(
                          opacity: progress > 0.8 ? 1.0 : 0.0,
                          child: const Text(
                            '✅  Your result is ready',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.justiceGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(lastResultProvider);
    if (result == null) {
      return const Scaffold(body: Center(child: Text('No analysis available')));
    }

    if (_isLoading) {
      return _buildLoadingState();
    }

    
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundOffWhite,
        elevation: 0,
        title: const Text(
          'Analysis Result',
          style: TextStyle(
            color: AppColors.textDarkGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.textDarkGrey),
            onPressed: () => _share(result),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Legal Disclaimer Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.amber[700], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'AI-generated information only. This is NOT legal advice. '
                            'Always consult a qualified advocate for legal proceedings.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Zone 1: Case Strength Banner
                  SlideTransition(
                    position: _bannerAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: _getCaseStrengthGradient(result.confidence),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shield,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getCaseStrengthTitle(result.confidence),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'You have clear legal grounds',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xDDFFFFFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Zone 2: Your Rights Summary
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: const Border(left: BorderSide(color: AppColors.justiceGold, width: 3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.gavel,
                              color: AppColors.trustNavy,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Your Rights',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.trustNavy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          result.userRights,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textDarkGrey,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Zone 3: Action Steps
                  const Text(
                    'Action Steps',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDarkGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(result.steps.length, (index) {
                    final isExpanded = index < _expandedSteps.length ? _expandedSteps[index] : false;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _toggleStep(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isExpanded ? AppColors.trustNavy.withOpacity(0.04) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isExpanded ? AppColors.trustNavy : const Color(0xFFE8ECF0),
                              width: isExpanded ? 1.5 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: AppColors.trustNavy,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      result.steps[index].length > 50
                                          ? '${result.steps[index].substring(0, 47)}...'
                                          : result.steps[index],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDarkGrey,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: AppColors.textMediumGrey,
                                  ),
                                ],
                              ),
                              if (isExpanded) ...[
                                const SizedBox(height: 12),
                                Text(
                                  result.steps[index],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textMediumGrey,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // Zone 4: Relevant Laws as Chips
                  const Text(
                    'Relevant Laws',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDarkGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      GestureDetector(
                        onTap: () => _showLawBottomSheet(result.applicableLaw, result.lawSummary),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.trustNavy.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.trustNavy.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.book,
                                size: 14,
                                color: AppColors.trustNavy,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                result.applicableLaw,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.trustNavy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Zone 5: Trust Disclaimer (above sticky buttons)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 12,
                        color: AppColors.textMediumGrey,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'AI guidance only • Not a substitute for legal advice',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMediumGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // Zone 5: CTA Buttons (sticky at bottom)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.backgroundOffWhite,
              border: Border(top: BorderSide(color: Color(0xFFE8ECF0))),
            ),
            child: Column(
              children: [
                // Primary Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _generateComplaint(context),
                    icon: const Icon(Icons.description_outlined, size: 20),
                    label: const Text(
                      'Generate Complaint Letter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.trustNavy,
                      shadowColor: AppColors.trustNavy.withOpacity(0.35),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Secondary Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _saveCase(context, ref),
                    icon: const Icon(Icons.send_outlined, size: 20),
                    label: const Text(
                      'Contact Authority Directly',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.trustNavy,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.trustNavy, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}