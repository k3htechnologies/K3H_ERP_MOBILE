import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/data/datasource/outdoor.datasource.dart';

abstract interface class OutdoorRepository {
  Future<Either<Failure, Map<String, dynamic>>> getOutdoorList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addOutdoorAttendance({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateConclusion({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateOutdoor({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportOutdoor({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class OutdoorRepositoryImpl implements OutdoorRepository {
  final OutdoorDatasource outdoorDatasource;

  OutdoorRepositoryImpl({required this.outdoorDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getOutdoorList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await outdoorDatasource.apicallPullOutdoor(
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
  Future<Either<Failure, Map<String, dynamic>>> addOutdoorAttendance({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await outdoorDatasource.apicallAddOutdoorAttendance(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateConclusion({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await outdoorDatasource.apicallAddUpdateConclusion(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateOutdoor({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await outdoorDatasource.apicallAddUpdateOutdoor(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportOutdoor({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await outdoorDatasource.apicallPullOutdoorForExport(
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
