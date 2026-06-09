import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/data/datasource/call_tracker.datasource.dart';

abstract interface class CallTrackerRepository {
  Future<Either<Failure, Map<String, dynamic>>> getCallingData({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addCallingData({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> getCallLog({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addCallLog({
    required Map<String, String> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> updateCallLog({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteCallLog({
    required int projectId,
    required int callLogId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportCallingData({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportCallLog({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class CallTrackerRepositoryImpl implements CallTrackerRepository {
  final CallTrackerDataSource callTrackerDataSource;

  CallTrackerRepositoryImpl({required this.callTrackerDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCallingData({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await callTrackerDataSource.apicallPullCallingData(
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
  Future<Either<Failure, Map<String, dynamic>>> addCallingData({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await callTrackerDataSource.apicallToAddUpdateCallingData(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCallLog({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await callTrackerDataSource.apicallPullCallLog(
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
  Future<Either<Failure, Map<String, dynamic>>> addCallLog({
    required Map<String, String> body,
  }) async {
    try {
      var result = await callTrackerDataSource.apiCallToAddCallLog(body: body);
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
      var result = await callTrackerDataSource.apiCallToUpdateCallLog(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteCallLog({
    required int projectId,
    required int callLogId,
    required String uniqueKey,
  }) async {
    try {
      var result = await callTrackerDataSource.apicallDeleteCallLog(
        projectId: projectId,
        callLogId: callLogId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportCallingData({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await callTrackerDataSource.apicallPullCallingDataExport(
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
  Future<Either<Failure, Map<String, dynamic>>> exportCallLog({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await callTrackerDataSource.apicallPullCallLogExport(
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
