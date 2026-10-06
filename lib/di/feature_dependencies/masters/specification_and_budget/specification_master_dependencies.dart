import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/specification_and_budget/specification_master/data/datasource/specification_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/specification_and_budget/specification_master/data/repository/specification_master.repository.dart';
import 'package:k3h_erp_app/features/masters/specification_and_budget/specification_master/presentation/cubit/specification_master_cubit.dart';

void registerSpecificationMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<SpecificationMasterDatasource>(
    SpecificationMasterDatasourceImpl(),
  );

  serviceLocator.registerSingleton<SpecificationMasterRepository>(
    SpecificationMasterRepositoryImpl(
      specificationMasterDatasource:
          serviceLocator<SpecificationMasterDatasource>(),
    ),
  );
  serviceLocator.registerSingleton<SpecificationMasterCubit>(
    SpecificationMasterCubit(),
  );
}
