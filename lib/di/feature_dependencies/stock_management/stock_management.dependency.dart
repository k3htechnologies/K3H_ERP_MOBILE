import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/stock_management/data/datasource/stock_management.datasource.dart';
import 'package:k3h_erp_app/features/stock_management/data/repository/stock_management.repository.dart';
import 'package:k3h_erp_app/features/stock_management/presentation/cubit/stock_management_cubit.dart';

void registerStockManagementrDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<StockManagementDatasource>(
    StockManagementDatasourceImpl(),
  );
  serviceLocator.registerSingleton<StockManagementRepository>(
    StockManagementRepositoryImpl(
      stockManagementDatasource: serviceLocator<StockManagementDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<StockManagementCubit>(
    StockManagementCubit(),
  );
}
