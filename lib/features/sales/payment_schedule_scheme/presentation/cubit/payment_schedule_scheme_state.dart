import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/data/model/project_inventory_structure.model.dart';
import '../../../../inventory/data/model/building.model.dart';
import '../../data/model/payment_schedule_scheme.model.dart';

class PaymentScheduleSchemeState extends BaseState {
  final List<PaymentScheduleSchemeModel> paymentScheduleSchemeList;
  final String searchText;
  final int totalNumberOfRecord;
  final int currentPage;
  final String currentSortColumn;
  final String currentSortDirection;

  /// ---------------- NEW ----------------
  final List<ProjectInventoryStructure> projectInventoryList;
  final List<ProjectInventoryStructure> buildingList;
  final List<ProjectInventoryStructure> wingList;
  // final int? selectedBuilding;
  // final int? selectedWing;

  const PaymentScheduleSchemeState({
    required super.isLoading,
    required this.paymentScheduleSchemeList,
    required this.searchText,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.projectInventoryList,
    required this.buildingList,
    required this.wingList,
    // required this.selectedBuilding,
    // required this.selectedWing,
  });

  factory PaymentScheduleSchemeState.initial() => PaymentScheduleSchemeState(
    isLoading: false,
    paymentScheduleSchemeList: [],
    searchText: "",
    totalNumberOfRecord: 0,
    currentPage: 1,
    currentSortColumn: "CreatedDate",
    currentSortDirection: "DESC",

    /// ---- NEW INITIAL ----
    projectInventoryList: [],
    buildingList: [],
    wingList: [],
    // selectedBuilding: null,
    // selectedWing: null,
  );

  PaymentScheduleSchemeState copyWith({
    bool? isLoading,
    List<PaymentScheduleSchemeModel>? paymentScheduleSchemeList,
    String? searchText,
    int? totalNumberOfRecord,
    int? currentPage,
    String? currentSortColumn,
    String? currentSortDirection,

    /// ---- NEW ----
    List<ProjectInventoryStructure>? projectInventoryList,
    List<ProjectInventoryStructure>? buildingList,
    List<ProjectInventoryStructure>? wingList,
    int? selectedBuilding,
    int? selectedWing,
  }) {
    return PaymentScheduleSchemeState(
      isLoading: isLoading ?? this.isLoading,
      paymentScheduleSchemeList:
          paymentScheduleSchemeList ?? this.paymentScheduleSchemeList,
      searchText: searchText ?? this.searchText,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,

      /// ---- NEW ----
      projectInventoryList: projectInventoryList ?? this.projectInventoryList,
      buildingList: buildingList ?? this.buildingList,
      wingList: wingList ?? this.wingList,
      // selectedBuilding: selectedBuilding ?? this.selectedBuilding,
      // selectedWing: selectedWing ?? this.selectedWing,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    paymentScheduleSchemeList,
    searchText,
    totalNumberOfRecord,
    currentPage,
    currentSortColumn,
    currentSortDirection,

    /// ---- NEW ----
    projectInventoryList,
    buildingList,
    wingList,
    // selectedBuilding,
    // selectedWing,
  ];
}
