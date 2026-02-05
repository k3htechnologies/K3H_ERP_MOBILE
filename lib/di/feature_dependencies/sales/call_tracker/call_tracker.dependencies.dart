import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/core/services/app_call_tracker_service.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/data/datasource/call_tracker.datasource.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/data/repository/call_tracker.repository.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/presentation/cubit/call_tracker_cubit.dart';

void registerCallTrackerDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<AppCallTrackerService>(
    AppCallTrackerService(),
  );
  serviceLocator.registerSingleton<CallTrackerDataSource>(
    CallTrackerDataSourceImpl(),
  );
  serviceLocator.registerSingleton<CallTrackerRepository>(
    CallTrackerRepositoryImpl(
      callTrackerDataSource: serviceLocator<CallTrackerDataSource>(),
    ),
  );

  //<---- CUBIT ---->
  serviceLocator.registerSingleton<CallTrackerCubit>(CallTrackerCubit());
}
