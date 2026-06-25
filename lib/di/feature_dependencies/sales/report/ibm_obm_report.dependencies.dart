import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/ibm_obm/data/datasource/ibm_obm_report.datasource.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/ibm_obm/data/repository/ibm_obm_report.repository.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/ibm_obm/presentation/cubit/ibm_obm_report_cubit.dart';

void registerIbmObmReportDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<IbmObmReportDatasource>(
    IbmObmReportDatasourceImpl(),
  );
  serviceLocator.registerSingleton<IbmObmReportRepository>(
    IbmObmReportRepositoryImpl(
      ibmObmReportDatasource: serviceLocator<IbmObmReportDatasource>(),
    ),
  );
  serviceLocator.registerSingleton<IbmObmReportCubit>(IbmObmReportCubit());
}
