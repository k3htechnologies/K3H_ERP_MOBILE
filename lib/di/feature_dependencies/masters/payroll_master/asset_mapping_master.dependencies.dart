import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/data/datasource/asset_master_mapping.datasource.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/data/repository/asset_master_mapping.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/presentation/cubit/asset_mapping_master_cubit.dart';

void registerAssetMappingMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<AssetMasterMappingDatasource>(
    AssetMasterMappingDatasourceImpl(),
  );

  serviceLocator.registerSingleton<AssetMasterMappingRepository>(
    AssetMasterMappingRepositoryImpl(
      assetMasterMappingDatasource:
          serviceLocator<AssetMasterMappingDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<AssetMappingMasterCubit>(
    AssetMappingMasterCubit(),
  );
}
