import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/data/datasource/asset_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/data/repository/asset_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/presentation/cubit/asset_master_cubit.dart';

void registerAssetMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<AssetMasterDataSource>(
    AssetMasterDataSourceImpl(),
  );

  serviceLocator.registerSingleton<AssetMasterRepository>(
    AssetMasterRepositoryImpl(
      assetMasterDatasource: serviceLocator<AssetMasterDataSource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<AssetMasterCubit>(
    AssetMasterCubit(),
  );
}


