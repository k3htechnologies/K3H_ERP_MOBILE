part of 'employee_master_cubit.dart';

class EmployeeMasterState extends BaseState {
  final List<UserModel> employeeMasterList;
  final List<EmployeeDocumentModel> employeeDocumentList;
  final List<DepartmentModel> departmentList;
  final List<CompanyModel> companyNameList;
  final List<DesignationMasterModel> designationList;
  final List<AssetMappingModel> assetMappingList;
  final List<ShiftMappingModel> shiftManagementList;
  final List<WeekOffMappingModel> weekOffMappingList;
  final Map<int, List<CityModel>> stateMap;
  final Map<int, List<CityModel>> districtMap;
  final List<Map<String, dynamic>> stateList;
  final List<Map<String, dynamic>> districtList;
  final List<Map<String, dynamic>> cityList;
  final int totalNumberOfRecord;
  final int departmentTotalCount;
  final int companyNameTotalCount;
  final int designationTotalCount;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterReportPersonName;
  final String filterCompanyName;
  final String filterBranchName;
  final String filterEmployeeCode;
  final String filterDepartmentName;
  final String filterDesignationName;
  final String filterMobileNumber;
  final DateTime? filterDOBFrom;
  final DateTime? filterDOBTo;
  final String filterIsProbation;
  final String filterIdCardIssue;
  final ProjectModel? selectedProject;
  final List<ProjectModel> projectList;
  final bool isLoadingProjects;
  final int currentTabIndex;

  const EmployeeMasterState({
    super.isLoading,
    super.stateType,
    required this.employeeMasterList,
    required this.employeeDocumentList,
    required this.departmentList,
    required this.companyNameList,
    required this.designationList,
    required this.assetMappingList,
    required this.shiftManagementList,
    required this.weekOffMappingList,
    this.stateMap = const {},
    this.districtMap = const {},
    required this.stateList,
    required this.districtList,
    required this.cityList,
    required this.totalNumberOfRecord,
    required this.departmentTotalCount,
    required this.companyNameTotalCount,
    required this.designationTotalCount,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.filterReportPersonName,
    required this.filterCompanyName,
    required this.filterBranchName,
    required this.filterEmployeeCode,
    required this.filterDepartmentName,
    required this.filterDesignationName,
    required this.filterMobileNumber,
    required this.filterDOBFrom,
    required this.filterDOBTo,
    required this.filterIsProbation,
    required this.filterIdCardIssue,
    this.selectedProject,
    required this.projectList,
    required this.isLoadingProjects,
    required this.currentTabIndex,
  });

  factory EmployeeMasterState.initial() => EmployeeMasterState(
    employeeMasterList: [],
    employeeDocumentList: [],
    departmentList: [],
    companyNameList: [],
    designationList: [],
    assetMappingList: [],
    shiftManagementList: [],
    weekOffMappingList: [],
    stateMap: {},
    districtMap: {},
    stateList: [],
    districtList: [],
    cityList: [],
    totalNumberOfRecord: 0,
    departmentTotalCount: 0,
    companyNameTotalCount: 0,
    designationTotalCount: 0,
    currentPage: 1,
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    filterReportPersonName: "",
    filterCompanyName: "",
    filterEmployeeCode: "",
    filterBranchName: "",
    filterDepartmentName: "",
    filterDesignationName: "",
    filterMobileNumber: "",
    filterDOBFrom: null,
    filterDOBTo: null,
    filterIsProbation: "",
    filterIdCardIssue: "",
    isLoading: true,
    selectedProject: null,
    projectList: [],
    isLoadingProjects: false,
    currentTabIndex: 0,
  );

