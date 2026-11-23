import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/crm/crm_report/client_loan_report/data/datasource/client_loan_report.datasource.dart';
import 'package:k3h_erp_app/features/crm/crm_report/client_loan_report/data/repository/client_loan_report.repository.dart';
import 'package:k3h_erp_app/features/crm/crm_report/client_loan_report/presentation/cubit/client_loan_report_cubit.dart';

void registerClientLoanReportsDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<ClientLoanReportDatasource>(
    ClientLoanReportDatasourceImpl(),
  );
  serviceLocator.registerSingleton<ClientLoanReportRepository>(
    ClientLoanReportRepositoryImpl(
      clientLoanReportDatasource: serviceLocator<ClientLoanReportDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<ClientLoanReportCubit>(
    ClientLoanReportCubit(),
  );
}
