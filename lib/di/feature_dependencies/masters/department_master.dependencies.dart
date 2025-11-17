import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/datasource/department_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/repository/department_master.repository.dart';
import 'package:k3h_erp_app/features/masters/department_master/presentation/cubit/department_master_cubit.dart';

void registerDepartmentMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<DepartmentMasterDatasource>(
    DepartmentMasterDataSourceImpl(),
  );
  serviceLocator.registerSingleton<DepartmentMasterRepository>(
    DepartmentMasterRepositoryImpl(
      departmentMasterDatasource: serviceLocator<DepartmentMasterDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<DepartmentMasterCubit>(
    DepartmentMasterCubit(),
  );
}