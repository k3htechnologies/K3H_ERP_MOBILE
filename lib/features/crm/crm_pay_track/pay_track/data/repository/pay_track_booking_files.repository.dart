import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/datasource/pay_track_booking_files.datasource.dart';

abstract interface class PayTrackBookingFilesRepository {
  Future<Either<Failure, Map<String, dynamic>>>
  getPayTrackBookingFilesBookingFilesList({
    required int pageNumber,
    required int pageSize,
    required String fileType,
    required int bookingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdatePayTrackBookingFilesBookingFiles({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  deletePayTrackBookingFilesBookingFiles({
    required int payTrackBookingFilesId,
    required int projectId,
    required int bookingId,
    required String uniqueKey,
  });
}

class PayTrackBookingFilesRepositoryImpl
    extends PayTrackBookingFilesRepository {
  final PayTrackBookingFilesDatasource payTrackBookingFilesDatasource;
  PayTrackBookingFilesRepositoryImpl({
    required this.payTrackBookingFilesDatasource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getPayTrackBookingFilesBookingFilesList({
    required int pageNumber,
    required int pageSize,
    required String fileType,
    required int bookingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await payTrackBookingFilesDatasource
          .apiCallPullPayTrackBookingFiles(
            pageNumber: pageNumber,
            pageSize: pageSize,
            fileType: fileType,
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
  addUpdatePayTrackBookingFilesBookingFiles({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await payTrackBookingFilesDatasource
          .apiCallAddUpdatePayTrackBookingFiles(body: body, fileList: fileList);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  deletePayTrackBookingFilesBookingFiles({
    required int payTrackBookingFilesId,
    required int projectId,
    required int bookingId,
    required String uniqueKey,
  }) async {
    try {
      var result = await payTrackBookingFilesDatasource
          .apicallDeletePayTrackBookingFiles(
            payTrackBookingFilesId: payTrackBookingFilesId,
            projectId: projectId,
            bookingId: bookingId,
            uniqueKey: uniqueKey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
