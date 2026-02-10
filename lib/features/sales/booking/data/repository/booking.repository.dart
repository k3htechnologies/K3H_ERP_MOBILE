import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/sales/booking/data/datasource/booking.datasource.dart';

abstract interface class BookingRepository {
  Future<Either<Failure, Map<String, dynamic>>> getBookingList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class BookingRepositoryImpl extends BookingRepository {
  BookingDatasource bookingDatasource;

  BookingRepositoryImpl({required this.bookingDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBookingList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await bookingDatasource.apiCallPullBooking(
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
