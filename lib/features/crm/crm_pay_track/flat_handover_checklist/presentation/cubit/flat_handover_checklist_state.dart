part of 'flat_handover_checklist_cubit.dart';

class FlatHandoverChecklistState extends BaseState {
  final List<FlatHandoverChecklistModel> flatHandoverCheckList;
  const FlatHandoverChecklistState({
    super.isLoading,
    required this.flatHandoverCheckList,
  });
  factory FlatHandoverChecklistState.initial() =>
      FlatHandoverChecklistState(isLoading: true, flatHandoverCheckList: []);
  FlatHandoverChecklistState copyWith({
    bool? isLoading,
    List<FlatHandoverChecklistModel>? flatHandoverCheckList,
  }) {
    return FlatHandoverChecklistState(
      isLoading: isLoading ?? this.isLoading,
      flatHandoverCheckList:
          flatHandoverCheckList ?? this.flatHandoverCheckList,
    );
  }

  @override
  List<Object?> get props => [isLoading, flatHandoverCheckList];
}
