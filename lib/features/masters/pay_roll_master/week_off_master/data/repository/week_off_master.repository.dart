import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/data/datasource/week_off_master.datasource.dart';

abstract interface class WeekOffMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getWeekOffList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteWeekOff({
    required int weekOffId,
    required String uniqueKey,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateWeekOff({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> getWeekOffForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class WeekOffMasterRepositoryImp extends WeekOffMasterRepository {
  final WeekOffMasterDataSource weekOffMasterDataSource;
  WeekOffMasterRepositoryImp({required this.weekOffMasterDataSource});

  // ADD / UPDATE WEEK OFF
  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateWeekOff({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await weekOffMasterDataSource.apiCallAddUpdateWeekOff(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // DELETE WEEK OFF
  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteWeekOff({
    required int weekOffId,
    required String uniqueKey,
  }) async {
    try {
      final result = await weekOffMasterDataSource.apiCallDeleteWeekOff(
        weekOffId: weekOffId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // GET WEEK OFF
  @override
  Future<Either<Failure, Map<String, dynamic>>> getWeekOffList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await weekOffMasterDataSource.apiCallPullWeekOff(
        pageNumber: pageNumber,
        pageSize: pageSize,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // EXPORT WEEK OFF
  @override
  Future<Either<Failure, Map<String, dynamic>>> getWeekOffForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await weekOffMasterDataSource.apiCallPullWeekOffForExport(
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
