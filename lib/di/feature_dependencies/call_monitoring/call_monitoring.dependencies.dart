import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/core/services/call_monitoring_service.dart';
import 'package:k3h_erp_app/features/call_monitoring/data/datasource/call_monitoring.datasource.dart';
import 'package:k3h_erp_app/features/call_monitoring/data/repository/call_monitoring.repository.dart';
import 'package:k3h_erp_app/features/call_monitoring/presentation/cubit/call_monitoring_cubit.dart';

void registerCallMonitoringDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<CallMonitoringDatasource>(
    CallMonitoringDatasourceImpl(),
  );

  serviceLocator.registerSingleton<CallMonitoringRepository>(
    CallMonitoringRepositoryImpl(
      callMonitoringDatasource: serviceLocator<CallMonitoringDatasource>(),
    ),
  );

  serviceLocator.registerSingleton<CallMonitoringCubit>(CallMonitoringCubit());

  final callMonitoringService = CallMonitoringService.instance;

  // IMPORTANT: Initialize repository
  callMonitoringService.initializeRepository(
    repository: serviceLocator<CallMonitoringRepository>(),
  );

  serviceLocator.registerSingleton<CallMonitoringService>(
    callMonitoringService,
  );
}
