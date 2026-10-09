import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/finance/reports/data/model/term_sheet_report.model.dart';

class TermSheetReportState extends BaseState {
  final List<TermSheetReportModel> termSheetReportList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterByCompanyName;
  final String filterByStatus;
  final String filterByInstitutionName;
  const TermSheetReportState({
    super.isLoading,
    required this.termSheetReportList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    this.currentSortColumn = "",
    this.currentSortDirection = "",
    this.filterByCompanyName = '',
    this.filterByStatus = '',
    this.filterByInstitutionName = '',
  });
  factory TermSheetReportState.initial() => TermSheetReportState(
    termSheetReportList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: '',
    isLoading: true,
    filterByCompanyName: '',
    filterByStatus: '',
    filterByInstitutionName: '',
    currentSortColumn: "",
    currentSortDirection: "",
  );
  TermSheetReportState copyWith({
    bool? isLoading,
    List<TermSheetReportModel>? termSheetReportList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? filterByCompanyName,
    String? filterByStatus,
    String? filterByInstitutionName,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return TermSheetReportState(
      isLoading: isLoading ?? this.isLoading,
      termSheetReportList: termSheetReportList ?? this.termSheetReportList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      filterByCompanyName: filterByCompanyName ?? this.filterByCompanyName,
      filterByStatus: filterByStatus ?? this.filterByStatus,
      filterByInstitutionName:
          filterByInstitutionName ?? this.filterByInstitutionName,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    termSheetReportList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    filterByCompanyName,
    filterByStatus,
    filterByInstitutionName,
    currentSortColumn,
    currentSortDirection,
  ];
}
