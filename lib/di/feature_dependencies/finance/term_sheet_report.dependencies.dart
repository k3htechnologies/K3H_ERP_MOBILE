import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/finance/reports/data/datasource/term_sheet_report.datasource.dart';
import 'package:k3h_erp_app/features/finance/reports/data/repository/term_sheet_report.repository.dart';
import 'package:k3h_erp_app/features/finance/reports/presentation/cubit/term_sheet_report_cubit.dart';

void registerTermSheetReportDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<TermSheetReportDatasource>(
    TermSheetReportDatasourceImpl(),
  );
  serviceLocator.registerSingleton<TermSheetReportRepository>(
    TermSheetReportRepositoryImpl(
      termSheetReportDatasource: serviceLocator<TermSheetReportDatasource>(),
    ),
  );
  //- CUBITS -
  serviceLocator.registerSingleton<TermSheetReportCubit>(
    TermSheetReportCubit(),
  );
}
