import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/data/datasource/earning_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/data/repository/earning_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/presentation/cubit/earning_master_cubit.dart';

void registerEarningMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<EarningMasterDatasource>(
    EarningMasterDatasourceImpl(),
  );
  serviceLocator.registerSingleton<EarningMasterRepository>(
    EarningMasterRepositoryImpl(
      earningMasterDatasource: serviceLocator<EarningMasterDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<EarningMasterCubit>(EarningMasterCubit());
}
