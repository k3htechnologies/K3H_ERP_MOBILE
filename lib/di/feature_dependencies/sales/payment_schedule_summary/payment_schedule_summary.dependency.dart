import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/data/datasource/payment_schedule_summary.datasource.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/data/repository/payment_schedule_summary.repository.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/presentation/cubit/payment_schedule_summary_cubit.dart';

void registerPaymentScheduleSummaryDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<PaymentScheduleDataSource>(
    PaymentScheduleDataSourceImpl(),
  );

  serviceLocator.registerSingleton<PaymentScheduleSummaryRepository>(
    PaymentScheduleSummaryRepositoryImpl(
      paymentScheduleDataSource: serviceLocator<PaymentScheduleDataSource>(),
    ),
  );

  //<---- CUBIT ---->
  serviceLocator.registerSingleton<PaymentScheduleSummaryCubit>(
    PaymentScheduleSummaryCubit(),
  );
}
