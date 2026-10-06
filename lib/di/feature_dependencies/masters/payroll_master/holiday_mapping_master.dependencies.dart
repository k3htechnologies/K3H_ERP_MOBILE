import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/data/datasource/holiday_mapping_maaster.datasource.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/data/repository/holiday_mapping_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/presentation/cubit/holiday_mapping_master_cubit.dart';

void registerHolidayMappingMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<HolidayMappingMasterDatasource>(
    HolidayMappingMasterDatasourceImpl(),
  );
  serviceLocator.registerSingleton<HolidayMappingMasterRepository>(
    HolidayMappingMasterRepositoryImpl(
      holidayMappingMasterDatasource:
          serviceLocator<HolidayMappingMasterDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<HolidayMappingMasterCubit>(
    HolidayMappingMasterCubit(),
  );
}
