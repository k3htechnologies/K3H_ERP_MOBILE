import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/data/datasource/holiday_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/data/repository/holiday_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/presentation/cubit/holiday_master_cubit.dart';

void registerHolidayMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<HolidayMasterDataSource>(
    HolidayMasterDataSourceImpl(),
  );
  serviceLocator.registerSingleton<HolidayMasterRepository>(
    HolidayMasterRepositoryImpl(
      holidayMasterDataSource: serviceLocator<HolidayMasterDataSource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<HolidayMasterCubit>(HolidayMasterCubit());
}
