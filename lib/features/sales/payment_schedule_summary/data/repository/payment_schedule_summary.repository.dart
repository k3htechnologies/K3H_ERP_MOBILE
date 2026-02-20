import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/data/datasource/payment_schedule_summary.datasource.dart';

abstract interface class PaymentScheduleSummaryRepository {
  Future<Either<Failure, Map<String, dynamic>>> getProjectInventoryStructure({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> getPaymentScheduleMasterReport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required Map<String, dynamic> queryParams,
  });
  // ---------------- NEW: Cost Sheet ----------------
  Future<Either<Failure, Map<String, dynamic>>> getCostSheetReport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required Map<String, dynamic> queryParams,
  });
}

class PaymentScheduleSummaryRepositoryImpl
    implements PaymentScheduleSummaryRepository {
  final PaymentScheduleDataSource paymentScheduleDataSource;

  PaymentScheduleSummaryRepositoryImpl({
    required this.paymentScheduleDataSource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProjectInventoryStructure({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await paymentScheduleDataSource
          .apicallPullProjectInventoryStructure(
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

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPaymentScheduleMasterReport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required Map<String, dynamic> queryParams,
  }) async {
    try {
      var result = await paymentScheduleDataSource
          .apicallPullPaymentScheduleMasterReport(
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

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCostSheetReport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required Map<String, dynamic> queryParams,
  }) async {
    try {
      var result = await paymentScheduleDataSource.apicallPullCostSheetReport(
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
