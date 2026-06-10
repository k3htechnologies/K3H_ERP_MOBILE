import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule/data/datasource/payment_schedule.datasource.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule/data/respository/payment_schedule.repository.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule/presentation/cubit/payment_schedule_cubit.dart';

void registerPaymentScheduleDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<PaymentScheduleDatasource>(
    PaymentScheduleDatasourceImpl(),
  );

  serviceLocator.registerSingleton<PaymentScheduleRepository>(
    PaymentScheduleRepositoryImpl(
      paymentScheduleDatasource: serviceLocator<PaymentScheduleDatasource>(),
    ),
  );

  //<---- CUBIT ---->
  serviceLocator.registerSingleton<PaymentScheduleCubit>(
    PaymentScheduleCubit(),
  );
}
