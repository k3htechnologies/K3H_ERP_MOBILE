part of 'dashboard_cubit.dart';

final class DashboardState extends BaseState {
  final DashboardModel? data;
  final UserDashboardModel? userData;
  final List<DashboardModel> dashboardModelList;
  final List<UserDashboardModel> userDashboardModelList;
  const DashboardState({
    super.isLoading,
    this.data,
    this.userData,
    required this.dashboardModelList,
    required this.userDashboardModelList,
  });
  factory DashboardState.initial() => DashboardState(
    dashboardModelList: [],
    isLoading: true,
    userDashboardModelList: [],
  );
  DashboardState copyWith({
    bool? isLoading,
    int? totalNumberOfRecord,
    int? currentPage,
    DashboardModel? data,
    UserDashboardModel? userData,
    List<DashboardModel>? dashboardModelList,
    List<UserDashboardModel>? userDashboardModelList,
    int? currentTabIndex,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      userData: userData ?? this.userData,
      dashboardModelList: dashboardModelList ?? this.dashboardModelList,
      userDashboardModelList:
          userDashboardModelList ?? this.userDashboardModelList,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    dashboardModelList,
    data,
    userData,
    userDashboardModelList,
  ];
}
