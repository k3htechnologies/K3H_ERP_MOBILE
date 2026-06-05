part of 'ticket_cubit.dart';

class TicketState extends BaseState {
  final List<TicketModel> ticketList;
  final TicketModel? ticketModel;
  final int currentPage;
  final int totalNumberOfRecord;
  final List<TicketEmployeeModel> employeeList;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterPlatform;
  final String filterModule;
  final String filterPriority;
  final String filterDepartment;
  final String filterStatus;
  const TicketState({
    super.isLoading,
    required this.ticketList,
    required this.ticketModel,
    required this.currentPage,
    required this.totalNumberOfRecord,
    required this.employeeList,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.filterPlatform,
    required this.filterModule,
    required this.filterPriority,
    required this.filterDepartment,
    required this.filterStatus,
  });

  factory TicketState.initial() => TicketState(
    isLoading: true,
    ticketList: [],
    ticketModel: null,
    currentPage: 1,
    totalNumberOfRecord: 0,
    employeeList: [],
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    filterPlatform: '',
    filterModule: '',
    filterPriority: '',
    filterDepartment: '',
    filterStatus: '',
  );

  TicketState copyWith({
    bool? isLoading,
    List<TicketModel>? ticketList,
    TicketModel? ticketModel,
    int? currentPage,
    int? totalNumberOfRecord,
    List<TicketEmployeeModel>? employeeList,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
    String? filterPlatform,
    String? filterModule,
    String? filterPriority,
    String? filterDepartment,
    String? filterStatus,
  }) {
    return TicketState(
      isLoading: isLoading ?? this.isLoading,
      ticketList: ticketList ?? this.ticketList,
      ticketModel: ticketModel ?? this.ticketModel,
      currentPage: currentPage ?? this.currentPage,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      employeeList: employeeList ?? this.employeeList,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterPlatform: filterPlatform ?? this.filterPlatform,
      filterModule: filterModule ?? this.filterModule,
      filterPriority: filterPriority ?? this.filterPriority,
      filterDepartment: filterDepartment ?? this.filterDepartment,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    currentPage,
    ticketList,
    ticketModel,
    totalNumberOfRecord,
    employeeList,
    searchText,
    currentSortColumn,
    currentSortDirection,
    filterPlatform,
    filterModule,
    filterPriority,
    filterStatus,
    filterDepartment,
  ];
}
