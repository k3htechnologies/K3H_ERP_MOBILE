import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/data/datasource/payment_schedule_scheme.datasource.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/data/repository/payment_schedule_scheme.repository.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/presentation/cubit/payment_schedule_scheme_cubit.dart';

void registerPaymentScheduleSchemeDependencies(GetIt serviceLocator) {
  // ---------------- DATASOURCE ----------------
  serviceLocator.registerSingleton<PaymentScheduleSchemeDatasource>(
    PaymentScheduleSchemeDatasourceImpl(),
  );

  // ---------------- REPOSITORY ----------------
  serviceLocator.registerSingleton<PaymentScheduleSchemeRepository>(
    PaymentScheduleSchemeRepositoryImpl(
      paymentScheduleSchemeDatasource:
          serviceLocator<PaymentScheduleSchemeDatasource>(),
    ),
  );

  // ---------------- CUBIT ----------------
  serviceLocator.registerSingleton<PaymentScheduleSchemeCubit>(
    PaymentScheduleSchemeCubit(),
  );
}
