part of 'sales_dashboard_cubit.dart';

final class SalesDashboardState extends BaseState {
  final SalesDashboardModel? salesData;
  final List<SalesDashboardModel> salesDashboardList;
  final List<SalesDashboardModel> salesDashboardListForFilter;
  final int currentTabIndex;
  final String filterType;
  final DateTime? fromDate;
  final DateTime? toDate;
  const SalesDashboardState({
    super.isLoading,
    this.salesData,
    required this.salesDashboardList,
    required this.salesDashboardListForFilter,
    required this.currentTabIndex,
    required this.filterType,
    this.fromDate,
    this.toDate,
  });

  factory SalesDashboardState.initial() => SalesDashboardState(
    isLoading: true,
    salesDashboardList: [],
    salesDashboardListForFilter: [],
    currentTabIndex: 0,
    filterType: "TODAY",
  );

  SalesDashboardState copyWith({
    bool? isLoading,
    int? totalNumberOfRecord,
    int? currentPage,
    SalesDashboardModel? salesData,
    List<SalesDashboardModel>? salesDashboardList,
    List<SalesDashboardModel>? salesDashboardListForFilter,
    int? currentTabIndex,
    String? filterType,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return SalesDashboardState(
      isLoading: isLoading ?? this.isLoading,
      salesData: salesData ?? this.salesData,
      salesDashboardList: salesDashboardList ?? this.salesDashboardList,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      salesDashboardListForFilter:
          salesDashboardListForFilter ?? this.salesDashboardListForFilter,
      filterType: filterType ?? this.filterType,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    salesData,
    salesDashboardList,
    currentTabIndex,
    salesDashboardListForFilter,
    filterType,
    fromDate,
  ];
}
