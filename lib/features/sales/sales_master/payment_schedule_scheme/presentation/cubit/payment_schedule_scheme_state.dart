import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/inventory/data/model/project_inventory_structure.model.dart';
import '../../data/model/payment_schedule_scheme.model.dart';

class PaymentScheduleSchemeState extends BaseState {
  final List<PaymentScheduleSchemeModel> paymentScheduleSchemeList;
  final String searchText;
  final int totalNumberOfRecord;
  final int currentPage;
  final String currentSortColumn;
  final String currentSortDirection;
  final List<ProjectInventoryStructure> projectInventoryList;
  final List<ProjectInventoryStructure> buildingList;
  final List<ProjectInventoryStructure> wingList;

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
  });

  factory PaymentScheduleSchemeState.initial() => PaymentScheduleSchemeState(
    isLoading: false,
    paymentScheduleSchemeList: [],
    searchText: "",
    totalNumberOfRecord: 0,
    currentPage: 1,
    currentSortColumn: "CreatedDate",
    currentSortDirection: "DESC",
    projectInventoryList: [],
    buildingList: [],
    wingList: [],
  );

  PaymentScheduleSchemeState copyWith({
    bool? isLoading,
    List<PaymentScheduleSchemeModel>? paymentScheduleSchemeList,
    String? searchText,
    int? totalNumberOfRecord,
    int? currentPage,
    String? currentSortColumn,
    String? currentSortDirection,
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
      projectInventoryList: projectInventoryList ?? this.projectInventoryList,
      buildingList: buildingList ?? this.buildingList,
      wingList: wingList ?? this.wingList,
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
    projectInventoryList,
    buildingList,
    wingList,
  ];
}
