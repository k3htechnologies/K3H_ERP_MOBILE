import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/snag_checklist/data/datasource/snag_checklist.datasource.dart';

abstract interface class SnagChecklistRepository {
  Future<Either<Failure, Map<String, dynamic>>> getBookingLoanDetailsList({
    required int projectId,
    required int bookingId,
    required String categoryName,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateBookingLoanDetails({
    required Map<String, dynamic> body,
  });
}

class SnagChecklistRepositoryImpl extends SnagChecklistRepository {
  final SnagChecklistDatasource snagChecklistDatasource;

  SnagChecklistRepositoryImpl({required this.snagChecklistDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBookingLoanDetailsList({
    required int projectId,
    required int bookingId,
    required String categoryName,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await snagChecklistDatasource.apicallPullSnagCheckList(
        projectId: projectId,
        bookingId: bookingId,
        categoryName: categoryName,
        queryParams: queryParams,
      );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateBookingLoanDetails({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await snagChecklistDatasource.apicallAddUpdateSnagCheckList(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
