import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/legal/dashboard/data/datasource/litigation_dashboard.datatsource.dart';
import 'package:k3h_erp_app/features/legal/dashboard/data/repository/litigation_dashboard.repository.dart';
import 'package:k3h_erp_app/features/legal/dashboard/presentation/cubit/litigation_dashboard_cubit.dart';

void registerLitigationDashboardDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<LitigationDashboardDatasource>(
    LitigationDashboardDatasourceImpl(),
  );
  serviceLocator.registerSingleton<LitigationDashboardRepository>(
    LitigationDashboardRepositoryImpl(
      litigationDashboardDatasource:
          serviceLocator<LitigationDashboardDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<LitigationDashboardCubit>(
    LitigationDashboardCubit(),
  );
}
