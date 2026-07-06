import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/data/datasource/deduction_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/data/repository/deduction_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/presentation/cubit/deduction_master_cubit.dart';

void registerDeductionMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<DeductionMasterDatasource>(
    DeductionMasterDatasourceImpl(),
  );
  serviceLocator.registerSingleton<DeductionMasterRepository>(
    DeductionMasterRepositoryImpl(
      deductionMasterDatasource: serviceLocator<DeductionMasterDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<DeductionMasterCubit>(
    DeductionMasterCubit(),
  );
}
