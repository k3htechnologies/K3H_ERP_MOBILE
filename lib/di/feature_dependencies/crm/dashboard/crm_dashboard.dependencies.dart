import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/crm/dashboard/data/datasource/crm_dashboard.datasource.dart';
import 'package:k3h_erp_app/features/crm/dashboard/data/repository/crm_dashboard.repository.dart';
import 'package:k3h_erp_app/features/crm/dashboard/presentation/cubit/crm_dashboard_cubit.dart';

void registerCrmDashboardDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<CrmDashboardDatasource>(
    CrmDashboardDatasourceImpl(),
  );
  serviceLocator.registerSingleton<CrmDashboardRepository>(
    CrmDashboardRepositoryImpl(
      crmDashboardDatasource: serviceLocator<CrmDashboardDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<CrmDashboardCubit>(CrmDashboardCubit());
}
