import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/more/inward_outward/data/model/inward_outward.model.dart';

class InwardOutwardState extends BaseState {
  final List<InwardOutwardModel> inwardOutwardList;
  final int inwardOutwardTotalRecords;
  final int inwardOutwardCurrentPage;
  final String searchText;
  final int currentTabIndex;
  final String filterBySenderName;
  final String filterByReceiverName;
  final String filterByDocumentType;
  final String filterByDocumentTitle;
  final String filterByStatus;
  final String filterBySenderMobileNumber;
  final String filterByReceiverMobileNumber;
  final DateTime? filterByFromDate;
  final DateTime? filterByToDate;
  final String currentSortColumn;
  final String currentSortDirection;
  final InwardOutwardModel? inwardOutwardDetails;
  const InwardOutwardState({
    super.isLoading,
    required this.inwardOutwardList,
    required this.inwardOutwardTotalRecords,
    required this.inwardOutwardCurrentPage,
    required this.searchText,
    required this.currentTabIndex,
    required this.filterBySenderName,
    required this.filterByReceiverName,
    required this.filterByDocumentType,
    required this.filterByDocumentTitle,
    required this.filterByStatus,
    required this.filterBySenderMobileNumber,
    required this.filterByReceiverMobileNumber,
    required this.filterByFromDate,
    required this.filterByToDate,
    required this.currentSortColumn,
    required this.currentSortDirection,
    this.inwardOutwardDetails,
  });
  factory InwardOutwardState.initial() => const InwardOutwardState(
    isLoading: true,
    inwardOutwardList: [],
    inwardOutwardTotalRecords: 0,
    inwardOutwardCurrentPage: 1,
    searchText: "",
    currentTabIndex: 0,
    filterBySenderName: "",
    filterByReceiverName: "",
    filterByDocumentType: "",
    filterByDocumentTitle: "",
    filterByStatus: "",
    filterBySenderMobileNumber: "",
    filterByReceiverMobileNumber: "",
    filterByFromDate: null,
    filterByToDate: null,
    currentSortColumn: "",
    currentSortDirection: "",
    inwardOutwardDetails: null,
  );
  static const _noChange = Object();
  InwardOutwardState copyWith({
    bool? isLoading,
    List<InwardOutwardModel>? inwardOutwardList,
    int? inwardOutwardTotalRecords,
    int? inwardOutwardCurrentPage,
    String? searchText,
    int? currentTabIndex,
    String? filterBySenderName,
    String? filterByReceiverName,
    String? filterByDocumentType,
    String? filterByDocumentTitle,
    String? filterByStatus,
    String? filterBySenderMobileNumber,
    String? filterByReceiverMobileNumber,
    Object? filterByFromDate = _noChange,
    Object? filterByToDate = _noChange,
    String? currentSortColumn,
    String? currentSortDirection,
    InwardOutwardModel? inwardOutwardDetails,
  }) {
    return InwardOutwardState(
      isLoading: isLoading ?? this.isLoading,
      inwardOutwardList: inwardOutwardList ?? this.inwardOutwardList,
      inwardOutwardTotalRecords:
          inwardOutwardTotalRecords ?? this.inwardOutwardTotalRecords,
      inwardOutwardCurrentPage:
          inwardOutwardCurrentPage ?? this.inwardOutwardCurrentPage,
      searchText: searchText ?? this.searchText,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      filterBySenderName: filterBySenderName ?? this.filterBySenderName,
      filterByReceiverName: filterByReceiverName ?? this.filterByReceiverName,
      filterByDocumentType: filterByDocumentType ?? this.filterByDocumentType,
      filterByDocumentTitle:
          filterByDocumentTitle ?? this.filterByDocumentTitle,
      filterByStatus: filterByStatus ?? this.filterByStatus,
      filterBySenderMobileNumber:
          filterBySenderMobileNumber ?? this.filterBySenderMobileNumber,
      filterByReceiverMobileNumber:
          filterByReceiverMobileNumber ?? this.filterByReceiverMobileNumber,
      filterByFromDate:
          filterByFromDate == _noChange
              ? this.filterByFromDate
              : filterByFromDate as DateTime?,
      filterByToDate:
          filterByToDate == _noChange
              ? this.filterByToDate
              : filterByToDate as DateTime?,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      inwardOutwardDetails: inwardOutwardDetails ?? this.inwardOutwardDetails,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    inwardOutwardList,
    inwardOutwardTotalRecords,
    inwardOutwardCurrentPage,
    searchText,
    currentTabIndex,
    filterBySenderName,
    filterByReceiverName,
    filterByDocumentType,
    filterByDocumentTitle,
    filterByStatus,
    filterBySenderMobileNumber,
    filterByReceiverMobileNumber,
    filterByFromDate,
    filterByToDate,
    currentSortColumn,
    currentSortDirection,
    inwardOutwardDetails,
  ];
}
