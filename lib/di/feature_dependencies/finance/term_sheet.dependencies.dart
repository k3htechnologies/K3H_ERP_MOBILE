import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/finance/disbursement/data/datasource/disbursement.datasource.dart';
import 'package:k3h_erp_app/features/finance/disbursement/data/repository/disbursement.repository.dart';
import 'package:k3h_erp_app/features/finance/disbursement/presentation/cubit/disbursement_cubit.dart';
import 'package:k3h_erp_app/features/finance/document/data/datasource/document.datasource.dart';
import 'package:k3h_erp_app/features/finance/document/data/repository/document.repository.dart';
import 'package:k3h_erp_app/features/finance/document/presentation/cubit/documents_cubit.dart';
import 'package:k3h_erp_app/features/finance/dsa/data/datasource/dsa.datasource.dart';
import 'package:k3h_erp_app/features/finance/dsa/data/repository/dsa.repository.dart';
import 'package:k3h_erp_app/features/finance/dsa/presentation/cubit/dsa_cubit.dart';
import 'package:k3h_erp_app/features/finance/dsra/data/datasource/dsra.datasource.dart';
import 'package:k3h_erp_app/features/finance/dsra/data/repository/dsra.repository.dart';
import 'package:k3h_erp_app/features/finance/dsra/presentation/cubit/dsra_cubit.dart';
import 'package:k3h_erp_app/features/finance/repayment/data/datasource/repayment.datasource.dart';
import 'package:k3h_erp_app/features/finance/repayment/data/repository/repayment.repository.dart';
import 'package:k3h_erp_app/features/finance/repayment/presentation/cubit/repayment_cubit.dart';
import 'package:k3h_erp_app/features/finance/sweep_ratio/data/datasource/sweep_ratio.datasource.dart';
import 'package:k3h_erp_app/features/finance/sweep_ratio/data/repository/sweep_ratio.repository.dart';
import 'package:k3h_erp_app/features/finance/sweep_ratio/presentation/cubit/sweep_ratio_cubit.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/datasource/term_sheet.datasource.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/repository/term_sheet.repository.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/presentation/cubit/term_sheet_cubit.dart';

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
  serviceLocator.registerSingleton<DocumentsDatasource>(
    DocumentsDatasourceImpl(),
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
  serviceLocator.registerSingleton<DocumentsRepository>(
    DocumentsRepositoryImpl(
      documentsDatasource: serviceLocator<DocumentsDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<TermSheetCubit>(TermSheetCubit());
  serviceLocator.registerSingleton<DisbursementCubit>(DisbursementCubit());
  serviceLocator.registerSingleton<SweepRatioCubit>(SweepRatioCubit());
  serviceLocator.registerSingleton<DsaCubit>(DsaCubit());
  serviceLocator.registerSingleton<RepaymentCubit>(RepaymentCubit());
  serviceLocator.registerSingleton<DsraCubit>(DsraCubit());
  serviceLocator.registerSingleton<DocumentsCubit>(DocumentsCubit());
}
