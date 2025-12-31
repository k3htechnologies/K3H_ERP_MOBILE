import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/datasource/branch_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/repository/branch_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/presentation/cubit/branch_master_cubit.dart';

void registerBranchMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<BranchMasterDatasource>(
    BranchMasterDatasourceImpl(),
  );

  serviceLocator.registerSingleton<BranchMasterRepository>(
    BranchMasterRepositoryImpl(
      branchMasterDatasource: serviceLocator<BranchMasterDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<BranchMasterCubit>(
    BranchMasterCubit(),
  );
}