import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.verified, color: Colors.green, size: 18),
        SizedBox(width: 6),
        Text('Verified by Legal Expert',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
