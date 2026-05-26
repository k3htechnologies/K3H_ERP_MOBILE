import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/inventory_reports/data/datasource/inventory_report.datasource.dart';
import 'package:k3h_erp_app/features/inventory_reports/data/repository/inventory_report.repository.dart';
import 'package:k3h_erp_app/features/inventory_reports/presentation/cubit/inventory_report_cubit.dart';

void registerInventoryReportReportDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<InventoryReportDatasource>(
    InventoryReportDatasourceImpl(),
  );
  serviceLocator.registerSingleton<InventoryReportRepository>(
    InventoryReportRepositoryImpl(
      inventoryReportDatasource: serviceLocator<InventoryReportDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<InventoryReportCubit>(
    InventoryReportCubit(),
  );
}
