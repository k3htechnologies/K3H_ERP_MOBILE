import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/presentation/cubit/bank_list_master_cubit.dart';

void registerBankListMasterDependencies(GetIt serviceLocator) {
  // <----- CUBITS ----->
  serviceLocator.registerSingleton<BankListMasterCubit>(BankListMasterCubit());
}

