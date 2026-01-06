import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/data/datasource/material_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/data/repository/material_master.repository.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/presentation/cubit/material_master_cubit.dart';

void registerMaterialMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<MaterialMasterDatasource>(
    MaterialMasterDataSourceImpl(),
  );

  serviceLocator.registerSingleton<MaterialMasterRepository>(
    MaterialMasterRepositoryImpl(
      materialMasterDatasource: serviceLocator<MaterialMasterDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<MaterialMasterCubit>(
    MaterialMasterCubit(),
  );
}


