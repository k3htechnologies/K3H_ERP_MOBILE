part of 'outdoor_cubit.dart';

class OutdoorState extends BaseState {
  final List<OutdoorModel> outdoorList;
  final List<DepartmentModel> departmentList;
  final List<UserModel> employeeList;
  final int totalNumberOfRecord;
  final int departmentTotalCount;
  final int employeeTotalCount;
  final int currentPage;
  final String searchText;
  final int currentTabIndex;

  const OutdoorState({
    super.isLoading,
    required this.outdoorList,
    required this.departmentList,
    required this.employeeList,
    required this.totalNumberOfRecord,
    required this.departmentTotalCount,
    required this.employeeTotalCount,
    required this.currentPage,
    required this.searchText,
    required this.currentTabIndex,
  });

  factory OutdoorState.initial() => OutdoorState(
    isLoading: true,
    outdoorList: [],
    departmentList: [],
    employeeList: [],
    totalNumberOfRecord: 0,
    departmentTotalCount: 0,
    employeeTotalCount: 0,
    currentPage: 1,
    searchText: "",
    currentTabIndex: 0,
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
    int? currentTabIndex,
  }) {
    return OutdoorState(
      isLoading: isLoading ?? this.isLoading,
      outdoorList: outdoorList ?? this.outdoorList,
      departmentList: departmentList ?? this.departmentList,
      employeeList: employeeList ?? this.employeeList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      departmentTotalCount: departmentTotalCount ?? this.departmentTotalCount,
      employeeTotalCount: employeeTotalCount ?? this.employeeTotalCount,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    outdoorList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentTabIndex,
  ];
}

