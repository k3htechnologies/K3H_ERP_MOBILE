import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/datasource/department_master.datasource.dart';

abstract interface class DepartmentMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getDepartmentList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateDepartment({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteDepartment({
    required int departmentMasterId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportDepartment({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class DepartmentMasterRepositoryImpl implements DepartmentMasterRepository {
  final DepartmentMasterDatasource departmentMasterDatasource;

  DepartmentMasterRepositoryImpl({required this.departmentMasterDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDepartmentList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await departmentMasterDatasource.apicallPullDepartmentMaster(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateDepartment({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await departmentMasterDatasource
          .apicallAddUpdateDepartmentMaster(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteDepartment({
    required int departmentMasterId,
    required String uniqueKey,
  }) async {
    try {
      var result = await departmentMasterDatasource
          .apicallDeleteDepartmentMaster(
            departmentMasterId: departmentMasterId,
            uniqueKey: uniqueKey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportDepartment({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await departmentMasterDatasource
          .apicallPullDepartmentMasterForExport(
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
