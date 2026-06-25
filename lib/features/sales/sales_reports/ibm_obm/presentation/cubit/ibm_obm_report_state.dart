import 'package:k3h_erp_app/core/base_state.dart';
import '../../data/model/ibm_obm_report.model.dart';

class IbmObmReportState extends BaseState {
  // ================= LIST (MAIN)
  final List<IbmObmReportModel> ibmObmReportList;
  final int currentPageNumber;
  final int totalNumberOfRecord;

  // ================= VIEW LIST (SEPARATE)
  final List<IbmObmReportModel> viewReportList;

  // ================= SEARCH / SORT
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  // ================= FILTERS (MAIN)
  final DateTime? filterByFromDate;
  final DateTime? filterByToDate;
  final String filterByYear;
  final String filterByReportType;
  final int? filterByProjectId;

  // ================= FILTERS (VIEW)
  final DateTime? viewFilterByFromDate;
  final DateTime? viewFilterByToDate;
  final String viewFilterByYear;
  final String viewFilterByReportType;

  const IbmObmReportState({
    super.isLoading,

    // MAIN LIST
    required this.ibmObmReportList,
    this.currentPageNumber = 1,
    this.totalNumberOfRecord = 0,

    // VIEW LIST
    required this.viewReportList,

    // SEARCH / SORT
    this.searchText = '',
    this.currentSortColumn = '',
    this.currentSortDirection = '',

    // MAIN FILTERS
    this.filterByFromDate,
    this.filterByToDate,
    this.filterByYear = '',
    this.filterByReportType = '',
    this.filterByProjectId,

    // VIEW FILTERS
    this.viewFilterByFromDate,
    this.viewFilterByToDate,
    this.viewFilterByYear = '',
    this.viewFilterByReportType = '',
  });

  // ================= INITIAL
  factory IbmObmReportState.initial() => IbmObmReportState(
    isLoading: false,

    // MAIN LIST
    ibmObmReportList: const [],
    currentPageNumber: 1,
    totalNumberOfRecord: 0,

    // VIEW LIST
    viewReportList: const [],

    // FILTERS MAIN
    filterByFromDate: null,
    filterByToDate: null,
    filterByYear: '',
    filterByReportType: '',
    filterByProjectId: null,

    // FILTERS VIEW
    viewFilterByFromDate: null,
    viewFilterByToDate: null,
    viewFilterByYear: '',
    viewFilterByReportType: '',

    searchText: '',
    currentSortColumn: '',
    currentSortDirection: '',
  );

  // ================= NO CHANGE HELPER
  static const _noChange = Object();

  // ================= COPYWITH
  IbmObmReportState copyWith({
    bool? isLoading,

    // MAIN LIST
    List<IbmObmReportModel>? ibmObmReportList,
    int? currentPageNumber,
    int? totalNumberOfRecord,

    // VIEW LIST
    List<IbmObmReportModel>? viewReportList,

    // SEARCH / SORT
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,

    // MAIN FILTERS
    Object? filterByFromDate = _noChange,
    Object? filterByToDate = _noChange,
    String? filterByYear,
    String? filterByReportType,
    Object? filterByProjectId = _noChange,

    // VIEW FILTERS
    Object? viewFilterByFromDate = _noChange,
    Object? viewFilterByToDate = _noChange,
    String? viewFilterByYear,
    String? viewFilterByReportType,
  }) {
    return IbmObmReportState(
      isLoading: isLoading ?? this.isLoading,

      // MAIN LIST
      ibmObmReportList: ibmObmReportList ?? this.ibmObmReportList,
      currentPageNumber: currentPageNumber ?? this.currentPageNumber,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,

      // VIEW LIST
      viewReportList: viewReportList ?? this.viewReportList,

      // SEARCH / SORT
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,

      // MAIN FILTERS
      filterByFromDate:
          filterByFromDate == _noChange
              ? this.filterByFromDate
              : filterByFromDate as DateTime?,
      filterByToDate:
          filterByToDate == _noChange
              ? this.filterByToDate
              : filterByToDate as DateTime?,
      filterByYear: filterByYear ?? this.filterByYear,
      filterByReportType: filterByReportType ?? this.filterByReportType,
      filterByProjectId:
          filterByProjectId == _noChange
              ? this.filterByProjectId
              : filterByProjectId as int?,

      // VIEW FILTERS
      viewFilterByFromDate:
          viewFilterByFromDate == _noChange
              ? this.viewFilterByFromDate
              : viewFilterByFromDate as DateTime?,
      viewFilterByToDate:
          viewFilterByToDate == _noChange
              ? this.viewFilterByToDate
              : viewFilterByToDate as DateTime?,
      viewFilterByYear: viewFilterByYear ?? this.viewFilterByYear,
      viewFilterByReportType:
          viewFilterByReportType ?? this.viewFilterByReportType,
    );
  }

  // ================= PROPS
  @override
  List<Object?> get props => [
    isLoading,

    // MAIN
    ibmObmReportList,
    currentPageNumber,
    totalNumberOfRecord,

    // VIEW
    viewReportList,

    // SEARCH
    searchText,
    currentSortColumn,
    currentSortDirection,

    // MAIN FILTERS
    filterByFromDate,
    filterByToDate,
    filterByYear,
    filterByReportType,
    filterByProjectId,

    // VIEW FILTERS
    viewFilterByFromDate,
    viewFilterByToDate,
    viewFilterByYear,
    viewFilterByReportType,
  ];
}
