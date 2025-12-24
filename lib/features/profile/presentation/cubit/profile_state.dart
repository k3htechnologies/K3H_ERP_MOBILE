part of 'profile_cubit.dart';

class ProfileState extends BaseState {
  final UserModel? user;
  final ProjectModel? selectedProject;
  final List<ProjectModel> projectList;
  final bool isLoadingProjects;
  final int currentTabIndex;

  const ProfileState({
    super.isLoading,
    this.user,
    this.selectedProject,
    required this.projectList,
    required this.isLoadingProjects,
    required this.currentTabIndex,
  });

  factory ProfileState.initial() => const ProfileState(
        projectList: [],
        isLoadingProjects: false,
        currentTabIndex: 0,
        isLoading: false,
      );

  ProfileState copyWith({
    bool? isLoading,
    UserModel? user,
    ProjectModel? selectedProject,
    List<ProjectModel>? projectList,
    bool? isLoadingProjects,
    int? currentTabIndex,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      selectedProject: selectedProject ?? this.selectedProject,
      projectList: projectList ?? this.projectList,
      isLoadingProjects: isLoadingProjects ?? this.isLoadingProjects,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
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
      ];
}

