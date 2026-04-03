part of 'project_master_cubit.dart';

class ProjectMasterState extends BaseState {
  final bool isEmployeeLoading;
  final List<ProjectModel> projectList;
  final List<ModulesWorkflowApprovalModel> moduleWorkflowApprovalList;

  // PROJECT DETAILS SCREEN
  final List<UserModel> employeeByProject;
  final List<UserModel> employeeByProjectOriginal;
  final List<BankDetailsModel> bankByProject;
  final List<CompanyModel> companyByProject;

  final String currentSortColumn;
  final String currentSortDirection;

  // ACCESS MODULE SCREEN
  final List<ModuleModel> modulesPermissionsList;

  final int totalNumberOfRecord;
  final int totalNumberOfRecordEmployee;
  final int totalNumberOfRecordCompany;

  // NEW MASTER PAGINATION
  final int totalNumberOfRecordCompanyMaster;
  final int totalNumberOfRecordEmployeeMaster;

  final int currentPage;
  final int currentPageEmployee;
  final int currentPageCompany;
  final int currentPageBank;

  // NEW MASTER PAGINATION
  final int currentPageCompanyMaster;
  final int currentPageEmployeeMaster;

  final int pageSize;
  final String searchText;
  final bool isAllSelected;

  final String filterProjectLocation;
  final String filterCTSNumber;

  const ProjectMasterState({
    required this.isEmployeeLoading,
    required this.projectList,
    required this.moduleWorkflowApprovalList,
    required this.companyByProject,
    required this.bankByProject,
    required this.employeeByProject,
    required this.employeeByProjectOriginal,
    required this.modulesPermissionsList,
    super.stateType,

    required this.totalNumberOfRecord,
    required this.totalNumberOfRecordEmployee,
    required this.totalNumberOfRecordCompany,

    required this.totalNumberOfRecordCompanyMaster,
    required this.totalNumberOfRecordEmployeeMaster,

    required this.currentPage,
    required this.currentPageEmployee,
    required this.currentPageCompany,
    required this.currentPageBank,

    required this.currentPageCompanyMaster,
    required this.currentPageEmployeeMaster,

    required this.pageSize,
    required this.searchText,
    required this.filterProjectLocation,
    required this.filterCTSNumber,

    required this.currentSortColumn,
    required this.currentSortDirection,

    this.isAllSelected = false,
    super.isLoading,
  });

  factory ProjectMasterState.initial() => ProjectMasterState(
    isEmployeeLoading: false,
    projectList: [],
    moduleWorkflowApprovalList: [],
    employeeByProject: [],
    employeeByProjectOriginal: [],
    bankByProject: [],
    companyByProject: [],
    modulesPermissionsList: [],

    totalNumberOfRecord: 0,
    totalNumberOfRecordEmployee: 0,
    totalNumberOfRecordCompany: 0,

    totalNumberOfRecordCompanyMaster: 0,
    totalNumberOfRecordEmployeeMaster: 0,

    currentPage: 1,
    currentPageEmployee: 1,
    currentPageCompany: 1,
    currentPageBank: 1,

    currentPageCompanyMaster: 1,
    currentPageEmployeeMaster: 1,

    pageSize: 10,
    searchText: "",
    filterCTSNumber: '',
    filterProjectLocation: '',

    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",

    isLoading: true,
  );

  ProjectMasterState copyWith({
    bool? isEmployeeLoading,
    List<ProjectModel>? projectList,
    List<ModulesWorkflowApprovalModel>? moduleWorkflowApprovalList,
    List<CompanyModel>? companyByProject,
    List<BankDetailsModel>? bankByProject,
    List<UserModel>? employeeByProject,
    List<UserModel>? employeeByProjectOriginal,
    List<ModuleModel>? modulesPermissionsList,

    String? filterProjectLocation,
    String? filterCTSNumber,

    StateType? stateType,
    bool? isLoading,
    bool? isAllSelected,

    int? totalNumberOfRecord,
    int? totalNumberOfRecordEmployee,
    int? totalNumberOfRecordCompany,

    int? totalNumberOfRecordCompanyMaster,
    int? totalNumberOfRecordEmployeeMaster,

    int? currentPage,
    int? currentPageEmployee,
    int? currentPageCompany,
    int? currentPageBank,

    int? currentPageCompanyMaster,
    int? currentPageEmployeeMaster,

    int? pageSize,
    String? searchText,

    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return ProjectMasterState(
      isEmployeeLoading: isEmployeeLoading ?? this.isEmployeeLoading,
      projectList: projectList ?? this.projectList,
      moduleWorkflowApprovalList:
      moduleWorkflowApprovalList ?? this.moduleWorkflowApprovalList,
      companyByProject: companyByProject ?? this.companyByProject,
      bankByProject: bankByProject ?? this.bankByProject,
      employeeByProject: employeeByProject ?? this.employeeByProject,
      employeeByProjectOriginal:
      employeeByProjectOriginal ?? this.employeeByProjectOriginal,
      modulesPermissionsList:
      modulesPermissionsList ?? this.modulesPermissionsList,

      stateType: stateType ?? this.stateType,

      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      totalNumberOfRecordEmployee:
      totalNumberOfRecordEmployee ?? this.totalNumberOfRecordEmployee,
      totalNumberOfRecordCompany:
      totalNumberOfRecordCompany ?? this.totalNumberOfRecordCompany,

      totalNumberOfRecordCompanyMaster:
      totalNumberOfRecordCompanyMaster ?? this.totalNumberOfRecordCompanyMaster,
      totalNumberOfRecordEmployeeMaster:
      totalNumberOfRecordEmployeeMaster ?? this.totalNumberOfRecordEmployeeMaster,

      currentPage: currentPage ?? this.currentPage,
      currentPageEmployee: currentPageEmployee ?? this.currentPageEmployee,
      currentPageCompany: currentPageCompany ?? this.currentPageCompany,
      currentPageBank: currentPageBank ?? this.currentPageBank,

      currentPageCompanyMaster:
      currentPageCompanyMaster ?? this.currentPageCompanyMaster,
      currentPageEmployeeMaster:
      currentPageEmployeeMaster ?? this.currentPageEmployeeMaster,

      pageSize: pageSize ?? this.pageSize,
      searchText: searchText ?? this.searchText,

      isLoading: isLoading ?? this.isLoading,
      isAllSelected: isAllSelected ?? this.isAllSelected,

      filterCTSNumber: filterCTSNumber ?? this.filterCTSNumber,
      filterProjectLocation:
      filterProjectLocation ?? this.filterProjectLocation,

      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isEmployeeLoading,
    isLoading,
    isAllSelected,
    projectList,
    moduleWorkflowApprovalList,
    companyByProject,
    bankByProject,
    employeeByProject,
    employeeByProjectOriginal,
    modulesPermissionsList,

    totalNumberOfRecord,
    totalNumberOfRecordEmployee,
    totalNumberOfRecordCompany,

    totalNumberOfRecordCompanyMaster,
    totalNumberOfRecordEmployeeMaster,

    currentPage,
    currentPageEmployee,
    currentPageCompany,
    currentPageBank,

    currentPageCompanyMaster,
    currentPageEmployeeMaster,

    pageSize,
    searchText,

    currentSortColumn,
    currentSortDirection,

    filterCTSNumber,
    filterProjectLocation,
  ];
}