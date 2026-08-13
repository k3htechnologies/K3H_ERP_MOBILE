import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/business_development/dashboard/data/datasource/redevelopment_dashborad.datasource.dart';
import 'package:k3h_erp_app/features/business_development/dashboard/data/repository/redevelopment.dashboard_repository.dart';

void registerRedevelopmentDashboardDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<RedevelopmentDashboradDatasource>(
    RedevelopmentDashboradDatasourceImpl(),
  );
  serviceLocator.registerSingleton<RedevelopmentDashboardRepository>(
    RedevelopmentDashboardRepositoryImpl(
      redevelopmentDashboradDatasource:
          serviceLocator<RedevelopmentDashboradDatasource>(),
    ),
  );
}
