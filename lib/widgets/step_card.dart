import 'package:flutter/material.dart';

class StepCard extends StatelessWidget {
  final int index;
  final String text;
  const StepCard({super.key, required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Text('${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Text(text),
      ),
    );
  }
}
