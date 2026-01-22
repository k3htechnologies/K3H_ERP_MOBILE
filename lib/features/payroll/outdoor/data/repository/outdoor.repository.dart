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
  //
  // Future<Either<Failure, Map<String, dynamic>>> deleteDepartment({
  //   required int departmentMasterId,
  //   required String uniqueKey,
  // });

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
  //
  // @override
  // Future<Either<Failure, Map<String, dynamic>>> deleteDepartment({
  //   required int departmentMasterId,
  //   required String uniqueKey,
  // }) async {
  //   try {
  //     var result = await departmentMasterDatasource
  //         .apicallDeleteDepartmentMaster(
  //       departmentMasterId: departmentMasterId,
  //       uniqueKey: uniqueKey,
  //     );
  //     return right(result);
  //   } catch (error) {
  //     return left(Failure(message: ErrorHandler.getErrorMessage(error)));
  //   }
  // }

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
