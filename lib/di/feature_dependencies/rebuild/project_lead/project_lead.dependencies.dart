import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/data/datasource/project_lead.datasource.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/data/repository/project_lead.repository.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/presentation/cubit/project_lead_cubit.dart';

void registerProjectLeadDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<ProjectLeadDatasource>(
    ProjectLeadDatasourceImpl(),
  );
  serviceLocator.registerSingleton<ProjectLeadRepository>(
    ProjectLeadRepositoryImpl(
      projectLeadDatasource: serviceLocator<ProjectLeadDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<ProjectLeadCubit>(ProjectLeadCubit());
}
