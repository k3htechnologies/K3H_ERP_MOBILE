import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/files/presentation/cubit/files_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover/presentation/cubit/flat_handover_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/data/datasource/loan_details.datasource.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/data/repository/loan_details.repository.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/presentation/cubit/loan_details_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/datasource/pay_track.datasource.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/datasource/pay_track_booking_files.datasource.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/repository/pay_track.repository.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/repository/pay_track_booking_files.repository.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/datasource/payment.datasource.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/repository/payment.repository.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/cubit/payment_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/datasource/request_management.datasource.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/repository/request_management.repository.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';

void registerPayTrackDependencies(GetIt serviceLocator) {
  // DATASOURCE
  serviceLocator.registerSingleton<PayTrackDatasource>(
    PayTrackDatasourceImpl(),
  );
  serviceLocator.registerSingleton<PayTrackBookingFilesDatasource>(
    PayTrackBookingFilesDatasourceImpl(),
  );

  serviceLocator.registerSingleton<BookingLoanDetailsDatasource>(
    BookingLoanDetailsDatasourceImpl(),
  );
  serviceLocator.registerSingleton<PaymentDatasource>(PaymentDatasourceImpl());
  serviceLocator.registerSingleton<RequestManagementDatasource>(
    RequestManagementDatasourceImpl(),
  );
  // REPOSITORIES
  serviceLocator.registerSingleton<PayTrackRepository>(
    PayTrackRepositoryImpl(
      payTrackDatasource: serviceLocator<PayTrackDatasource>(),
    ),
  );
  serviceLocator.registerSingleton<PayTrackBookingFilesRepository>(
    PayTrackBookingFilesRepositoryImpl(
      payTrackBookingFilesDatasource:
          serviceLocator<PayTrackBookingFilesDatasource>(),
    ),
  );
  serviceLocator.registerSingleton<BookingLoanDetailsRepository>(
    BookingLoanDetailsRepositoryImpl(
      bookingLoanDetailsDatasource:
          serviceLocator<BookingLoanDetailsDatasource>(),
    ),
  );
  serviceLocator.registerSingleton<PaymentRepository>(
    PaymentRepositoryImpl(
      paymentDatasource: serviceLocator<PaymentDatasource>(),
    ),
  );
  serviceLocator.registerSingleton<RequestManagementRepository>(
    RequestManagementRepositoryImpl(
      flatAlterationRequestDatasource:
          serviceLocator<RequestManagementDatasource>(),
    ),
  );
  // CUBITS
  serviceLocator.registerSingleton<PayTrackCubit>(PayTrackCubit());
  serviceLocator.registerSingleton<LoanDetailsCubit>(LoanDetailsCubit());
  serviceLocator.registerSingleton<FlatHandoverCubit>(FlatHandoverCubit());
  serviceLocator.registerSingleton<FilesCubit>(FilesCubit());
  serviceLocator.registerSingleton<PaymentCubit>(PaymentCubit());
  serviceLocator.registerSingleton<RequestManagementCubit>(
    RequestManagementCubit(),
  );
}
