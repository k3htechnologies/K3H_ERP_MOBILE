import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/data/datasource/visitor_management_dashboard.datasource.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/data/repository/visitor_management_dashboard.repository.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/presentation/cubit/visitor_management_dashboard_cubit.dart';

void registerVisitorManagementDashboardDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<VisitorManagementDashboardDatasource>(
    VisitorManagementDashboardDatasourceImpl(),
  );
  serviceLocator.registerSingleton<VisitorManagementDashboardRepository>(
    VisitorManagementDashboardRepositoryImpl(
      visitorManagementDashboardDatasource:
          serviceLocator<VisitorManagementDashboardDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<VisitorManagementDashboardCubit>(
    VisitorManagementDashboardCubit(),
  );
}
