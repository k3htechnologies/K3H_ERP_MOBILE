import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule/data/datasource/payment_schedule.datasource.dart';

abstract interface class PaymentScheduleRepository {
  Future<Either<Failure, Map<String, dynamic>>> getPaymentScheduleMasterList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdatePaymentScheduleMaster({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deletePaymentSchedule({
    required int paymentScheduleId,
    required String uniqueKey,
    required int projectId,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportPaymentScheduleMaster({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class PaymentScheduleRepositoryImpl extends PaymentScheduleRepository {
  final PaymentScheduleDatasource paymentScheduleDatasource;

  PaymentScheduleRepositoryImpl({required this.paymentScheduleDatasource});

  // PULL PAYMENT SCHEDULE

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPaymentScheduleMasterList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await paymentScheduleDatasource
          .apicallPullPaymentScheduleMaster(
            pageNumber: pageNumber,
            pageSize: pageSize,
            projectId: projectId,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // ADD UPDATE PAYMENT SCHEDULE

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdatePaymentScheduleMaster({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await paymentScheduleDatasource
          .apicallAddUpdatePaymentScheduleMaster(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // DELETE PAYMENT SCHEDULE

  @override
  Future<Either<Failure, Map<String, dynamic>>> deletePaymentSchedule({
    required int paymentScheduleId,
    required String uniqueKey,
    required int projectId,
  }) async {
    try {
      var result = await paymentScheduleDatasource.apicallDeletePaymentSchedule(
        paymentScheduleId: paymentScheduleId,
        uniqueKey: uniqueKey,
        projectId: projectId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // EXPORT PAYMENT SCHDULE

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportPaymentScheduleMaster({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await paymentScheduleDatasource
          .apicallPullPaymentScheduleMasterForExport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            projectId: projectId,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
