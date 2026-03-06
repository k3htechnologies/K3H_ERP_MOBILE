import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/setting_dashboard/data/datasource/setting_dashbaord.datasource.dart';
import 'package:k3h_erp_app/features/masters/setting_dashboard/data/repository/setting_dashbaord.repository.dart';
import 'package:k3h_erp_app/features/masters/setting_dashboard/presentation/cubit/setting_dashboard_cubit.dart';

void registerSettingDashboardDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<SettingDashbaordDatasource>(
    SettingDashboardDatasourceImpl(),
  );
  serviceLocator.registerSingleton<SettingDashbaordRepository>(
    SettingDashbaordRepositoryImpl(
      settingDashbaordDatasource: serviceLocator<SettingDashbaordDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<SettingDashboardCubit>(
    SettingDashboardCubit(),
  );
}
