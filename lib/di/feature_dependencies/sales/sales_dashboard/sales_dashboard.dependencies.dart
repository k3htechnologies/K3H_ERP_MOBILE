import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/data/datasource/sales.dashboard.datasource.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/data/repository/sales.dashboard.repository.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/cubit/sales_dashboard_cubit.dart';

void registerSalesDashboardDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<SalesDashboardDatasource>(
    SalesDashboardDatasourceImpl(),
  );
  serviceLocator.registerSingleton<SalesDashboardRepository>(
    SalesDashboardRepositoryImpl(
      salesDashboardDatasource: serviceLocator<SalesDashboardDatasource>(),
    ),
  );

  //<---- CUBIT
  serviceLocator.registerSingleton<SalesDashboardCubit>(SalesDashboardCubit());
}
