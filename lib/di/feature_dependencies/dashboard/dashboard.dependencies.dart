import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/dashboard/data/datasource/dashboard.datasource.dart';
import 'package:k3h_erp_app/features/dashboard/data/repository/dashboard.repository.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';

void registerDashboardDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<DashboardDatasource>(
    DashboardDatasourceImpl(),
  );
  serviceLocator.registerSingleton<DashboardRepository>(
    DashboardRepositoryImpl(
      dashboardDatasource: serviceLocator<DashboardDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<DashboardCubit>(DashboardCubit());
}
