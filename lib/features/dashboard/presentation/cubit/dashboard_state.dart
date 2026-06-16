part of 'dashboard_cubit.dart';

final class DashboardState extends BaseState {
  final AttendanceModel? data;
  final UserDashboardModel? userData;
  final List<AttendanceModel> dashboardModelList;
  final List<UserDashboardModel> userDashboardModelList;
  final String searchEmployee;
  final List<UserModel>? employeeByProject;
  final int currentTabIndex;
  final int currentUnitPage;
  final int unitTotalRecords;
  const DashboardState({
    super.isLoading,
    this.data,
    this.userData,
    required this.dashboardModelList,
    required this.userDashboardModelList,
    required this.searchEmployee,
    required this.employeeByProject,
    this.currentTabIndex = 0,
    this.currentUnitPage = 0,
    this.unitTotalRecords = 0,
  });
  factory DashboardState.initial() => DashboardState(
    dashboardModelList: [],
    isLoading: true,
    userDashboardModelList: [],
    employeeByProject: [],
    searchEmployee: "",
    currentTabIndex: 0,
    currentUnitPage: 0,
    unitTotalRecords: 0,
  );
  DashboardState copyWith({
    bool? isLoading,
    AttendanceModel? data,
    UserDashboardModel? userData,
    List<AttendanceModel>? dashboardModelList,
    List<UserDashboardModel>? userDashboardModelList,
    String? searchEmployee,
    List<UserModel>? employeeByProject,
    int? currentTabIndex,
    bool todayHasPunchIn = false,
    int? currentUnitPage,
    int? unitTotalRecords,
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
      currentUnitPage: currentUnitPage ?? this.currentUnitPage,
      unitTotalRecords: unitTotalRecords ?? this.unitTotalRecords,
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
    currentUnitPage,
    unitTotalRecords,
  ];
}
