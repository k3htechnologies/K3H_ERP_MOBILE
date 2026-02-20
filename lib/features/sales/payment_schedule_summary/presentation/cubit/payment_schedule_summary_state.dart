import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/data/model/cost_sheet.model.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/data/model/payment_schedule_master_report.model.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/data/model/project_inventory_structure.model.dart';

class PaymentScheduleSummaryState extends BaseState {
  final int currentTabIndex;
  final List<ProjectInventoryStructure> projectInventoryList;
  final List<PaymentScheduleMasterReport> paymentScheduleMasterReportList;
  final List<CostSheetReport> costSheetReportList;
  final List<ProjectInventoryStructure> buildingList;
  final List<String> wingList;
  final List<String> flatConfigurationList;
  final String selectedFlatConfiguration;

  // New fields for dropdowns
  final ProjectInventoryStructure? selectedBuilding;
  final String? selectedWing;

  const PaymentScheduleSummaryState({
    super.isLoading,
    required this.currentTabIndex,
    required this.projectInventoryList,
    required this.paymentScheduleMasterReportList,
    required this.costSheetReportList,
    required this.buildingList,
    required this.wingList,
    required this.flatConfigurationList,
    required this.selectedFlatConfiguration,
    this.selectedBuilding,
    this.selectedWing,
  });

  factory PaymentScheduleSummaryState.initial() => PaymentScheduleSummaryState(
    isLoading: true,
    currentTabIndex: 0,
    projectInventoryList: [],
    paymentScheduleMasterReportList: [],
    costSheetReportList: [],
    buildingList: [],
    wingList: [],
    flatConfigurationList: [],
    selectedFlatConfiguration: '',
    selectedBuilding: null,
    selectedWing: null,
  );

  PaymentScheduleSummaryState copyWith({
    bool? isLoading,
    int? currentTabIndex,
    List<ProjectInventoryStructure>? projectInventoryList,
    List<PaymentScheduleMasterReport>? paymentScheduleMasterReportList,
    List<CostSheetReport>? costSheetReportList,
    List<ProjectInventoryStructure>? buildingList,
    List<String>? wingList,
    List<String>? flatConfigurationList,
    String? selectedFlatConfiguration,
    ProjectInventoryStructure? selectedBuilding,
    String? selectedWing,
  }) {
    return PaymentScheduleSummaryState(
      isLoading: isLoading ?? this.isLoading,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      projectInventoryList: projectInventoryList ?? this.projectInventoryList,
      paymentScheduleMasterReportList:
          paymentScheduleMasterReportList ??
          this.paymentScheduleMasterReportList,
      costSheetReportList: costSheetReportList ?? this.costSheetReportList,
      buildingList: buildingList ?? this.buildingList,
      wingList: wingList ?? this.wingList,
      flatConfigurationList:
          flatConfigurationList ?? this.flatConfigurationList,
      selectedFlatConfiguration:
          selectedFlatConfiguration ?? this.selectedFlatConfiguration,
      selectedBuilding: selectedBuilding ?? this.selectedBuilding,
      selectedWing: selectedWing ?? this.selectedWing,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    currentTabIndex,
    projectInventoryList,
    paymentScheduleMasterReportList,
    costSheetReportList,
    buildingList,
    wingList,
    flatConfigurationList,
    selectedFlatConfiguration,
    selectedBuilding,
    selectedWing,
  ];
}
