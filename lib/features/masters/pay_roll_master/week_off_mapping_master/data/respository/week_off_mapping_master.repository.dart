import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/data/datasource/week_off_mapping_master.datasource.dart';

abstract interface class WeekOffMappingMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getWeekOffMappingList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteWeekOffMapping({
    required int weekOffMappingId,
    required String uniqueKey,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateWeekOffMapping({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> getWeekOffMappingForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class WeekOffMappingMasterRepositoryImp extends WeekOffMappingMasterRepository {
  final WeekOffMappingMasterDataSource weekOffMasterDataSource;
  WeekOffMappingMasterRepositoryImp({required this.weekOffMasterDataSource});

  // ADD / UPDATE WEEK OFF MAPPING
  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateWeekOffMapping({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await weekOffMasterDataSource.apiCallAddUpdateMappedWeekOff(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // DELETE WEEK OFF MAPPING
  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteWeekOffMapping({
    required int weekOffMappingId,
    required String uniqueKey,
  }) async {
    try {
      final result = await weekOffMasterDataSource.apiCallDeleteMappedWeekOff(
        weekOffMasterMappingId: weekOffMappingId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // GET WEEK OFF MAPPING
  @override
  Future<Either<Failure, Map<String, dynamic>>> getWeekOffMappingList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await weekOffMasterDataSource
          .apiCallPullWeekOffMappedWeekOff(
            pageNumber: pageNumber,
            pageSize: pageSize,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // EXPORT WEEK OFF MAPPING
  @override
  Future<Either<Failure, Map<String, dynamic>>> getWeekOffMappingForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await weekOffMasterDataSource
          .apiCallPullMappedWeekOffsForExport(
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
