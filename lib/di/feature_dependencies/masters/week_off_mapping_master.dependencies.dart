import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/data/datasource/week_off_mapping_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/data/respository/week_off_mapping_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/presentation/cubit/week_off_mapping_cubit.dart';

void registerWeekOffMappingMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<WeekOffMappingMasterDataSource>(
    WeekOffMappingMasterDataSourceImp(),
  );
  serviceLocator.registerSingleton<WeekOffMappingMasterRepository>(
    WeekOffMappingMasterRepositoryImp(
      weekOffMasterDataSource: serviceLocator<WeekOffMappingMasterDataSource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<WeekOffMappingMasterCubit>(
    WeekOffMappingMasterCubit(),
  );
}
