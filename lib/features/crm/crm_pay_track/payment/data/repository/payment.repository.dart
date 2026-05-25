import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/datasource/payment.datasource.dart';

abstract interface class PaymentRepository {
  Future<Either<Failure, Map<String, dynamic>>>
  getPayTrackPayTrackPaymentLedgerList({
    required int bookingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> getPayTrackPaymentScheduleList({
    required int bookingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdatePayTrackPaymentLedger({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deletePayTrackPaymentLedger({
    required int projectId,
    required int payTrackPaymentLedgerId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportPaymentLedger({
    required int bookingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdatePayTrackPaymentScheduleDemand({required Map<String, String> body});
  Future<Either<Failure, Map<String, dynamic>>>
  getPayTrackPayTrackPaymentLedgerSummaryList({
    required int bookingId,
    required int projectId,
    required String paymentFor,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateRefundedAmountLedger({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
}

class PaymentRepositoryImpl extends PaymentRepository {
  final PaymentDatasource paymentDatasource;

  PaymentRepositoryImpl({required this.paymentDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getPayTrackPayTrackPaymentLedgerList({
    required int bookingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await paymentDatasource.apicallPullPayTrackPaymentLedger(
        bookingId: bookingId,
        projectId: projectId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPayTrackPaymentScheduleList({
    required int bookingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await paymentDatasource.apicallPullPayTrackPaymentSchedule(
        bookingId: bookingId,
        projectId: projectId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdatePayTrackPaymentLedger({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await paymentDatasource
          .apicallAddUpdatePayTrackPaymentLedger(
            body: body,
            fileList: fileList,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deletePayTrackPaymentLedger({
    required int projectId,
    required int payTrackPaymentLedgerId,
    required String uniqueKey,
  }) async {
    try {
      var result = await paymentDatasource.apicallDeletePayTrackPaymentLedger(
        projectId: projectId,
        payTrackPaymentLedgerId: payTrackPaymentLedgerId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportPaymentLedger({
    required int bookingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await paymentDatasource
          .apicallPullPayTrackPaymentLedgerForExport(
            bookingId: bookingId,
            projectId: projectId,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdatePayTrackPaymentScheduleDemand({
    required Map<String, String> body,
  }) async {
    try {
      var result = await paymentDatasource
          .apicallAddUpdatePayTrackPaymentScheduleDemand(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getPayTrackPayTrackPaymentLedgerSummaryList({
    required int bookingId,
    required int projectId,
    required String paymentFor,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await paymentDatasource
          .apicallPullPayTrackPaymentLedgerSummary(
            bookingId: bookingId,
            projectId: projectId,
            paymentFor: paymentFor,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateRefundedAmountLedger({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await paymentDatasource.apicallAddUpdateRefundedAmountLedger(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
