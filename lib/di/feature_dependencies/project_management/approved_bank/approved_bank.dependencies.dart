import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/data/datasource/approved_bank.datasource.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/data/repository/approved_bank.repository.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/cubit/approved_bank_file/approved_bank_file_cubit.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/cubit/approved_bank_folder/approved_bank_folder_cubit.dart';

void registerApprovedBankDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<ApprovedBankDatasource>(
    ApprovedBankDatasourceImpl(),
  );
  serviceLocator.registerSingleton<ApprovedBankRepository>(
    ApprovedBankRepositoryImpl(
      approvedBankDatasource: serviceLocator<ApprovedBankDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<ApprovedBankFolderCubit>(
    ApprovedBankFolderCubit(),
  );

  serviceLocator.registerSingleton<ApprovedBankFileCubit>(
    ApprovedBankFileCubit(),
  );
}
