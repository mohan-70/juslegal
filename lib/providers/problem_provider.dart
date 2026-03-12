import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProblemState {
  final String category;
  final String description;
  ProblemState({required this.category, required this.description});

  ProblemState copyWith({String? category, String? description}) =>
      ProblemState(
          category: category ?? this.category,
          description: description ?? this.description);
}

class ProblemNotifier extends StateNotifier<ProblemState> {
  ProblemNotifier() : super(ProblemState(category: '', description: ''));

  void setCategory(String category) =>
      state = state.copyWith(category: category);
  void setDescription(String description) =>
      state = state.copyWith(description: description);
}

final problemProvider = StateNotifierProvider<ProblemNotifier, ProblemState>(
    (ref) => ProblemNotifier());
