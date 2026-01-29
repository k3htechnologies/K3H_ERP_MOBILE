import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/payroll/payroll_report/presentation/cubit/payroll_report_cubit.dart';

void registerPayrollReportDependencies(GetIt serviceLocator) {
  // serviceLocator.registerSingleton<OutdoorDatasource>(
  //   OutdoorDatasourceDataSourceImpl(),
  // );
  // serviceLocator.registerSingleton<OutdoorRepository>(
  //   OutdoorRepositoryImpl(
  //     outdoorDatasource: serviceLocator<OutdoorDatasource>(),
  //   ),
  // );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<PayrollReportCubit>(PayrollReportCubit());
}