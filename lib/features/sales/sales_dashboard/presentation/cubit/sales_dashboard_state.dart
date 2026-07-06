part of 'sales_dashboard_cubit.dart';

final class SalesDashboardState extends BaseState {
  final List<SalesDashboardModel> salesDashboardList;
  final List<ProjectWiseSalesDashboardModel> projectWiseSalesDashboardList;

  const SalesDashboardState({
    super.isLoading,
    required this.salesDashboardList,
    required this.projectWiseSalesDashboardList,
  });

  factory SalesDashboardState.initial() => SalesDashboardState(
    isLoading: true,
    salesDashboardList: [],
    projectWiseSalesDashboardList: [],
  );

  SalesDashboardState copyWith({
    bool? isLoading,
    List<SalesDashboardModel>? salesDashboardList,
    List<ProjectWiseSalesDashboardModel>? projectWiseSalesDashboardList,
  }) {
    return SalesDashboardState(
      isLoading: isLoading ?? this.isLoading,
      salesDashboardList: salesDashboardList ?? this.salesDashboardList,
      projectWiseSalesDashboardList:
          projectWiseSalesDashboardList ?? this.projectWiseSalesDashboardList,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    salesDashboardList,
    projectWiseSalesDashboardList,
  ];
}
