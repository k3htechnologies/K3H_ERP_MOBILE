import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/datasource/term_sheet.datasource.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/repository/term_sheet.repository.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/presentation/cubit/term_sheet_cubit.dart';

void registerTermSheetDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<TermSheetDatasource>(
    TermSheetDatasourceImpl(),
  );
  serviceLocator.registerSingleton<TermSheetRepository>(
    TermSheetRepositoryImpl(
      termSheetDatasource: serviceLocator<TermSheetDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<TermSheetCubit>(TermSheetCubit());
}
