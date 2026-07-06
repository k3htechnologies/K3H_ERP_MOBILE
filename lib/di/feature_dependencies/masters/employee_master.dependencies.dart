import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/datasource/employee_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/cubit/employee_master_cubit.dart';

void registerEmployeeMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<EmployeeMasterDataSource>(
    EmployeeMasterDataSourceImpl(),
  );

  serviceLocator.registerSingleton<EmployeeMasterRepository>(
    EmployeeMasterRepositoryImp(serviceLocator<EmployeeMasterDataSource>()),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<EmployeeMasterCubit>(EmployeeMasterCubit());
}
