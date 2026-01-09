import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/inventory/data/datasource/inventory.datasource.dart';
import 'package:k3h_erp_app/features/inventory/data/repository/inventory.repository.dart';
import 'package:k3h_erp_app/features/inventory/presentation/cubit/inventory_cubit.dart';

void registerInventoryDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<InventoryDatasource>(InventoryDatasourceImpl());
  serviceLocator.registerSingleton<InventoryRepository>(
    InventoryRepositoryImpl(inventoryDatasource: serviceLocator<InventoryDatasource>()),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<InventoryCubit>(InventoryCubit());
}