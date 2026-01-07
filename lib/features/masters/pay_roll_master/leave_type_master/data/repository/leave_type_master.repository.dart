import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/datasource/leave_type_master.datasource.dart';

abstract interface class LeaveTypeMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getLeaveTypeList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteLeaveType({
    required int leaveTypeId,
    required String uniqueKey,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateLeaveType({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> getLeaveTypeForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class LeaveTypeMasterRepositoryImp extends LeaveTypeMasterRepository {
  final LeaveTypeMasterDataSource leaveTypeMasterDataSource;
  LeaveTypeMasterRepositoryImp({required this.leaveTypeMasterDataSource});

  // ADD / UPDATE LEAVE TYPE
  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateLeaveType({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await leaveTypeMasterDataSource.apiCallAddUpdateLeaveType(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // DELETE LEAVE TYPE
  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteLeaveType({
    required int leaveTypeId,
    required String uniqueKey,
  }) async {
    try {
      final result = await leaveTypeMasterDataSource.apiCallDeleteLeaveType(
        leaveTypeId: leaveTypeId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // GET LEAVE TYPE
  @override
  Future<Either<Failure, Map<String, dynamic>>> getLeaveTypeList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await leaveTypeMasterDataSource.apiCallPullLeaveType(
        pageNumber: pageNumber,
        pageSize: pageSize,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // EXPORT LEAVE TYPE
  @override
  Future<Either<Failure, Map<String, dynamic>>> getLeaveTypeForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await leaveTypeMasterDataSource
          .apiCallPullLeaveTypeForExport(
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
