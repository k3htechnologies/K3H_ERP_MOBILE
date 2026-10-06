import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/data/datasource/shift_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/data/repository/shift_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/presentation/cubit/shift_master_cubit.dart';

void registerShiftMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<ShiftMasterDataSource>(
    ShiftMasterDataSourceImp(),
  );
  serviceLocator.registerSingleton<ShiftMasterRepository>(
    ShiftMasterRepositoryImp(
      shiftMasterDataSource: serviceLocator<ShiftMasterDataSource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<ShiftMasterCubit>(ShiftMasterCubit());
}
