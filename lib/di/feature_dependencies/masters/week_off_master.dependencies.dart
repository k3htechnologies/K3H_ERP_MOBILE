import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/data/datasource/week_off_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/data/repository/week_off_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/presentation/cubit/week_off_master_cubit.dart';

void registerWeekOffMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<WeekOffMasterDataSource>(
    WeekOffMasterDataSourceImp(),
  );
  serviceLocator.registerSingleton<WeekOffMasterRepository>(
    WeekOffMasterRepositoryImp(
      weekOffMasterDataSource: serviceLocator<WeekOffMasterDataSource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<WeekOffMasterCubit>(WeekOffMasterCubit());
}
