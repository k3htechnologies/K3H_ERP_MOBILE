import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_debit_master/data/datasource/leave_credit_debit_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_debit_master/data/repository/leave_credit_debit_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_debit_master/presentation/cubit/leave_credit_debit_master_cubit.dart';

void registerLeaveCreditDebitMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<LeaveCreditDebitMasterDatasource>(
    LeaveCreditDebitMasterDatasourceImpl(),
  );
  serviceLocator.registerSingleton<LeaveCreditDebitMasterRepository>(
    LeaveCreditDebitMasterRepositoryImpl(
      leaveCreditDebitMasterDatasource:
          serviceLocator<LeaveCreditDebitMasterDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<LeaveCreditDebitMasterCubit>(
    LeaveCreditDebitMasterCubit(),
  );
}
