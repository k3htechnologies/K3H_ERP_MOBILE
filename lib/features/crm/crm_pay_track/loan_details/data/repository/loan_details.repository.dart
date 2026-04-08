import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/data/datasource/loan_details.datasource.dart';

abstract interface class BankLoanDetailsRepository {
  Future<Either<Failure, Map<String, dynamic>>> getBookingLoanDetailsList({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateBookingLoanDetails({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteBookingLoanDetails({
    required int bookingLoanDetailsId,
    required String uniqueKey,
    required int projectId,
    required int bookingId,
  });
}

class BankLoanDetailsRepositoryImpl extends BankLoanDetailsRepository {
  final BookingLoanDetailsDatasource bankLoanDetailsDatasource;

  BankLoanDetailsRepositoryImpl({required this.bankLoanDetailsDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBookingLoanDetailsList({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await bankLoanDetailsDatasource
          .apicallPullBookingLoanDetails(
            pageSize: pageSize,
            pageNumber: pageNumber,
            projectId: projectId,
            bookingId: bookingId,
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
      var result = await bankLoanDetailsDatasource
          .apicallAddUpdateBookingLoanDetails(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteBookingLoanDetails({
    required int bookingLoanDetailsId,
    required String uniqueKey,
    required int projectId,
    required int bookingId,
  }) async {
    try {
      var result = await bankLoanDetailsDatasource
          .apicallDeleteBookingLoanDetails(
            bookingLoanDetailsId: bookingLoanDetailsId,
            uniqueKey: uniqueKey,
            projectId: projectId,
            bookingId: bookingId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
