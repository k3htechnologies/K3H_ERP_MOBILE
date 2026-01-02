import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/data/datasource/holiday_master.datasource.dart';

abstract interface class HolidayMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getHolidayList({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportHolidayList({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateHoliday({
    required List<Map<String, dynamic>> fileList,
    required Map<String, String> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteHoliday({
    required int holidayMasterId,
    required String uniqueKey,
  });
}

class HolidayMasterRepositoryImpl extends HolidayMasterRepository {
  final HolidayMasterDataSource holidayMasterDataSource;

  HolidayMasterRepositoryImpl({required this.holidayMasterDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getHolidayList({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await holidayMasterDataSource.pullHolidays(
        pageSize: pageSize,
        pageNumber: pageNumber,
        queryParams: queryParams,
      );

      return right(result);
    } catch (e) {
      return left(Failure(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportHolidayList({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await holidayMasterDataSource.pullHolidaysForExport(
        pageSize: pageSize,
        pageNumber: pageNumber,
        queryParams: queryParams,
      );
      return right(result);
    } catch (e) {
      return left(Failure(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateHoliday({
    required List<Map<String, dynamic>> fileList,
    required Map<String, String> body,
  }) async {
    try {
      var result = await holidayMasterDataSource.appUpdateHoliday(
        fileList: fileList,
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteHoliday({
    required int holidayMasterId,
    required String uniqueKey,
  }) async {
    try {
      var result = await holidayMasterDataSource.deleteHoliday(
        holidayMasterId: holidayMasterId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
