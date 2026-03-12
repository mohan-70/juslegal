import 'package:flutter/material.dart';

class CommunityWinCard extends StatelessWidget {
  final String city;
  final String category;
  final String outcome;
  final String law;
  const CommunityWinCard(
      {super.key,
      required this.city,
      required this.category,
      required this.outcome,
      required this.law});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('User from $city',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Chip(label: Text(category)),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  outcome,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                law,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
