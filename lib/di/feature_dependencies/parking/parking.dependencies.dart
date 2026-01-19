import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/parking/data/datasource/parking.datasource.dart';
import 'package:k3h_erp_app/features/parking/data/repository/parking.repository.dart';
import 'package:k3h_erp_app/features/parking/presentation/cubit/parking_cubit.dart';

void registerParkingDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<ParkingDatasource>(ParkingDatasourceImpl());
  serviceLocator.registerSingleton<ParkingRepository>(
    ParkingRepositoryImpl(
      parkingDataSource: serviceLocator<ParkingDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<ParkingCubit>(ParkingCubit());
}
