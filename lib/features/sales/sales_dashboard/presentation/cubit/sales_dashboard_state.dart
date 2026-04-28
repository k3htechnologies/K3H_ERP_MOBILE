part of 'sales_dashboard_cubit.dart';

final class SalesDashboardState extends BaseState {
  final SalesDashboardModel? salesData;
  final List<SalesDashboardModel> salesDashboardList;
  final List<SalesDashboardModel> salesDashboardListForFilter;
  final int currentTabIndex;
  const SalesDashboardState({
    super.isLoading,
    this.salesData,
    required this.salesDashboardList,
    required this.salesDashboardListForFilter,
    required this.currentTabIndex,
  });

  factory SalesDashboardState.initial() => SalesDashboardState(
    isLoading: true,
    salesDashboardList: [],
    salesDashboardListForFilter: [],
    currentTabIndex: 0,
  );

  SalesDashboardState copyWith({
    bool? isLoading,
    int? totalNumberOfRecord,
    int? currentPage,
    SalesDashboardModel? salesData,
    List<SalesDashboardModel>? salesDashboardList,
    List<SalesDashboardModel>? salesDashboardListForFilter,
    int? currentTabIndex,
  }) {
    return SalesDashboardState(
      isLoading: isLoading ?? this.isLoading,
      salesData: salesData ?? this.salesData,
      salesDashboardList: salesDashboardList ?? this.salesDashboardList,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      salesDashboardListForFilter:
          salesDashboardListForFilter ?? this.salesDashboardListForFilter,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    salesData,
    salesDashboardList,
    currentTabIndex,
    salesDashboardListForFilter,
  ];
}
