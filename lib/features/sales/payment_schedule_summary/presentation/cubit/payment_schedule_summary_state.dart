import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/data/model/cost_sheet.model.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/data/model/payment_schedule_master_report.model.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/data/model/project_inventory_structure.model.dart';

class PaymentScheduleSummaryState extends BaseState {
  final int currentTabIndex;
  final List<ProjectInventoryStructure> projectInventoryList;
  final List<PaymentScheduleMasterReport> paymentScheduleReportList;
  final List<CostSheetReport> costSheetReportList;
  final List<ProjectInventoryStructure> buildingList;
  final List<String> wingList;
  final List<String> flatConfigurationList;
  final String selectedFlatConfiguration;
  final ProjectInventoryStructure? selectedBuilding;
  final String? selectedWing;
  final int paymentScheduleCurrentPage;
  final int paymentScheduleTotalRecords;
  final int costSheetCurrentPage;
  final int costSheetTotalRecords;

  const PaymentScheduleSummaryState({
    super.isLoading,
    required this.currentTabIndex,
    required this.projectInventoryList,
    required this.paymentScheduleReportList,
    required this.costSheetReportList,
    required this.buildingList,
    required this.wingList,
    required this.flatConfigurationList,
    required this.selectedFlatConfiguration,
    this.selectedBuilding,
    this.selectedWing,
    this.paymentScheduleCurrentPage = 1,
    this.paymentScheduleTotalRecords = 0,
    this.costSheetCurrentPage = 1,
    this.costSheetTotalRecords = 0,
  });

  factory PaymentScheduleSummaryState.initial() => PaymentScheduleSummaryState(
    isLoading: true,
    currentTabIndex: 0,
    projectInventoryList: [],
    paymentScheduleReportList: [],
    costSheetReportList: [],
    buildingList: [],
    wingList: [],
    flatConfigurationList: [],
    selectedFlatConfiguration: '',
    selectedBuilding: null,
    selectedWing: null,
    paymentScheduleCurrentPage: 1,
    paymentScheduleTotalRecords: 0,
    costSheetCurrentPage: 1,
    costSheetTotalRecords: 0,
  );

  PaymentScheduleSummaryState copyWith({
    bool? isLoading,
    int? currentTabIndex,
    List<ProjectInventoryStructure>? projectInventoryList,
    List<PaymentScheduleMasterReport>? paymentScheduleReportList,
    List<CostSheetReport>? costSheetReportList,
    List<ProjectInventoryStructure>? buildingList,
    List<String>? wingList,
    List<String>? flatConfigurationList,
    String? selectedFlatConfiguration,
    ProjectInventoryStructure? selectedBuilding,
    String? selectedWing,
    int? paymentScheduleCurrentPage,
    int? paymentScheduleTotalRecords,
    int? costSheetCurrentPage,
    int? costSheetTotalRecords,
  }) {
    return PaymentScheduleSummaryState(
      isLoading: isLoading ?? this.isLoading,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      projectInventoryList: projectInventoryList ?? this.projectInventoryList,
      paymentScheduleReportList:
          paymentScheduleReportList ?? this.paymentScheduleReportList,
      costSheetReportList: costSheetReportList ?? this.costSheetReportList,
      buildingList: buildingList ?? this.buildingList,
      wingList: wingList ?? this.wingList,
      flatConfigurationList:
          flatConfigurationList ?? this.flatConfigurationList,
      selectedFlatConfiguration:
          selectedFlatConfiguration ?? this.selectedFlatConfiguration,
      selectedBuilding: selectedBuilding ?? this.selectedBuilding,
      selectedWing: selectedWing ?? this.selectedWing,
      paymentScheduleCurrentPage:
          paymentScheduleCurrentPage ?? this.paymentScheduleCurrentPage,
      paymentScheduleTotalRecords:
          paymentScheduleTotalRecords ?? this.paymentScheduleTotalRecords,
      costSheetCurrentPage: costSheetCurrentPage ?? this.costSheetCurrentPage,
      costSheetTotalRecords:
          costSheetTotalRecords ?? this.costSheetTotalRecords,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    currentTabIndex,
    projectInventoryList,
    paymentScheduleReportList,
    costSheetReportList,
    buildingList,
    wingList,
    flatConfigurationList,
    selectedFlatConfiguration,
    selectedBuilding,
    selectedWing,
    paymentScheduleCurrentPage,
    paymentScheduleTotalRecords,
    costSheetCurrentPage,
    costSheetTotalRecords,
  ];
}
