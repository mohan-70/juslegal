import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AuthorityCard extends StatelessWidget {
  final String name;
  final String? contact;
  final String? purpose;
  final String action;
  final VoidCallback onAction;
  const AuthorityCard({
    super.key,
    required this.name,
    this.contact,
    this.purpose,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (contact != null && contact!.isNotEmpty)
                    Text(contact!,
                        style: const TextStyle(color: Colors.black54)),
                  if (purpose != null && purpose!.isNotEmpty)
                    Text(purpose!,
                        style: const TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onAction,
              child: Text(action),
            ),
          ],
        ),
      ),
    );
  }
}
