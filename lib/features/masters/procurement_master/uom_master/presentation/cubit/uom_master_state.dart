part of 'uom_master_cubit.dart';

class UOMMasterState extends BaseState {
  final List<UOMModel> uomList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const UOMMasterState({
    super.isLoading,
    required this.uomList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory UOMMasterState.initial() => UOMMasterState(
    uomList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    isLoading: true,
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );

  UOMMasterState copyWith({
    String? errorMessage,
    bool? isLoading,
    bool? success,
    List<UOMModel>? uomList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return UOMMasterState(
      isLoading: isLoading ?? this.isLoading,
      uomList: uomList ?? this.uomList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    uomList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
  ];
}
