import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/payroll/leave/data/datasource/leave.datasource.dart';

abstract interface class LeaveRepository {
  Future<Either<Failure, Map<String, dynamic>>> getLeaveList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateLeave({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteLeave({
    required int leaveTypeMasterId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportLeave({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class LeaveRepositoryImpl implements LeaveRepository {
  final LeaveDatasource leaveDatasource;

  LeaveRepositoryImpl({required this.leaveDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLeaveList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await leaveDatasource.apicallPullLeave(
        pageNumber: pageNumber,
        pageSize: pageSize,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateLeave({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await leaveDatasource.apicallAddUpdateLeave(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteLeave({
    required int leaveTypeMasterId,
    required String uniqueKey,
  }) async {
    try {
      var result = await leaveDatasource.apicallDeleteLeave(
        leaveTypeMasterId: leaveTypeMasterId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportLeave({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await leaveDatasource.apicallPullLeaveForExport(
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
