import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/payroll/payroll_report/data/datasource/payroll_report.datasource.dart';
import 'package:k3h_erp_app/features/payroll/payroll_report/data/repository/payroll_report.repository.dart';
import 'package:k3h_erp_app/features/payroll/payroll_report/presentation/cubit/payroll_report_cubit.dart';

void registerPayrollReportDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<PayrollReportDatasource>(
    PayrollReportDatasourceImpl(),
  );
  serviceLocator.registerSingleton<PayrollReportRepository>(
    PayrollReportRepositoryImpl(
      payrollReportDatasource: serviceLocator<PayrollReportDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<PayrollReportCubit>(PayrollReportCubit());
}
