import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/proposed_plans.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/form/building_form_model.dart';

class ProposedPlansState extends BaseState {
  final List<ProposedPlanBuilding> proposedPlansList;

  final int currentProjectId;
  final int currentTabIndex;
  final int currentBuildingIndex;
  final BuildingFormDataModel buildingForm;

  const ProposedPlansState({
    super.isLoading,
    required this.proposedPlansList,
    required this.currentProjectId,
    required this.currentTabIndex,
    required this.currentBuildingIndex,
    required this.buildingForm,
  });

  factory ProposedPlansState.initial() => ProposedPlansState(
    proposedPlansList: [],
    isLoading: true,
    currentTabIndex: 0,
    currentProjectId: 0,
    currentBuildingIndex: 0,
    buildingForm: BuildingFormDataModel(),
  );

  ProposedPlansState copyWith({
    bool? isLoading,
    int? currentTabIndex,
    int? currentProjectId,
    int? currentBuildingIndex,
    List<ProposedPlanBuilding>? proposedPlansList,
    BuildingFormDataModel? buildingForm,
  }) {
    return ProposedPlansState(
      isLoading: isLoading ?? this.isLoading,
      currentProjectId: currentProjectId ?? this.currentProjectId,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      currentBuildingIndex: currentBuildingIndex ?? this.currentBuildingIndex,
      proposedPlansList: proposedPlansList ?? this.proposedPlansList,
      buildingForm: buildingForm ?? this.buildingForm,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    currentTabIndex,
    currentProjectId,
    currentBuildingIndex,
    proposedPlansList,
    buildingForm,
  ];
}
