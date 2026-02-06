part of 'dashboard_cubit.dart';

final class DashboardState extends BaseState {
  final DashboardModel? data;
  final List<DashboardModel> dashboardModelList;
  const DashboardState({
    super.isLoading,
    this.data,
    required this.dashboardModelList,
  });
  factory DashboardState.initial() =>
      DashboardState(dashboardModelList: [], isLoading: true);
  DashboardState copyWith({
    bool? isLoading,
    int? totalNumberOfRecord,
    int? currentPage,
    DashboardModel? data,
    List<DashboardModel>? dashboardModelList,
    int? currentTabIndex,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      dashboardModelList: dashboardModelList ?? this.dashboardModelList,
    );
  }

  @override
  List<Object?> get props => [isLoading, dashboardModelList, data];
}
