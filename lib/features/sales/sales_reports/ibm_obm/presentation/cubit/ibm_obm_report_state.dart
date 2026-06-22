import 'package:k3h_erp_app/core/base_state.dart';

import '../../data/model/ibm_obm_report.model.dart';

class IbmObmReportState extends BaseState {
  final List<IbmObmReportModel> ibmObmReportList;

  final int currentPageNumber;
  final int totalNumberOfRecord;

  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const IbmObmReportState({
    super.isLoading,
    required this.ibmObmReportList,
    this.currentPageNumber = 1,
    this.totalNumberOfRecord = 0,
    this.searchText = '',
    this.currentSortColumn = '',
    this.currentSortDirection = '',
  });

  factory IbmObmReportState.initial() => const IbmObmReportState(
    isLoading: false,
    ibmObmReportList: [],
    currentPageNumber: 1,
    totalNumberOfRecord: 0,
    searchText: '',
    currentSortColumn: '',
    currentSortDirection: '',
  );

  IbmObmReportState copyWith({
    bool? isLoading,
    List<IbmObmReportModel>? ibmObmReportList,
    int? currentPageNumber,
    int? totalNumberOfRecord,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return IbmObmReportState(
      isLoading: isLoading ?? this.isLoading,
      ibmObmReportList: ibmObmReportList ?? this.ibmObmReportList,
      currentPageNumber: currentPageNumber ?? this.currentPageNumber,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    ibmObmReportList,
    currentPageNumber,
    totalNumberOfRecord,
    searchText,
    currentSortColumn,
    currentSortDirection,
  ];
}
