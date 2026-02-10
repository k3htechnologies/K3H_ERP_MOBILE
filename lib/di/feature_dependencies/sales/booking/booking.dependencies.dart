import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/sales/booking/data/datasource/booking.datasource.dart';

import 'package:k3h_erp_app/features/sales/booking/data/datasource/booking.datasource.dart';
import 'package:k3h_erp_app/features/sales/booking/data/repository/booking.repository.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/cubit/booking_cubit.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/cubit/booking_cubit.dart';

void registerTargetDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<BookingDatasource>(BookingDatasourceImpl());
  serviceLocator.registerSingleton<BookingRepository>(
    BookingRepositoryImpl(
      bookingDatasource: serviceLocator<BookingDatasource>(),
    ),
  );

  //<---- CUBIT ---->
  serviceLocator.registerSingleton<BookingCubit>(BookingCubit());
}