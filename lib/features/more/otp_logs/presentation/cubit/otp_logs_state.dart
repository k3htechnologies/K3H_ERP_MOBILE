part of 'otp_logs_cubit.dart';

class OtpLogsState extends BaseState {
  final List<OtpLogsModel> ticketList;
  final OtpLogsModel? ticketModel;
  final int currentPage;
  final int totalNumberOfRecord;
  final String searchText;
  final String filterMobileNumber;
  final String filterModuleName;
  final DateTime? filterFromDate;
  final DateTime? filterToDate;
  const OtpLogsState({
    super.isLoading,
    required this.ticketList,
    required this.ticketModel,
    required this.currentPage,
    required this.totalNumberOfRecord,
    required this.searchText,
    required this.filterMobileNumber,
    required this.filterModuleName,
    this.filterFromDate,
    this.filterToDate,
  });

  factory OtpLogsState.initial() => OtpLogsState(
    isLoading: true,
    ticketList: [],
    ticketModel: null,
    currentPage: 1,
    totalNumberOfRecord: 0,
    searchText: "",
    filterMobileNumber: '',
    filterModuleName: '',
    filterFromDate: null,
    filterToDate: null,
  );

  OtpLogsState copyWith({
    bool? isLoading,
    List<OtpLogsModel>? ticketList,
    OtpLogsModel? ticketModel,
    int? currentPage,
    int? totalNumberOfRecord,
    String? searchText,
    String? filterMobileNumber,
    String? filterModuleName,
    DateTime? filterFromDate,
    DateTime? filterToDate,
  }) {
    return OtpLogsState(
      isLoading: isLoading ?? this.isLoading,
      ticketList: ticketList ?? this.ticketList,
      ticketModel: ticketModel ?? this.ticketModel,
      currentPage: currentPage ?? this.currentPage,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      searchText: searchText ?? this.searchText,
      filterMobileNumber: filterMobileNumber ?? this.filterMobileNumber,
      filterModuleName: filterModuleName ?? this.filterModuleName,
      filterFromDate: filterFromDate ?? this.filterFromDate,
      filterToDate: filterToDate ?? this.filterToDate,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    currentPage,
    ticketList,
    ticketModel,
    totalNumberOfRecord,
    searchText,
    filterMobileNumber,
    filterModuleName,
  ];
}
