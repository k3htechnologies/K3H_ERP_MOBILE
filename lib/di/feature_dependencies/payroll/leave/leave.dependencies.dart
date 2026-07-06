import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/payroll/leave/data/datasource/leave.datasource.dart';
import 'package:k3h_erp_app/features/payroll/leave/data/repository/leave.repository.dart';
import 'package:k3h_erp_app/features/payroll/leave/presentation/cubit/leave_cubit.dart';

void registerLeaveDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<LeaveDatasource>(
    LeaveDatasourceDataSourceImpl(),
  );
  serviceLocator.registerSingleton<LeaveRepository>(
    LeaveRepositoryImpl(leaveDatasource: serviceLocator<LeaveDatasource>()),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<LeaveCubit>(LeaveCubit());
}
