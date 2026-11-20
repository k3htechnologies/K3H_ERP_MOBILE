part of 'client_loan_report_cubit.dart';

final class ClientLoanReportState extends BaseState {
  final List<ClientLoanReportModel> clientLoanReportList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterByApplicantName;
  const ClientLoanReportState({
    super.isLoading,
    required this.clientLoanReportList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.filterByApplicantName,
  });

  factory ClientLoanReportState.initial() => ClientLoanReportState(
    isLoading: true,
    clientLoanReportList: [],
    totalNumberOfRecord: 0,
    currentPage: 0,
    searchText: '',
    currentSortColumn: '',
    currentSortDirection: '',
    filterByApplicantName: '',
  );
  ClientLoanReportState copyWith({
    bool? isLoading,
    List<ClientLoanReportModel>? clientLoanReportList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
    String? filterByApplicantName,
  }) {
    return ClientLoanReportState(
      isLoading: isLoading ?? this.isLoading,
      clientLoanReportList: clientLoanReportList ?? this.clientLoanReportList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterByApplicantName:
          filterByApplicantName ?? this.filterByApplicantName,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    clientLoanReportList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
    filterByApplicantName,
  ];
}
