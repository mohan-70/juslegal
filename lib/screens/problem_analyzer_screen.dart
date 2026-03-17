import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/problem_provider.dart';
import '../providers/ai_provider.dart';
import '../widgets/complaint_button.dart';
import '../widgets/loading_message_widget.dart';
import '../core/constants/app_colors.dart';

class ProblemAnalyzerScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  const ProblemAnalyzerScreen({super.key, this.initialCategory});

  @override
  ConsumerState<ProblemAnalyzerScreen> createState() =>
      _ProblemAnalyzerScreenState();
}

class _ProblemAnalyzerScreenState
    extends ConsumerState<ProblemAnalyzerScreen> {
  late final TextEditingController _controller;
  String _category = '';
  bool _isAnalyzing = false;

  String _getCategoryExample() {
    switch (_category) {
      case 'E-commerce & Shopping':
        return 'e.g. Flipkart seller refused my refund after 10 days';
      case 'Banking & UPI Fraud':
        return 'e.g. Unauthorized UPI transaction of ₹5,000 from my account';
      case 'Flights & Travel Issues':
        return 'e.g. Airline cancelled my flight and denied refund';
      case 'Restaurant & Food Billing':
        return 'e.g. Restaurant overcharged me and added fake GST charges';
      case 'Hospital Billing Problems':
        return 'e.g. Hospital charged ₹50,000 for tests not performed';
      case 'Traffic & Vehicle Issues':
        return 'e.g. Wrong traffic challan issued for my parked car';
      case 'Telecom & Internet Services':
        return 'e.g. Telecom company deducted balance without usage';
      case 'Education & Coaching Complaints':
        return 'e.g. Coaching institute refused refund after course cancellation';
      case 'Rental & Housing Issues':
        return 'e.g. Landlord illegally deducting security deposit';
      case 'Government Service Problems':
        return 'e.g. Passport office delayed processing beyond timeline';
      default:
        return 'e.g. Describe your legal issue in detail...';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _category = widget.initialCategory ?? '';
    if (_category.isNotEmpty) {
      Future.microtask(() {
        ref.read(problemProvider.notifier).setCategory(_category);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyze() async {
    if (_isAnalyzing) return;

    final text = _controller.text.trim();

    if (text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Please enter at least 10 characters to analyze your problem.'),
          backgroundColor: AppColors.warningSoftRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      ref.read(problemProvider.notifier).setDescription(text);
      await ref.read(analysisProvider.notifier).analyze(text, _category);
      if (mounted) context.go('/home/result');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: $e'),
            backgroundColor: AppColors.warningSoftRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textLength = _controller.text.trim().length;
    final valid = textLength >= 10 && !_isAnalyzing;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.textDarkGrey),
        ),
        title: const Text(
          'Describe Your Problem',
          style: TextStyle(
            color: AppColors.textDarkGrey,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    16, 12, 16, bottomInset > 0 ? 8 : 16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category chip
                    if (_category.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.trustNavy.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.trustNavy.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.category_rounded,
                                size: 14, color: AppColors.trustNavy),
                            const SizedBox(width: 6),
                            Text(
                              _category,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.trustNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Tips card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.justiceGold.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.justiceGold.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.tips_and_updates_rounded,
                              size: 18, color: AppColors.justiceGold),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Describe when, where, and what happened. Mention amounts, dates and any communication with the other party.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: AppColors.textDarkGrey
                                    .withOpacity(0.75),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Text field label
                    const Text(
                      'Your Problem',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDarkGrey,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Text field
                    TextField(
                      controller: _controller,
                      maxLines: 9,
                      maxLength: 1000,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText:
                            'Describe your issue in detail...\n${_getCategoryExample()}',
                        hintStyle: TextStyle(
                          color: AppColors.textMediumGrey.withOpacity(0.6),
                          fontSize: 13,
                          height: 1.6,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: AppColors.grey200, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: AppColors.grey200, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: AppColors.trustNavy, width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        counterStyle: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMediumGrey.withOpacity(0.7),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.55,
                        color: AppColors.textDarkGrey,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                    // Hint under field
                    if (!valid && textLength > 0 && textLength < 10)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Enter ${10 - textLength} more character${10 - textLength == 1 ? '' : 's'} to continue',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.warningSoftRed.withOpacity(0.8),
                          ),
                        ),
                      ),

                    // Loading widget
                    if (_isAnalyzing)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: LoadingMessageWidget(),
                      ),
                  ],
                ),
              ),
            ),

            // ── Sticky bottom action area ─────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                border: Border(
                  top: BorderSide(
                    color: AppColors.grey200.withOpacity(0.8),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ComplaintButton(
                    label: _isAnalyzing ? '' : 'Analyze My Problem',
                    onPressed: _analyze,
                    enabled: valid,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI-generated information only · Not legal advice · Always verify',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMediumGrey.withOpacity(0.55),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
