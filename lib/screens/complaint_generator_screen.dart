import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../providers/ai_provider.dart';
import '../providers/complaint_provider.dart';
import '../providers/problem_provider.dart';
import '../widgets/pro_upgrade_sheet.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/complaint_templates.dart';

class ComplaintGeneratorScreen extends ConsumerStatefulWidget {
  const ComplaintGeneratorScreen({super.key});

  @override
  ConsumerState<ComplaintGeneratorScreen> createState() =>
      _ComplaintGeneratorScreenState();
}

class _ComplaintGeneratorScreenState
    extends ConsumerState<ComplaintGeneratorScreen> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _opponent = TextEditingController();
  final _problem = TextEditingController();
  DateTime _incidentDate = DateTime.now();
  String _tab = 'Email Complaint';
  String _generated = '';
  String _category = '';
  late final FirebaseAnalytics _analytics;

  @override
  void initState() {
    super.initState();
    _analytics = FirebaseAnalytics.instance;
    final problem = ref.read(problemProvider);
    _problem.text = problem.description;
    _category = problem.category;
    _incidentDate = DateTime.now();
  }

  void _generate() async {
    final state = ref.read(complaintProvider);
    if (!state.isPro && state.generatedCount >= state.freeLimit) {
      showModalBottomSheet(
          context: context,
          showDragHandle: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (_) => const ProUpgradeSheet());
      return;
    }
    final result = ref.read(lastResultProvider);
    if (result == null) return;
    
    final problem = ref.read(problemProvider);
    final df = DateFormat('dd MMM yyyy');
    final incidentDf = DateFormat('dd MMM yyyy');
    
    // Get the appropriate template
    String templateType = _tab.toLowerCase().contains('email') ? 'email' : 
                         _tab.toLowerCase().contains('police') ? 'police' : 'consumer_court';
    String template = ComplaintTemplates.getTemplate(_category, templateType);
    
    // Replace placeholders with actual data
    String body = template
      .replaceAll('[Current Date]', df.format(DateTime.now()))
      .replaceAll('[Incident Date]', result.incidentDate ?? incidentDf.format(_incidentDate))
      .replaceAll('[Your Name]', _name.text.isEmpty ? '[Your Name]' : _name.text)
      .replaceAll('[Your Address]', _address.text.isEmpty ? '[Your Address]' : _address.text)
      .replaceAll('[Your Phone Number]', '[Your Phone Number]')
      .replaceAll('[Your Email Address]', '[Your Email Address]')
      .replaceAll('[Company Name]', result.companyName ?? (_opponent.text.isEmpty ? '[Company Name]' : _opponent.text))
      .replaceAll('[Order Number]', result.orderNumber ?? '[Order Number]')
      .replaceAll('[Product Details]', result.productDetails ?? '[Product Details]')
      .replaceAll('[Amount]', result.amountPaid ?? '[Amount]')
      .replaceAll('[Payment Method]', result.paymentMethod ?? '[Payment Method]')
      .replaceAll('[User Problem Description]', problem.description)
      .replaceAll('[User Rights from Legal Analysis]', result.userRights)
      .replaceAll('[Applicable Law]', result.applicableLaw);
    
    setState(() => _generated = body);
    
    // Log document generated event
    await _analytics.logEvent(
      name: 'document_generated',
      parameters: {
        'category': _category,
        'type': _tab.toLowerCase().replaceAll(' ', '_'),
      },
    );
    
    await ref.read(complaintProvider.notifier).increment();
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: _generated));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _share() {
    Share.share(_generated, subject: 'Consumer Complaint via JusLegal');
  }

  void _email() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: '',
      query: encodeQueryParameters({
        'subject': 'Consumer Complaint: ${_opponent.text}',
        'body': _generated,
      }),
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Generator')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.verifiedBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.verifiedBadge.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.verifiedBadge,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.documentDisclaimer,
                        style: const TextStyle(
                          color: AppColors.textDarkGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'Email Complaint', label: Text('Email Complaint')),
                  ButtonSegment(
                      value: 'Police Complaint Letter',
                      label: Text('Police Complaint')),
                  ButtonSegment(
                      value: 'Consumer Court Draft',
                      label: Text('Consumer Court Draft')),
                ],
                selected: {_tab},
                onSelectionChanged: (s) => setState(() => _tab = s.first),
              ),
              const SizedBox(height: 12),
              TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Full Name')),
              const SizedBox(height: 8),
              TextField(
                  controller: _address,
                  decoration: const InputDecoration(labelText: 'Address')),
              const SizedBox(height: 8),
              TextField(
                  controller: _opponent,
                  decoration:
                      const InputDecoration(labelText: 'Opponent name')),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Date of Incident'),
                subtitle: Text(DateFormat('dd MMM yyyy').format(_incidentDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _incidentDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    setState(() => _incidentDate = date);
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                  controller: _problem,
                  maxLines: 4,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Problem Description',
                    helperText: 'This is filled from your problem analysis',
                    border: OutlineInputBorder(),
                  )),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _generate, 
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate Letter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.trustNavy,
                  foregroundColor: AppColors.surfaceWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              if (_generated.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.successGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Generated Letter',
                      style: TextStyle(
                        fontWeight: FontWeight.w700, 
                        fontSize: 18,
                        color: AppColors.surfaceWhite,
                      )),
                ),
                const SizedBox(height: 8),
                TextField(
                    controller: TextEditingController(text: _generated),
                    maxLines: 12,
                    readOnly: true),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: OutlinedButton(
                            onPressed: _copy, child: const Text('Copy'))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: OutlinedButton(
                            onPressed: _share, child: const Text('Share'))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: OutlinedButton(
                            onPressed: _email, child: const Text('Email'))),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
