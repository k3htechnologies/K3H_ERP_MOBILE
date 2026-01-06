import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';

import '../datasource/leave_encashment_master.datasource.dart';

abstract interface class LeaveEncashmentMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getLeaveEncashmentList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteLeaveEncashment({
    required int slabsId,
    required String uniqueKey,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateLeaveEncashment({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> getLeaveEncashmentForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class LeaveEncashmentMasterRepositoryImp
    extends LeaveEncashmentMasterRepository {
  final LeaveEncashmentMasterDataSource leaveEncashmentMasterDataSource;
  LeaveEncashmentMasterRepositoryImp({
    required this.leaveEncashmentMasterDataSource,
  });

  // GET LEAVE ENCASHMENT
  @override
  Future<Either<Failure, Map<String, dynamic>>> getLeaveEncashmentList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await leaveEncashmentMasterDataSource
          .apiCallPullLeaveEncashment(
            pageNumber: pageNumber,
            pageSize: pageSize,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // DELETE LEAVE ENCASHMENT
  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteLeaveEncashment({
    required int slabsId,
    required String uniqueKey,
  }) async {
    try {
      var result = await leaveEncashmentMasterDataSource
          .apiCallDeleteLeaveEncashment(
            leaveEncashmentSlabsId: slabsId,
            uniqueKey: uniqueKey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  //ADD / UPDATE LEAVE ENCASHMENT
  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateLeaveEncashment({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await leaveEncashmentMasterDataSource
          .apiCallAddUpdateLeaveEncashment(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // EXPORT LEAVE ENCASHMENT
  @override
  Future<Either<Failure, Map<String, dynamic>>> getLeaveEncashmentForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await leaveEncashmentMasterDataSource
          .apiCallPullLeaveEncashmentForExport(
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
