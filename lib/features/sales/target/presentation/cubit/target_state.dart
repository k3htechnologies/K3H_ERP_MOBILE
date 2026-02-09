part of 'target_cubit.dart';

class TargetState extends BaseState {
  final List<TargetModel> salesTargets;
  final int totalNumberOfRecords;
  final int currentPage;
  final DateTime currentTargetMonth;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const TargetState({
    super.isLoading,
    required this.salesTargets,
    required this.totalNumberOfRecords,
    required this.currentPage,
    required this.currentTargetMonth,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory TargetState.initial() => TargetState(
    isLoading: false,
    salesTargets: [],
    totalNumberOfRecords: 0,
    currentPage: 1,
    currentTargetMonth: DateTime.now(),
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );

  TargetState copyWith({
    String? errorMessage,
    bool? isLoading,
    List<TargetModel>? salesTargets,
    int? totalNumberOfRecords,
    int? currentPage,
    DateTime? currentTargetMonth,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return TargetState(
      isLoading: isLoading ?? this.isLoading,
      salesTargets: salesTargets ?? this.salesTargets,
      totalNumberOfRecords: totalNumberOfRecords ?? this.totalNumberOfRecords,
      currentPage: currentPage ?? this.currentPage,
      currentTargetMonth: currentTargetMonth ?? this.currentTargetMonth,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    salesTargets,
    totalNumberOfRecords,
    currentPage,
    currentTargetMonth,
    searchText,
    currentSortColumn,
    currentSortDirection,
  ];
}
