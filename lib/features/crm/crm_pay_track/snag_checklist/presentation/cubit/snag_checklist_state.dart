part of 'snag_checklist_cubit.dart';

class SnagChecklistState extends BaseState {
  final List<SnagChecklistModel> snagChecklist;
  final String currentCategory;
  final Map<String, int> categoryPendingCounts;
  const SnagChecklistState({
    super.isLoading,
    required this.snagChecklist,
    required this.currentCategory,
    this.categoryPendingCounts = const {},
  });
  factory SnagChecklistState.inital() => SnagChecklistState(
    isLoading: true,
    snagChecklist: [],
    currentCategory: '',
    categoryPendingCounts: {},
  );

  SnagChecklistState copyWith({
    bool? isLoading,
    List<SnagChecklistModel>? snagChecklist,
    String? currentCategory,
    Map<String, int>? categoryPendingCounts,
  }) {
    return SnagChecklistState(
      isLoading: isLoading ?? this.isLoading,
      snagChecklist: snagChecklist ?? this.snagChecklist,
      currentCategory: currentCategory ?? this.currentCategory,
      categoryPendingCounts:
          categoryPendingCounts ?? this.categoryPendingCounts,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    snagChecklist,
    currentCategory,
    categoryPendingCounts,
  ];
}
