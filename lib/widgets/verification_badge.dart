import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum VerificationType {
  ai,
  legalExpert,
  userTestimonial,
}

class VerificationBadge extends StatelessWidget {
  final VerificationType type;
  final String? text;
  final bool showTooltip;

  const VerificationBadge({
    super.key,
    required this.type,
    this.text,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: 14,
            color: _getIconColor(),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text ?? _getDefaultText(),
              style: TextStyle(
                color: _getTextColor(),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case VerificationType.legalExpert:
        return AppColors.verifiedBackground;
      case VerificationType.userTestimonial:
        return AppColors.verifiedBackground;
      case VerificationType.ai:
      default:
        return AppColors.aiBackground;
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case VerificationType.legalExpert:
        return AppColors.verifiedBadge;
      case VerificationType.userTestimonial:
        return AppColors.verifiedBadge;
      case VerificationType.ai:
      default:
        return AppColors.aiBadge;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case VerificationType.legalExpert:
        return AppColors.verifiedBadge;
      case VerificationType.userTestimonial:
        return AppColors.verifiedBadge;
      case VerificationType.ai:
      default:
        return AppColors.aiBadge;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case VerificationType.legalExpert:
        return AppColors.verifiedBadge;
      case VerificationType.userTestimonial:
        return AppColors.verifiedBadge;
      case VerificationType.ai:
      default:
        return AppColors.aiBadge;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case VerificationType.legalExpert:
        return Icons.verified_user;
      case VerificationType.userTestimonial:
        return Icons.person;
      case VerificationType.ai:
      default:
        return Icons.smart_toy;
    }
  }

  String _getDefaultText() {
    switch (type) {
      case VerificationType.legalExpert:
        return 'Verified by Legal Expert';
      case VerificationType.userTestimonial:
        return 'Real User Success';
      case VerificationType.ai:
      default:
        return 'AI Analysis';
    }
  }
}
