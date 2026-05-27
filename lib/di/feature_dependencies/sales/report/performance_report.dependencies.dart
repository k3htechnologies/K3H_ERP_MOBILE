import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/performance/data/datasource/performance_report.datatsource.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/performance/data/repository/performance_report.repository.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/performance/presentation/cubit/performance_cubit.dart';

void registerPerformanceReportDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<PerformanceReportDatasource>(
    PerformanceReportDatasourceImpl(),
  );
  serviceLocator.registerSingleton<PerformanceReportRepository>(
    PerformanceReportRepositoryImpl(
      performanceReportDatasource:
          serviceLocator<PerformanceReportDatasource>(),
    ),
  );

  //<---- CUBIT ---->
  serviceLocator.registerSingleton<PerformanceCubit>(PerformanceCubit());
}
