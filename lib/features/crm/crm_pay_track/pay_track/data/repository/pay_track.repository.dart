import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/datasource/pay_track.datasource.dart';

abstract interface class PayTrackRepository {
  Future<Either<Failure, Map<String, dynamic>>> getPayTrackList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> getPayTrackListById({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportPayTrackList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  updatePayTrackBookingRegistrationDateParking({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
}

class PayTrackRepositoryImpl extends PayTrackRepository {
  final PayTrackDatasource payTrackDatasource;
  PayTrackRepositoryImpl({required this.payTrackDatasource});
  @override
  Future<Either<Failure, Map<String, dynamic>>> getPayTrackList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await payTrackDatasource.apiCallPullPayTrack(
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
  Future<Either<Failure, Map<String, dynamic>>> getPayTrackListById({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await payTrackDatasource.apiCallPullPayTrackByBookingId(
        pageNumber: pageNumber,
        pageSize: pageSize,
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
  Future<Either<Failure, Map<String, dynamic>>> exportPayTrackList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await payTrackDatasource.apiCallPullPayTrackForExport(
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
  Future<Either<Failure, Map<String, dynamic>>>
  updatePayTrackBookingRegistrationDateParking({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await payTrackDatasource
          .apiCallUpdatePayTrackBookingRegistrationDateParking(
            body: body,
            fileList: fileList,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
