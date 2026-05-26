part of 'snag_checklist_cubit.dart';

class SnagChecklistState extends BaseState {
  final List<SnagChecklistModel> snagChecklist;
  const SnagChecklistState({super.isLoading, required this.snagChecklist});
  factory SnagChecklistState.inital() =>
      SnagChecklistState(isLoading: true, snagChecklist: []);

  SnagChecklistState copyWith({
    bool? isLoading,
    List<SnagChecklistModel>? snagChecklist,
  }) {
    return SnagChecklistState(
      isLoading: isLoading ?? this.isLoading,
      snagChecklist: snagChecklist ?? this.snagChecklist,
    );
  }

  @override
  List<Object?> get props => [isLoading, snagChecklist];
}
