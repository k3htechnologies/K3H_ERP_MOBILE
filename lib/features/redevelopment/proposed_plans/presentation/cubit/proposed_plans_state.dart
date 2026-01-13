part of 'proposed_plans_cubit.dart';

class ProposedPlansState extends BaseState {
  final List<ProposedPlansModel> proposedPlansList;
  final int currentProjectId;
  final int currentTabIndex;

  const ProposedPlansState({
    super.isLoading,
    required this.proposedPlansList,
    required this.currentProjectId,
    required this.currentTabIndex,
  });

  factory ProposedPlansState.initial() => ProposedPlansState(
    proposedPlansList: [],
    isLoading: true,
    currentTabIndex: 0,
    currentProjectId: 0,
  );

  ProposedPlansState copyWith({
    bool? isLoading,
    int? currentTabIndex,
    int? currentProjectId,
    List<ProposedPlansModel>? proposedPlansList,
  }) {
    return ProposedPlansState(
      isLoading: isLoading ?? this.isLoading,
      currentProjectId: currentProjectId ?? this.currentProjectId,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,

      proposedPlansList: proposedPlansList ?? this.proposedPlansList,
    );
  }

  @override
  List<Object?> get props => [isLoading, currentTabIndex, currentProjectId, proposedPlansList];
}
