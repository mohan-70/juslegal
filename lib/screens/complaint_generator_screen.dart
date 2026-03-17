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
import '../widgets/loading_message_widget.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_colors.dart';

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
  bool _isGenerating = false;
  late final FirebaseAnalytics _analytics;

  @override
  void initState() {
    super.initState();
    _analytics = FirebaseAnalytics.instance;
    final problem = ref.read(problemProvider);
    _problem.text = problem.description;
    _category = problem.category;
    
    // Attempt to pre-fill from result
    final result = ref.read(lastResultProvider);
    if (result != null) {
      if (result.companyName != null) _opponent.text = result.companyName!;
    }
  }

  void _generate() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
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
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please analyze your problem first.')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generated = '';
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      final templateType = _tab.toLowerCase().contains('email') ? 'email' : 
                          _tab.toLowerCase().contains('police') ? 'police' : 'consumer_court';
                          
      final df = DateFormat('dd MMM yyyy');
      
      final generatedText = await aiService.generateLetter(
        letterType: templateType,
        category: _category,
        problemDescription: _problem.text,
        userRights: result.userRights,
        applicableLaw: result.applicableLaw,
        steps: result.steps,
        senderName: _name.text,
        senderAddress: _address.text,
        opponentName: _opponent.text,
        incidentDate: result.incidentDate ?? df.format(_incidentDate),
      );

      // Clean up the text in case AI added markdown blocks
      String cleanText = generatedText.trim();
      if (cleanText.startsWith('```')) {
        final lines = cleanText.split('\n');
        if (lines.length > 2) {
          cleanText = lines.sublist(1, lines.length - 1).join('\n');
        }
      }

      setState(() => _generated = cleanText);
      
      await _analytics.logEvent(
        name: 'document_generated',
        parameters: {
          'category': _category,
          'type': templateType,
        },
      );
      
      await ref.read(complaintProvider.notifier).increment();
      
      if (mounted) {
        // Scroll down to the result seamlessly
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate letter: $e'),
            backgroundColor: AppColors.warningSoftRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
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
        'subject': 'Consumer Complaint: ${_opponent.text.isNotEmpty ? _opponent.text : "Grievance"}',
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
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Draft Document', style: TextStyle(
          color: AppColors.textDarkGrey,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        )),
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDarkGrey),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Disclaimer banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.trustNavy.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.trustNavy.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.trustNavy,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.documentDisclaimer,
                        style: const TextStyle(
                          color: AppColors.textDarkGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              const Text('Select Format', style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDarkGrey
              )),
              const SizedBox(height: 12),
              
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Email Complaint', label: Text('Email')),
                    ButtonSegment(value: 'Police Complaint Letter', label: Text('Police')),
                    ButtonSegment(value: 'Consumer Court Draft', label: Text('Consumer Court')),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (s) => setState(() => _tab = s.first),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text('Details (Optional)', style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDarkGrey
              )),
              const SizedBox(height: 12),
              
              _buildTextField(_name, 'Your Full Name', Icons.person_outline),
              const SizedBox(height: 12),
              _buildTextField(_address, 'Your Address', Icons.home_outlined),
              const SizedBox(height: 12),
              _buildTextField(_opponent, 'Opponent / Company Name', Icons.business_outlined),
              const SizedBox(height: 16),
              
              // Custom Date Picker Tile
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey200),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: AppColors.textMediumGrey),
                        const SizedBox(width: 12),
                        const Text('Date of Incident', style: TextStyle(fontSize: 14)),
                        const Spacer(),
                        Text(
                          DateFormat('dd MMM yyyy').format(_incidentDate),
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.trustNavy)
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generate, 
                  icon: _isGenerating 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isGenerating ? 'Generating with AI...' : 'Generate Document'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.trustNavy,
                    foregroundColor: AppColors.surfaceWhite,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              
              if (_isGenerating)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: LoadingMessageWidget(message: 'JusLegal AI is crafting your professional document...',),
                ),
              
              if (_generated.isNotEmpty) ...[
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: AppColors.successEmerald,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Generated Successfully',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.successEmerald.withOpacity(0.3)),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _generated, 
                          textAlign: TextAlign.left,
                          style: const TextStyle(height: 1.5, color: AppColors.textDarkGrey),
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(child: _buildActionButton(Icons.copy, 'Copy', _copy)),
                            Expanded(child: _buildActionButton(Icons.share_outlined, 'Share', _share)),
                            if (_tab.contains('Email'))
                              Expanded(child: _buildActionButton(Icons.email_outlined, 'Send', _email)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textMediumGrey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.grey200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.grey200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.trustNavy, width: 2)),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.trustNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

