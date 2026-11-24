part of 'outdoor_cubit.dart';

class OutdoorState extends BaseState {
  final List<OutdoorModel> outdoorList;
  final int totalNumberOfRecord;
  final int departmentTotalCount;
  final int employeeTotalCount;
  final int currentPage;
  final String searchText;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  const OutdoorState({
    super.isLoading,
    required this.outdoorList,
    required this.totalNumberOfRecord,
    required this.departmentTotalCount,
    required this.employeeTotalCount,
    required this.currentPage,
    required this.searchText,
    this.filterStartDate,
    this.filterEndDate,
  });

  factory OutdoorState.initial() => OutdoorState(
    isLoading: true,
    outdoorList: [],
    totalNumberOfRecord: 0,
    departmentTotalCount: 0,
    employeeTotalCount: 0,
    currentPage: 1,
    searchText: "",
    filterStartDate: null,
    filterEndDate: null,
  );

  OutdoorState copyWith({
    bool? isLoading,
    List<OutdoorModel>? outdoorList,
    List<DepartmentModel>? departmentList,
    List<UserModel>? employeeList,
    int? totalNumberOfRecord,
    int? departmentTotalCount,
    int? employeeTotalCount,
    int? currentPage,
    String? searchText,

    Object? filterStartDate = _noChange,
    Object? filterEndDate = _noChange,
  }) {
    return OutdoorState(
      isLoading: isLoading ?? this.isLoading,
      outdoorList: outdoorList ?? this.outdoorList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      departmentTotalCount: departmentTotalCount ?? this.departmentTotalCount,
      employeeTotalCount: employeeTotalCount ?? this.employeeTotalCount,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      filterStartDate:
          filterStartDate == _noChange
              ? this.filterStartDate
              : filterStartDate as DateTime?,
      filterEndDate:
          filterEndDate == _noChange
              ? this.filterEndDate
              : filterEndDate as DateTime?,
    );
  }

  static const _noChange = Object();

  @override
  List<Object?> get props => [
    isLoading,
    outdoorList,
    totalNumberOfRecord,
    departmentTotalCount,
    employeeTotalCount,
    currentPage,
    searchText,
    filterStartDate,
    filterEndDate,
  ];
}
