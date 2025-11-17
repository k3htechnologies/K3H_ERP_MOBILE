part of 'employee_master_cubit.dart';

class EmployeeMasterState extends BaseState {
  final List<UserModel> employeeMasterList;
  final Map<int, List<CityModel>> stateMap;
  final Map<int, List<CityModel>> districtMap;
  final List<Map<String, dynamic>> stateList;
  final List<Map<String, dynamic>> districtList;
  final List<Map<String, dynamic>> cityList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterDepartmentName;
  final String filterDesignationName;

  const EmployeeMasterState({
    super.isLoading,
    super.stateType,
    required this.employeeMasterList,
    this.stateMap = const {},
    this.districtMap = const {},
    required this.stateList,
    required this.districtList,
    required this.cityList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.filterDepartmentName,
    required this.filterDesignationName,
  });

  factory EmployeeMasterState.initial() => EmployeeMasterState(
    employeeMasterList: [],
    stateMap: {},
    districtMap: {},
    stateList: [],
    districtList: [],
    cityList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    filterDepartmentName: "",
    filterDesignationName: "",
    isLoading: true,
  );

  EmployeeMasterState copyWith({
    bool? isLoading,
    StateType? stateType,
    String? errorMessage,
    List<UserModel>? employeeMasterList,
    bool? isAllSelected,
    Map<int, List<CityModel>>? stateMap,
    Map<int, List<CityModel>>? districtMap,
    List<Map<String, dynamic>>? stateList,
    List<Map<String, dynamic>>? districtList,
    List<Map<String, dynamic>>? cityList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
    String? filterDepartmentName,
    String? filterDesignationName,
  }) {
    return EmployeeMasterState(
      isLoading: isLoading ?? this.isLoading,
      stateType: stateType ?? this.stateType,
      employeeMasterList: employeeMasterList ?? this.employeeMasterList,
      stateMap: stateMap ?? this.stateMap,
      districtMap: districtMap ?? this.districtMap,
      stateList: stateList ?? this.stateList,
      districtList: districtList ?? this.districtList,
      cityList: cityList ?? this.cityList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterDepartmentName: filterDepartmentName ?? this.filterDepartmentName,
      filterDesignationName:
      filterDesignationName ?? this.filterDesignationName,
    );
  }

  @override
  List<Object?> get props => [
    employeeMasterList,
    stateMap,
    districtMap,
    stateList,
    districtList,
    cityList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
    filterDepartmentName,
    filterDesignationName,
  ];

}
