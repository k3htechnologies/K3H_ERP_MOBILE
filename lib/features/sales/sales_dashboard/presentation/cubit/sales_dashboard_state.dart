part of 'sales_dashboard_cubit.dart';

final class SalesDashboardState extends BaseState {
  final SalesDashboardModel? salesData;
  final List<SalesDashboardModel> salesDashboardList;
  const SalesDashboardState({
    super.isLoading,
    this.salesData,
    required this.salesDashboardList,
  });

  factory SalesDashboardState.initial() =>
      SalesDashboardState(isLoading: true, salesDashboardList: []);

  SalesDashboardState copyWith({
    bool? isLoading,
    int? totalNumberOfRecord,
    int? currentPage,
    SalesDashboardModel? salesData,
    List<SalesDashboardModel>? salesDashboardList,
  }) {
    return SalesDashboardState(
      isLoading: isLoading ?? this.isLoading,
      salesData: salesData ?? this.salesData,
      salesDashboardList: salesDashboardList ?? this.salesDashboardList,
    );
  }

  @override
  List<Object?> get props => [isLoading, salesData, salesDashboardList];
}
