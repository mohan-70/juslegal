import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class PhysicalActionCard extends StatelessWidget {
  final String instructions;
  const PhysicalActionCard({super.key, required this.instructions});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.accent.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⚠', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Physical Action Required',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(instructions),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
