import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/proposed_plans.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/form/building_form_model.dart';

class ProposedPlansState extends BaseState {
  final List<ProposedPlanBuilding> proposedPlansList;
  final int currentBuildingDetailTabIndex;
  final int currentBuildingIndex;
  final BuildingFormDataModel buildingForm;

  const ProposedPlansState({
    super.isLoading,
    required this.proposedPlansList,
    required this.currentBuildingDetailTabIndex,
    required this.currentBuildingIndex,
    required this.buildingForm,
  });

  factory ProposedPlansState.initial() => ProposedPlansState(
    proposedPlansList: [],
    isLoading: true,
    currentBuildingDetailTabIndex: 0,
    currentBuildingIndex: 0,
    buildingForm: BuildingFormDataModel(),
  );

  ProposedPlansState copyWith({
    bool? isLoading,
    int? currentBuildingDetailTabIndex,
    int? currentProjectId,
    int? currentBuildingIndex,
    List<ProposedPlanBuilding>? proposedPlansList,
    BuildingFormDataModel? buildingForm,
  }) {
    return ProposedPlansState(
      isLoading: isLoading ?? this.isLoading,
      currentBuildingDetailTabIndex:
          currentBuildingDetailTabIndex ?? this.currentBuildingDetailTabIndex,
      currentBuildingIndex: currentBuildingIndex ?? this.currentBuildingIndex,
      proposedPlansList: proposedPlansList ?? this.proposedPlansList,
      buildingForm: buildingForm ?? this.buildingForm,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    currentBuildingDetailTabIndex,
    currentBuildingIndex,
    proposedPlansList,
    buildingForm,
  ];
}
