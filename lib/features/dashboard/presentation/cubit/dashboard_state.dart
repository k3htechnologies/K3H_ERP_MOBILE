part of 'dashboard_cubit.dart';

final class DashboardState extends BaseState {
  final DashboardModel? data;
  final UserDashboardModel? userData;
  final List<DashboardModel> dashboardModelList;
  final List<UserDashboardModel> userDashboardModelList;
  final String searchEmployee;
  final List<UserModel>? employeeByProject;
  final int currentTabIndex;
  const DashboardState({
    super.isLoading,
    this.data,
    this.userData,
    required this.dashboardModelList,
    required this.userDashboardModelList,
    required this.searchEmployee,
    required this.employeeByProject,
    this.currentTabIndex = 0,
  });
  factory DashboardState.initial() => DashboardState(
    dashboardModelList: [],
    isLoading: true,
    userDashboardModelList: [],
    employeeByProject: [],
    searchEmployee: "",
    currentTabIndex: 0,
  );
  DashboardState copyWith({
    bool? isLoading,
    DashboardModel? data,
    UserDashboardModel? userData,
    List<DashboardModel>? dashboardModelList,
    List<UserDashboardModel>? userDashboardModelList,
    String? searchEmployee,
    List<UserModel>? employeeByProject,
    int? currentTabIndex,
    bool todayHasPunchIn = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      userData: userData ?? this.userData,
      dashboardModelList: dashboardModelList ?? this.dashboardModelList,
      userDashboardModelList:
          userDashboardModelList ?? this.userDashboardModelList,
      searchEmployee: searchEmployee ?? this.searchEmployee,
      employeeByProject: employeeByProject ?? this.employeeByProject,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    dashboardModelList,
    data,
    userData,
    userDashboardModelList,
    searchEmployee,
    employeeByProject,
    currentTabIndex,
  ];
}
