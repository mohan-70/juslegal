import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CommunityWinCard extends StatelessWidget {
  final String city;
  final String category;
  final String outcome;
  final String law;

  const CommunityWinCard({
    super.key,
    required this.city,
    required this.category,
    required this.outcome,
    required this.law,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.successEmerald.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    size: 14,
                    color: AppColors.successEmerald,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'From $city',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textDarkGrey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Category chip
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.trustNavy.withOpacity(0.07),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.trustNavy,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            // Outcome
            Expanded(
              child: Text(
                outcome,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: AppColors.textDarkGrey.withOpacity(0.82),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            // Law footer
            Text(
              law,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMediumGrey.withOpacity(0.65),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
