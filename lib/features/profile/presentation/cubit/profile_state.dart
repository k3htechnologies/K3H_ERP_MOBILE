part of 'profile_cubit.dart';

class ProfileState extends BaseState {
  final UserModel? user;
  final ProjectModel? selectedProject;
  final List<ProjectModel> projectList;
  final bool isLoadingProjects;
  final int currentTabIndex;
  final List<EmployeeDocumentModel> employeeDocumentList;
  final List<AssetMappingModel> assetMappingList;
  final List<ShiftMappingModel> shiftManagementList;
  final List<WeekOffMappingModel> weekOffMappingList;
  final List<EmployeeEducationDetailsModel> employeeEducationDetailsList;
  final List<EmployeeExperienceDetailsModel> employeeExperienceDetailsList;
  final List<BranchAssociationModel> branchAssociationList;

  const ProfileState({
    super.isLoading,
    this.user,
    this.selectedProject,
    required this.projectList,
    required this.isLoadingProjects,
    required this.currentTabIndex,
    required this.employeeDocumentList,
    required this.assetMappingList,
    required this.shiftManagementList,
    required this.weekOffMappingList,
    required this.employeeEducationDetailsList,
    required this.employeeExperienceDetailsList,
    required this.branchAssociationList,
  });

  factory ProfileState.initial() => const ProfileState(
    projectList: [],
    isLoadingProjects: false,
    currentTabIndex: 0,
    isLoading: false,
    employeeDocumentList: [],
    assetMappingList: [],
    shiftManagementList: [],
    weekOffMappingList: [],
    employeeEducationDetailsList: [],
    employeeExperienceDetailsList: [],
    branchAssociationList: [],
  );

  ProfileState copyWith({
    bool? isLoading,
    UserModel? user,
    ProjectModel? selectedProject,
    List<ProjectModel>? projectList,
    bool? isLoadingProjects,
    int? currentTabIndex,
    List<EmployeeDocumentModel>? employeeDocumentList,
    List<AssetMappingModel>? assetMappingList,
    List<ShiftMappingModel>? shiftManagementList,
    List<WeekOffMappingModel>? weekOffMappingList,
    List<EmployeeEducationDetailsModel>? employeeEducationDetailsList,
    List<EmployeeExperienceDetailsModel>? employeeExperienceDetailsList,
    List<BranchAssociationModel>? branchAssociationList,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      selectedProject: selectedProject ?? this.selectedProject,
      projectList: projectList ?? this.projectList,
      isLoadingProjects: isLoadingProjects ?? this.isLoadingProjects,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      employeeDocumentList: employeeDocumentList ?? this.employeeDocumentList,
      assetMappingList: assetMappingList ?? this.assetMappingList,
      shiftManagementList: shiftManagementList ?? this.shiftManagementList,
      weekOffMappingList: weekOffMappingList ?? this.weekOffMappingList,
      employeeEducationDetailsList: employeeEducationDetailsList ?? this.employeeEducationDetailsList,
      employeeExperienceDetailsList: employeeExperienceDetailsList ?? this.employeeExperienceDetailsList,
      branchAssociationList: branchAssociationList ?? this.branchAssociationList,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    user,
    selectedProject,
    projectList,
    isLoadingProjects,
    currentTabIndex,
    employeeDocumentList,
    assetMappingList,
    shiftManagementList,
    weekOffMappingList,
    employeeEducationDetailsList,
    employeeExperienceDetailsList,
    branchAssociationList,
  ];
}
