import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/data/datasource/payment_schedule_scheme.datasource.dart';

abstract interface class PaymentScheduleSchemeRepository {
  Future<Either<Failure, Map<String, dynamic>>> getPaymentScheduleSchemeList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdatePaymentScheduleScheme({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deletePaymentScheduleScheme({
    required int paymentScheduleSchemeId,
    required String uniqueKey,
    required int projectId,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportPaymentScheduleScheme({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class PaymentScheduleSchemeRepositoryImpl
    extends PaymentScheduleSchemeRepository {
  final PaymentScheduleSchemeDatasource paymentScheduleSchemeDatasource;

  PaymentScheduleSchemeRepositoryImpl({
    required this.paymentScheduleSchemeDatasource,
  });

  // PULL PAYMENT SCHEDULE SCHEME
  @override
  Future<Either<Failure, Map<String, dynamic>>> getPaymentScheduleSchemeList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await paymentScheduleSchemeDatasource
          .apicallPullPaymentScheduleScheme(
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

  // ADD UPDATE PAYMENT SCHEDULE SCHEME
  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdatePaymentScheduleScheme({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await paymentScheduleSchemeDatasource
          .apicallAddUpdatePaymentScheduleScheme(body: body);

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // DELETE PAYMENT SCHEDULE SCHEME
  @override
  Future<Either<Failure, Map<String, dynamic>>> deletePaymentScheduleScheme({
    required int paymentScheduleSchemeId,
    required String uniqueKey,
    required int projectId,
  }) async {
    try {
      var result = await paymentScheduleSchemeDatasource
          .apicallDeletePaymentScheduleScheme(
            paymentScheduleSchemeId: paymentScheduleSchemeId,
            uniqueKey: uniqueKey,
            projectId: projectId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // EXPORT PAYMENT SCHEDULE SCHEME

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportPaymentScheduleScheme({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await paymentScheduleSchemeDatasource
          .apicallPullScheduleSchemeForExport(
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
