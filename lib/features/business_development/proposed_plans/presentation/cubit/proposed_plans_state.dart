import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/data/model/proposed_plans.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/data/model/form/building_form_model.dart';

class ProposedPlansState extends BaseState {
  final List<ProposedPlanBuilding> proposedPlansList;
  final int currentBuildingDetailTabIndex;
  final int currentBuildingIndex;
  final ProposedPlanFormDataModel proposedPlanForm;

  const ProposedPlansState({
    super.isLoading,
    required this.proposedPlansList,
    required this.currentBuildingDetailTabIndex,
    required this.currentBuildingIndex,
    required this.proposedPlanForm,
  });

  factory ProposedPlansState.initial() => ProposedPlansState(
    proposedPlansList: [],
    isLoading: true,
    currentBuildingDetailTabIndex: 0,
    currentBuildingIndex: 0,
    proposedPlanForm: ProposedPlanFormDataModel(),
  );

  ProposedPlansState copyWith({
    bool? isLoading,
    int? currentBuildingDetailTabIndex,
    int? currentProjectId,
    int? currentBuildingIndex,
    List<ProposedPlanBuilding>? proposedPlansList,
    ProposedPlanFormDataModel? proposedPlanForm,
  }) {
    return ProposedPlansState(
      isLoading: isLoading ?? this.isLoading,
      currentBuildingDetailTabIndex:
          currentBuildingDetailTabIndex ?? this.currentBuildingDetailTabIndex,
      currentBuildingIndex: currentBuildingIndex ?? this.currentBuildingIndex,
      proposedPlansList: proposedPlansList ?? this.proposedPlansList,
      proposedPlanForm: proposedPlanForm ?? this.proposedPlanForm,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    currentBuildingDetailTabIndex,
    currentBuildingIndex,
    proposedPlansList,
    proposedPlanForm,
  ];
}
