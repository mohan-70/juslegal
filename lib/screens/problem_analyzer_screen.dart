import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/problem_provider.dart';
import '../providers/ai_provider.dart';
import '../widgets/complaint_button.dart';

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
    final text = _controller.text.trim();
    ref.read(problemProvider.notifier).setDescription(text);
    
    // Use the new analysis provider
    await ref.read(analysisProvider.notifier).analyze(text, _category);
    
    if (mounted) {
      context.go('/home/result');
    }
  }

  @override
  Widget build(BuildContext context) {
    final valid = _controller.text.trim().length >= 30;
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
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text('${_controller.text.length}/1000'),
            ),
            const Spacer(),
            ComplaintButton(
                label: 'Analyze My Problem',
                onPressed: _analyze,
                enabled: valid),
          ],
        ),
      ),
    );
  }
}
