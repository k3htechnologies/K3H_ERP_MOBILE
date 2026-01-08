import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/data/datasource/shift_master.datasource.dart';

abstract interface class ShiftMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getShiftList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteShift({
    required int shiftId,
    required String uniqueKey,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateShift({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> getShiftForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class ShiftMasterRepositoryImp extends ShiftMasterRepository {
  final ShiftMasterDataSource shiftMasterDataSource;
  ShiftMasterRepositoryImp({required this.shiftMasterDataSource});

  // ADD / UPDATE SHIFT
  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateShift({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await shiftMasterDataSource.apiCallAddUpdateShift(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // DELETE SHIFT
  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteShift({
    required int shiftId,
    required String uniqueKey,
  }) async {
    try {
      final result = await shiftMasterDataSource.apiCallDeleteShift(
        shiftId: shiftId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // GET SHIFT
  @override
  Future<Either<Failure, Map<String, dynamic>>> getShiftList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await shiftMasterDataSource.apiCallPullShift(
        pageNumber: pageNumber,
        pageSize: pageSize,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // EXPORT SHIFT
  @override
  Future<Either<Failure, Map<String, dynamic>>> getShiftForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await shiftMasterDataSource.apiCallPullShiftForExport(
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
