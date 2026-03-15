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

class _ProblemAnalyzerScreenState extends ConsumerState<ProblemAnalyzerScreen> {
  late final TextEditingController _controller;
  String _category = '';
  bool _isAnalyzing = false;

  String _getCategoryExample() {
    switch (_category) {
      case 'E-commerce & Shopping':
        return 'Example: Flipkart seller refused my refund after 10 days';
      case 'Banking & UPI Fraud':
        return 'Example: Unauthorized UPI transaction of ₹5,000 from my account';
      case 'Flights & Travel Issues':
        return 'Example: Airline cancelled my flight and denied refund';
      case 'Restaurant & Food Billing':
        return 'Example: Restaurant overcharged me and added fake GST charges';
      case 'Hospital Billing Problems':
        return 'Example: Hospital charged ₹50,000 for tests not performed';
      case 'Traffic & Vehicle Issues':
        return 'Example: Wrong traffic challan issued for my parked car';
      case 'Telecom & Internet Services':
        return 'Example: Telecom company deducted balance without usage';
      case 'Education & Coaching Complaints':
        return 'Example: Coaching institute refused refund after course cancellation';
      case 'Rental & Housing Issues':
        return 'Example: Landlord illegally deducting security deposit';
      case 'Government Service Problems':
        return 'Example: Passport office delayed processing beyond timeline';
      default:
        return 'Example: Describe your issue in detail';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _category = widget.initialCategory ?? '';
    if (_category.isNotEmpty) {
      // Delay the provider update to avoid modifying during widget build
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
    if (_isAnalyzing) {
      print('⏳ Analysis already in progress');
      return;
    }
    
    final text = _controller.text.trim();
    print('🔍 Analysis button clicked');
    print('📝 Text length: ${text.length}');
    print('📂 Category: $_category');
    
    if (text.length < 30) {
      print('❌ Text too short, showing error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least 30 characters to analyze your problem.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isAnalyzing = true;
    });
    
    try {
      print('🔄 Starting analysis...');
      ref.read(problemProvider.notifier).setDescription(text);
      
      // Use the new analysis provider
      await ref.read(analysisProvider.notifier).analyze(text, _category);
      
      print('✅ Analysis completed, navigating to result screen');
      if (mounted) {
        context.go('/home/result');
      }
    } catch (e) {
      print('❌ Analysis failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textLength = _controller.text.trim().length;
    final valid = textLength >= 30 && !_isAnalyzing;
    print('🔍 Button state - Text length: $textLength, Valid: $valid, Analyzing: $_isAnalyzing');
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
        title: const Text('Describe Your Problem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_category.isNotEmpty)
              Wrap(spacing: 8, children: [Chip(label: Text(_category))]),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText:
                    'Describe your problem in detail...\n${_getCategoryExample()}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  // Force rebuild to update button state
                });
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text('${_controller.text.length}/1000'),
            ),
            const Spacer(),
            Column(
              children: [
                ComplaintButton(
                    label: _isAnalyzing ? '' : 'Analyze My Problem',
                    onPressed: _analyze,
                    enabled: valid),
                if (!valid && textLength > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      textLength < 30 
                          ? 'Please enter at least ${30 - textLength} more characters'
                          : 'Please wait for analysis to complete',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
            if (_isAnalyzing)
              const Padding(
                padding: EdgeInsets.all(16),
                child: LoadingMessageWidget(),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'JusLegal provides AI-generated information only. This is NOT legal advice. '
                'For legal proceedings, consult a qualified advocate. '
                'AI responses may be inaccurate — always verify with official sources.',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
