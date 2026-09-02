import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/disbursement/data/datasource/disbursement.datasource.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/disbursement/data/repository/disbursement.repository.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/disbursement/presentation/cubit/disbursement_cubit.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/dsa/data/datasource/dsa.datasource.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/dsa/data/repository/dsa.repository.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/dsa/presentation/cubit/dsa_cubit.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/dsra/data/datasource/dsra.datasource.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/dsra/data/repository/dsra.repository.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/dsra/presentation/cubit/dsra_cubit.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/repayment/data/datasource/repayment.datasource.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/repayment/data/repository/repayment.repository.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/repayment/presentation/cubit/repayment_cubit.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/sweep_ratio/data/datasource/sweep_ratio.datasource.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/sweep_ratio/data/repository/sweep_ratio.repository.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/sweep_ratio/presentation/cubit/sweep_ratio_cubit.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/datasource/term_sheet.datasource.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/repository/term_sheet.repository.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/presentation/cubit/term_sheet_cubit.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet_document/data/datasource/term_sheet_document.datasource.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet_document/data/repository/term_sheet_document.repository.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet_document/presentation/cubit/term_sheet_document_cubit.dart';

void registerTermSheetDependencies(GetIt serviceLocator) {
  // DATASOURCES
  serviceLocator.registerSingleton<TermSheetDatasource>(
    TermSheetDatasourceImpl(),
  );
  serviceLocator.registerSingleton<DisbursementDatasource>(
    DisbursementDatasourceImpl(),
  );
  serviceLocator.registerSingleton<SweepRatioDatasource>(
    SweepRatioDatasourceImpl(),
  );
  serviceLocator.registerSingleton<DSADatasource>(DSADatasourceImpl());
  serviceLocator.registerSingleton<RepaymentDatasource>(
    RepaymentDatasourceImpl(),
  );
  serviceLocator.registerSingleton<DsraDatasource>(DsraDatasourceImpl());
  serviceLocator.registerSingleton<TermSheetDocumentsDatasource>(
    TermSheetDocumentsDatasourceImpl(),
  );

  // REPOSITORIES
  serviceLocator.registerSingleton<TermSheetRepository>(
    TermSheetRepositoryImpl(
      termSheetDatasource: serviceLocator<TermSheetDatasource>(),
    ),
  );
  serviceLocator.registerSingleton<DisbursementRepository>(
    DisbursementRepositoryImpl(
      disbursementDatasource: serviceLocator<DisbursementDatasource>(),
    ),
  );
  serviceLocator.registerSingleton<SweepRatioRepository>(
    SweepRatioRepositoryImpl(
      sweepRatioDatasource: serviceLocator<SweepRatioDatasource>(),
    ),
  );
  serviceLocator.registerSingleton<DSARepository>(
    DSARepositoryImpl(dsaDatasource: serviceLocator<DSADatasource>()),
  );
  serviceLocator.registerSingleton<RepaymentRepository>(
    RepaymentRepositoryImpl(
      repaymentDatasource: serviceLocator<RepaymentDatasource>(),
    ),
  );
  serviceLocator.registerSingleton<DsraRepository>(
    DsraRepositoryImpl(dsraDatasource: serviceLocator<DsraDatasource>()),
  );
  serviceLocator.registerSingleton<TermSheetDocumentsRepository>(
    TermSheetDocumentsRepositoryImpl(
      termSheetDocumentsDatasource:
          serviceLocator<TermSheetDocumentsDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<TermSheetCubit>(TermSheetCubit());
  serviceLocator.registerSingleton<DisbursementCubit>(DisbursementCubit());
  serviceLocator.registerSingleton<SweepRatioCubit>(SweepRatioCubit());
  serviceLocator.registerSingleton<DsaCubit>(DsaCubit());
  serviceLocator.registerSingleton<RepaymentCubit>(RepaymentCubit());
  serviceLocator.registerSingleton<DsraCubit>(DsraCubit());
  serviceLocator.registerSingleton<TermSheetDocumentCubit>(
    TermSheetDocumentCubit(),
  );
}
