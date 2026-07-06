import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/data/datasource/leave_credit_configuration_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/data/repository/leave_credit_configuration_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/presentation/cubit/leave_credit_configuration_master_cubit.dart';

void registerLeaveCreditConfigurationMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<LeaveCreditConfigurationMasterDatasource>(
    LeaveCreditConfigurationMasterDatasourceImpl(),
  );
  serviceLocator.registerSingleton<LeaveCreditConfigurationMasterRepository>(
    LeaveCreditConfigurationMasterRepositoryImpl(
      leaveCreditConfigurationMasterDatasource:
          serviceLocator<LeaveCreditConfigurationMasterDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<LeaveCreditConfigurationMasterCubit>(
    LeaveCreditConfigurationMasterCubit(),
  );
}
