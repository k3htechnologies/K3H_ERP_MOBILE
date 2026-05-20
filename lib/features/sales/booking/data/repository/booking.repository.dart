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

  Future<Either<Failure, Map<String, dynamic>>> addUpdateBooking({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>> getPaymentScheduleStagesList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> cancelBooking({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportBooking({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class BookingRepositoryImpl extends BookingRepository {
  BookingDatasource bookingDatasource;

  BookingRepositoryImpl({required this.bookingDatasource});

  // PULL BOOKING
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

  // ADD / UPADATE BOOKING
  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateBooking({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await bookingDatasource.apiCallAddUpdateBooking(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // PULL PAYMENT SCHEDULE
  @override
  Future<Either<Failure, Map<String, dynamic>>> getPaymentScheduleStagesList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await bookingDatasource.apiCallPullPaymentScheduleStages(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
        inventoryBuildingId: inventoryBuildingId,
        inventoryFlatFloorBasementPodiumWingId:
            inventoryFlatFloorBasementPodiumWingId,
        queryParams: queryParams,
      );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  //  CANCEL BOOKING
  @override
  Future<Either<Failure, Map<String, dynamic>>> cancelBooking({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await bookingDatasource.apiCallCancelBooking(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // EXPORT BOOKING
  @override
  Future<Either<Failure, Map<String, dynamic>>> exportBooking({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await bookingDatasource.apiCallPullBookingForExport(
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