  EmployeeMasterState copyWith({
    bool? isLoading,
    StateType? stateType,
    List<UserModel>? employeeMasterList,
    List<EmployeeDocumentModel>? employeeDocumentList,
    List<DepartmentModel>? departmentList,
    List<CompanyModel>? companyNameList,
    List<DesignationMasterModel>? designationList,
    List<AssetMappingModel>? assetMappingList,
    List<ShiftMappingModel>? shiftManagementList,
    List<WeekOffMappingModel>? weekOffMappingList,
    bool? isAllSelected,
    Map<int, List<CityModel>>? stateMap,
    Map<int, List<CityModel>>? districtMap,
    List<Map<String, dynamic>>? stateList,
    List<Map<String, dynamic>>? districtList,
    List<Map<String, dynamic>>? cityList,
    int? totalNumberOfRecord,
    int? departmentTotalCount,
    int? companyNameTotalCount,
    int? designationTotalCount,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
    String? filterReportPersonName,
    String? filterCompanyName,
    String? filterBranchName,
    String? filterEmployeeCode,
    String? filterDepartmentName,
    String? filterDesignationName,
    String? filterMobileNumber,
    DateTime? filterDOBFrom,
    DateTime? filterDOBTo,
    String? filterIsProbation,
    String? filterIdCardIssue,
    bool clearFilterDOBFrom = false,
    bool clearFilterDOBTo = false,
    ProjectModel? selectedProject,
    List<ProjectModel>? projectList,
    bool? isLoadingProjects,
    int? currentTabIndex,
  }) {
    return EmployeeMasterState(
      isLoading: isLoading ?? this.isLoading,
      stateType: stateType ?? this.stateType,
      employeeMasterList: employeeMasterList ?? this.employeeMasterList,
      employeeDocumentList: employeeDocumentList ?? this.employeeDocumentList,
      departmentList: departmentList ?? this.departmentList,
      companyNameList: companyNameList ?? this.companyNameList,
      designationList: designationList ?? this.designationList,
      assetMappingList: assetMappingList ?? this.assetMappingList,
      shiftManagementList: shiftManagementList ?? this.shiftManagementList,
      weekOffMappingList: weekOffMappingList ?? this.weekOffMappingList,
      stateMap: stateMap ?? this.stateMap,
      districtMap: districtMap ?? this.districtMap,
      stateList: stateList ?? this.stateList,
      districtList: districtList ?? this.districtList,
      cityList: cityList ?? this.cityList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      departmentTotalCount: departmentTotalCount ?? this.departmentTotalCount,
      companyNameTotalCount:
          companyNameTotalCount ?? this.companyNameTotalCount,
      designationTotalCount:
          designationTotalCount ?? this.designationTotalCount,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterReportPersonName:
          filterReportPersonName ?? this.filterReportPersonName,
      filterCompanyName: filterCompanyName ?? this.filterCompanyName,
      filterEmployeeCode: filterEmployeeCode ?? this.filterEmployeeCode,
      filterBranchName: filterBranchName ?? this.filterBranchName,
      filterDepartmentName: filterDepartmentName ?? this.filterDepartmentName,
      filterDesignationName:
          filterDesignationName ?? this.filterDesignationName,
      filterMobileNumber: filterMobileNumber ?? this.filterMobileNumber,
      filterDOBFrom:
          clearFilterDOBFrom ? null : (filterDOBFrom ?? this.filterDOBFrom),
      filterDOBTo: clearFilterDOBTo ? null : (filterDOBTo ?? this.filterDOBTo),
      filterIsProbation: filterIsProbation ?? this.filterIsProbation,
      filterIdCardIssue: filterIdCardIssue ?? this.filterIdCardIssue,
      selectedProject: selectedProject ?? this.selectedProject,
      projectList: projectList ?? this.projectList,
      isLoadingProjects: isLoadingProjects ?? this.isLoadingProjects,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    stateType,
    employeeMasterList,
    employeeDocumentList,
    departmentList,
    companyNameList,
    designationList,
    assetMappingList,
    shiftManagementList,
    weekOffMappingList,
    stateMap,
    districtMap,
    stateList,
    districtList,
    cityList,
    totalNumberOfRecord,
    departmentTotalCount,
    companyNameTotalCount,
    designationTotalCount,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
    filterReportPersonName,
    filterCompanyName,
    filterEmployeeCode,
    filterBranchName,
    filterDepartmentName,
    filterDesignationName,
    filterMobileNumber,
    filterDOBFrom,
    filterDOBTo,
    filterIsProbation,
    filterIdCardIssue,
    selectedProject,
    projectList,
    isLoadingProjects,
    currentTabIndex,
  ];
}
