import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class LegalDisclaimer extends StatelessWidget {
  final bool showDetailed;
  final EdgeInsets? padding;

  const LegalDisclaimer({
    super.key,
    this.showDetailed = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0x1A4CAF50),
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border(
          top: BorderSide(color: Color(0x4D4CAF50), width: 1),
          bottom: BorderSide(color: Color(0x4D4CAF50), width: 1),
          left: BorderSide(color: Color(0x4D4CAF50), width: 1),
          right: BorderSide(color: Color(0x4D4CAF50), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Color(0xFF4CAF50),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Important Legal Notice',
                  style: TextStyle(
                    color: Color(0xFF424242),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            showDetailed 
                ? 'This is AI-generated legal guidance based on Indian consumer law. It is not a substitute for professional legal advice. For serious matters, court cases, or complex disputes, always consult a practicing advocate.'
                : 'This is general legal guidance, not legal advice. Consult a lawyer for serious matters.',
            style: const TextStyle(
              color: Color(0xFF757575),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          if (showDetailed) ...[
            const SizedBox(height: 12),
            _buildTrustIndicators(),
          ],
        ],
      ),
    );
  }

  Widget _buildTrustIndicators() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTrustItem(
          icon: Icons.gavel,
          title: 'Based on Indian Law',
          subtitle: 'Consumer Protection Act 2019, specific sections',
        ),
        const SizedBox(height: 8),
        _buildTrustItem(
          icon: Icons.security,
          title: 'Data Source Verified',
          subtitle: 'Official legal knowledge base',
        ),
        const SizedBox(height: 8),
        _buildTrustItem(
          icon: Icons.people,
          title: '50,000+ Users Helped',
          subtitle: 'Real outcomes across India',
        ),
      ],
    );
  }

  Widget _buildTrustItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.verifiedBadge.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.verifiedBadge,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF424242),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
