import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/datasource/project_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';

void registerProjectMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<ProjectMasterDatasource>(
    ProjectMasterDatasourceImpl(),
  );

  serviceLocator.registerSingleton<ProjectMasterRepository>(
    ProjectMasterRepositoryImpl(
      projectMasterDatasource: serviceLocator<ProjectMasterDatasource>(),
    ),
  );

  //- CUBITS -
  /* serviceLocator.registerSingleton<CompanyMasterCubit>(CompanyMasterCubit());
  serviceLocator.registerSingleton<CompanyMasterAddCubit>(
    CompanyMasterAddCubit(),
  );*/
}
