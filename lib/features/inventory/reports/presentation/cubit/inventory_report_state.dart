import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/inventory/reports/data/model/inventory_parking_details.model.dart';
import 'package:k3h_erp_app/features/inventory/reports/data/model/inventory_parking_overall_report.model.dart';

class InventoryReportState extends BaseState {
  final List<InventoryParkingDetailsModel> reportList;
  final List<InventoryParkingOverallReport> reportDetailsList;
  final String? searchText;
  final int totalNumberOfRecord;
  final int currentPage;

  const InventoryReportState({
    super.isLoading,
    required this.reportList,
    required this.reportDetailsList,
    this.searchText,
    required this.totalNumberOfRecord,
    required this.currentPage,
  });

  factory InventoryReportState.initial() => InventoryReportState(
    totalNumberOfRecord: 0,
    currentPage: 1,

    isLoading: true,
    reportList: [],
    reportDetailsList: [],
    searchText: "",
  );

  InventoryReportState copyWith({
    bool? isLoading,
    List<InventoryParkingDetailsModel>? reportList,
    List<InventoryParkingOverallReport>? reportDetailsList,
    String? searchText,
    int? totalNumberOfRecord,
    int? currentPage,
  }) {
    return InventoryReportState(
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      reportList: reportList ?? this.reportList,
      reportDetailsList: reportDetailsList ?? this.reportDetailsList,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    totalNumberOfRecord,
    currentPage,
    reportList,
    reportDetailsList,
    searchText,
  ];
}
