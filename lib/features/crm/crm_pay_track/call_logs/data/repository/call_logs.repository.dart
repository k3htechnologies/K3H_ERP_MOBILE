import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/call_logs/data/datasource/call_logs.datasource.dart';

abstract interface class CallLogsRepository {
  Future<Either<Failure, Map<String, dynamic>>> getCallLog({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteCallLogs({
    required int payTrackCallLogId,
    required String uniqueKey,
    required int projectId,
    required int bookingId,
  });
  Future<Either<Failure, Map<String, dynamic>>> updateCallLog({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> getCallLogsForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class CallLogsRepositoryImpl extends CallLogsRepository {
  final CallLogsDatasource callLogsDatasource;
  CallLogsRepositoryImpl({required this.callLogsDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCallLog({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await callLogsDatasource.apiCallPullCallLog(
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
  Future<Either<Failure, Map<String, dynamic>>> deleteCallLogs({
    required int payTrackCallLogId,
    required String uniqueKey,
    required int projectId,
    required int bookingId,
  }) async {
    try {
      var result = await callLogsDatasource.apicallDeleteCallLogs(
        payTrackCallLogId: payTrackCallLogId,
        uniqueKey: uniqueKey,
        projectId: projectId,
        bookingId: bookingId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateCallLog({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await callLogsDatasource.apiCallToUpdateCallLog(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCallLogsForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await callLogsDatasource.apiCallPullCallLogsForExport(
        pageNumber: pageNumber,
        pageSize: pageSize,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
