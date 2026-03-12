import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers/cases_provider.dart';
import '../providers/ai_provider.dart';
import '../models/legal_result_model.dart';

class MyCasesScreen extends ConsumerStatefulWidget {
  const MyCasesScreen({super.key});

  @override
  ConsumerState<MyCasesScreen> createState() => _MyCasesScreenState();
}

class _MyCasesScreenState extends ConsumerState<MyCasesScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final cases = ref.watch(casesProvider);
    final filtered = _filter == 'All'
        ? cases
        : cases.where((c) => c.status == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Cases')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'Active', 'Resolved', 'Pending'].map((f) {
                final isSelected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _filter = f);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('No cases saved yet',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        Text('Analyze a problem to get started',
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      return Dismissible(
                        key: Key(c.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          ref.read(casesProvider.notifier).remove(c.id);
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () {
                              ref.read(lastResultProvider.notifier).state =
                                  LegalResultModel.fromJson(c.resultJson);
                              context.go('/home/result');
                            },
                            title: Text(c.category,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(DateFormat('dd MMM yyyy').format(c.date)),
                                Text(c.problemSnippet,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Chip(
                                  label: Text(c.status,
                                      style: const TextStyle(fontSize: 10)),
                                  backgroundColor: c.status == 'Resolved'
                                      ? Colors.green[50]
                                      : Colors.blue[50],
                                ),
                                if (c.status != 'Resolved')
                                  GestureDetector(
                                    onTap: () => ref
                                        .read(casesProvider.notifier)
                                        .markResolved(c.id),
                                    child: const Text('Mark Resolved',
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.blue)),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
