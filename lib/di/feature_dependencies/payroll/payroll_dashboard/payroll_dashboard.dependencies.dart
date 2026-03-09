import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/payroll/payroll_dashboard/data/datasource/payroll_dashboard.datasource.dart';
import 'package:k3h_erp_app/features/payroll/payroll_dashboard/data/respository/payroll_dashboard_repository.dart';
import 'package:k3h_erp_app/features/payroll/payroll_dashboard/presentation/cubit/payroll_dashboard_cubit.dart';

void registerPayrollDashboardDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<PayrollDashboardDatasource>(
    PayrollDashboardDatasourceImpl(),
  );
  serviceLocator.registerSingleton<PayrollDashboardRepository>(
    PayrollDashboardRepositoryImpl(
      payrollDashboardDatasource: serviceLocator<PayrollDashboardDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<PayrollDashboardCubit>(
    PayrollDashboardCubit(),
  );
}
