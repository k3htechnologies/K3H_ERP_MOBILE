import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/data/datasource/shift_master_mapping.datasource.dart';

abstract interface class ShiftMappingMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getShiftMasterMappedList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateShiftMapping({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteShiftMapping({
    required int shiftMasterMappingId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  getShiftMasterMappedListForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportBranch({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class ShiftMappingMasterRepositoryImpl extends ShiftMappingMasterRepository {
  final ShiftMappingMasterDatasource shiftMasterMappingDatasource;

  ShiftMappingMasterRepositoryImpl({
    required this.shiftMasterMappingDatasource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getShiftMasterMappedList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await shiftMasterMappingDatasource
          .apiCallPullShiftMappedShift(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateShiftMapping({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await shiftMasterMappingDatasource
          .apiCallAddUpdateMappedShift(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteShiftMapping({
    required int shiftMasterMappingId,
    required String uniqueKey,
  }) async {
    try {
      var result = await shiftMasterMappingDatasource.apiCallDeleteMappedShift(
        shiftMasterMappingId: shiftMasterMappingId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getShiftMasterMappedListForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await shiftMasterMappingDatasource
          .apiCallPullMappedShiftsForExport(
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
  Future<Either<Failure, Map<String, dynamic>>> exportBranch({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await shiftMasterMappingDatasource
          .apiCallPullMappedShiftsForExport(
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
