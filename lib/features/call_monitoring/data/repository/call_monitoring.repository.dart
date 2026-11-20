import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/call_monitoring/data/datasource/call_monitoring.datasource.dart';

abstract interface class CallMonitoringRepository {
  Future<Either<Failure, Map<String, dynamic>>> getCallMonitoring({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int id,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteCallMonitoring({
    required int callMonitoringId,
    required String uniqueKey,
    required int projectId,
  });
  Future<Either<Failure, Map<String, dynamic>>> addCallMonitoring({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> updateCallMonitoring({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> getCallMonitoringForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class CallMonitoringRepositoryImpl extends CallMonitoringRepository {
  final CallMonitoringDatasource callMonitoringDatasource;
  CallMonitoringRepositoryImpl({required this.callMonitoringDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCallMonitoring({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int id,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await callMonitoringDatasource.apiCallPullCallMonitoring(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
        queryParams: queryParams,
        id: id,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteCallMonitoring({
    required int callMonitoringId,
    required String uniqueKey,
    required int projectId,
  }) async {
    try {
      var result = await callMonitoringDatasource.apicallDeleteCallMonitoring(
        callMonitoringId: callMonitoringId,
        uniqueKey: uniqueKey,
        projectId: projectId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addCallMonitoring({
    required Map<String, dynamic> body,
  }) async {
    try {
      final result = await callMonitoringDatasource.apiCallToAddCallMonitoring(
        body: body,
      );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateCallMonitoring({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await callMonitoringDatasource.apiCallToUpdateCallMonitoring(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCallMonitoringForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await callMonitoringDatasource
          .apiCallPullCallMonitoringForExport(
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
