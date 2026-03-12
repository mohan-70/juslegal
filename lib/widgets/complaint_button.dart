import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ComplaintButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  const ComplaintButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: enabled ? onPressed : null,
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
