import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/more/otp_logs/data/datasource/otp_logs.datasource.dart';
import 'package:k3h_erp_app/features/more/otp_logs/data/repository/otp_logs.repository.dart';
import 'package:k3h_erp_app/features/more/otp_logs/presentation/cubit/otp_logs_cubit.dart';

void registerOtpLogsDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<OtpLogsDatasource>(OtpLogsDatasourceImpl());
  serviceLocator.registerSingleton<OtpLogsRepository>(
    OtpLogsRepositoryImpl(
      otpLogsDatasource: serviceLocator<OtpLogsDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<OtpLogsCubit>(OtpLogsCubit());
}
