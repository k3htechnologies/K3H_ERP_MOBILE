import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/data/datasource/holiday_mapping_maaster.datasource.dart';

abstract interface class HolidayMappingMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getMappedHolidayList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateMappedHoliday({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteMappedHoliday({
    required int holidayMappingMasterId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportHolidayMappings({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class HolidayMappingMasterRepositoryImpl
    extends HolidayMappingMasterRepository {
  final HolidayMappingMasterDatasource holidayMappingMasterDatasource;

  HolidayMappingMasterRepositoryImpl({
    required this.holidayMappingMasterDatasource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMappedHolidayList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await holidayMappingMasterDatasource
          .apiCallPullHolidayMapping(
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
  Future<Either<Failure, Map<String, dynamic>>> deleteMappedHoliday({
    required int holidayMappingMasterId,
    required String uniqueKey,
  }) async {
    try {
      var result = await holidayMappingMasterDatasource
          .apicallDeleteHolidayMapping(
            holidayMappingMasterId: holidayMappingMasterId,
            uniqueKey: uniqueKey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportHolidayMappings({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await holidayMappingMasterDatasource
          .apicallPullHolidayMappingForExport(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateMappedHoliday({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await holidayMappingMasterDatasource
          .apicallAddUpdateHolidayMapping(body: body, fileList: fileList);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
