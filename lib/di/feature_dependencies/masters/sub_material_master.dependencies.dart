import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/data/datasorce/sub_material_maste.datasource.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/data/repository/sub_material_master.repository.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/presentation/cubit/sub_material_master_cubit.dart';

void registerSubMaterialMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<SubMaterialMasterDatasource>(
    SubMaterialMasterDataSourceImpl(),
  );

  serviceLocator.registerSingleton<SubMaterialMasterRepository>(
    SubMaterialMasterRepositoryImpl(
      subMaterialMasterDatasource:
          serviceLocator<SubMaterialMasterDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<SubMaterialMasterCubit>(
    SubMaterialMasterCubit(),
  );
}

