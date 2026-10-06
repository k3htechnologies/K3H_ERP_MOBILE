import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/data/datasource/shift_master_mapping.datasource.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/data/repository/shift_master_mapping.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/presentation/cubit/shift_master_mapping_cubit.dart';

void registerShiftMappingMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<ShiftMappingMasterDatasource>(
    ShiftMappingMasterDataSourceImp(),
  );
  serviceLocator.registerSingleton<ShiftMappingMasterRepository>(
    ShiftMappingMasterRepositoryImpl(
      shiftMasterMappingDatasource:
          serviceLocator<ShiftMappingMasterDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<ShiftMappingMasterCubit>(
    ShiftMappingMasterCubit(),
  );
}
