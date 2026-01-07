part of 'project_master_cubit.dart';

class ProjectMasterState extends BaseState {
  final List<ProjectModel> projectList;
  final List<ModulesWorkflowApprovalModel> moduleWorkflowApprovalList;
  // PROJECT DETAILS SCREEN
  final List<UserModel> employeeByProject;
  final List<BankDetailsModel> bankByProject;
  final List<CompanyModel> companyByProject;

  // ACCESS MODULE SCREEN
  final List<ModuleModel> modulesPermissionsList;

  final int totalNumberOfRecord;
  final int totalNumberOfRecordEmployee;
  final int totalNumberOfRecordCompany;
  final int currentPage;
  final int currentPageEmployee;
  final int currentPageCompany;
  final int currentPageBank;
  final int pageSize;
  final String searchText;
  final bool isAllSelected;
  const ProjectMasterState({
    required this.projectList,
    required this.moduleWorkflowApprovalList,
    required this.companyByProject,
    required this.bankByProject,
    required this.employeeByProject,
    required this.modulesPermissionsList,
    super.stateType,
    required this.totalNumberOfRecord,
    required this.totalNumberOfRecordEmployee,
    required this.totalNumberOfRecordCompany,
    required this.currentPage,
    required this.currentPageEmployee,
    required this.currentPageCompany,
    required this.currentPageBank,
    required this.pageSize,
    required this.searchText,
    this.isAllSelected = false,
    super.isLoading,
  });

  factory ProjectMasterState.initial() => ProjectMasterState(
    projectList: [],
    moduleWorkflowApprovalList: [],
    employeeByProject: [],
    bankByProject: [],
    companyByProject: [],
    modulesPermissionsList: [],
    totalNumberOfRecord: 0,
    totalNumberOfRecordEmployee: 0,
    totalNumberOfRecordCompany: 0,
    currentPage: 1,
    currentPageEmployee: 1,
    currentPageCompany: 1,
    currentPageBank: 1,
    pageSize: 10,
    searchText: "",
    isLoading: true,
  );

  ProjectMasterState copyWith({
    List<ProjectModel>? projectList,
    List<ModulesWorkflowApprovalModel>? moduleWorkflowApprovalList,
    List<CompanyModel>? companyByProject,
    List<BankDetailsModel>? bankByProject,
    List<UserModel>? employeeByProject,
    List<ModuleModel>? modulesPermissionsList,
    StateType? stateType,
    String? errorMessage,
    bool? isLoading,
    bool? isAllSelected,
    int? totalNumberOfRecord,
    int? totalNumberOfRecordEmployee,
    int? totalNumberOfRecordCompany,
    int? currentPage,
    int? currentPageEmployee,
    int? currentPageCompany,
    int? currentPageBank,
    int? pageSize,
    String? searchText,
  }) {
    return ProjectMasterState(
      projectList: projectList ?? this.projectList,
      moduleWorkflowApprovalList:
      moduleWorkflowApprovalList ?? this.moduleWorkflowApprovalList,
      companyByProject: companyByProject ?? this.companyByProject,
      bankByProject: bankByProject ?? this.bankByProject,
      employeeByProject: employeeByProject ?? this.employeeByProject,
      modulesPermissionsList:
      modulesPermissionsList ?? this.modulesPermissionsList,
      stateType: stateType ?? this.stateType,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      totalNumberOfRecordEmployee:
      totalNumberOfRecordEmployee ?? this.totalNumberOfRecordEmployee,
      isAllSelected: isAllSelected ?? this.isAllSelected,
      totalNumberOfRecordCompany:
      totalNumberOfRecordCompany ?? this.totalNumberOfRecordCompany,
      currentPage: currentPage ?? this.currentPage,
      currentPageEmployee: currentPageEmployee ?? this.currentPageEmployee,
      currentPageCompany: currentPageCompany ?? this.currentPageCompany,
      currentPageBank: currentPageBank ?? this.currentPageBank,
      pageSize: pageSize ?? this.pageSize,
      searchText: searchText ?? this.searchText,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isAllSelected,
    projectList,
    moduleWorkflowApprovalList,
    companyByProject,
    bankByProject,
    employeeByProject,
    modulesPermissionsList,
    stateType,
    totalNumberOfRecord,
    totalNumberOfRecordEmployee,
    totalNumberOfRecordCompany,
    currentPage,
    currentPageEmployee,
    currentPageCompany,
    currentPageBank,
    pageSize,
    searchText,
  ];
}
