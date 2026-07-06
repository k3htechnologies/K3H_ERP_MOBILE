import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/data/datasource/branch_association_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/data/repository/branch_association_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/presentation/cubit/branch_association_master_cubit.dart';

void registerBranchAssociationMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<BranchAssociationMasterDatasource>(
    BranchAssociationMasterDatasourceImpl(),
  );

  serviceLocator.registerSingleton<BranchAssociationMasterRepository>(
    BranchAssociationMasterRepositoryImpl(
      branchAssociationMasterDataSource:
          serviceLocator<BranchAssociationMasterDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<BranchAssociationMasterCubit>(
    BranchAssociationMasterCubit(),
  );
}
