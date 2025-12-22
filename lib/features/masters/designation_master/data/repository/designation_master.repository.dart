import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/datasource/designation_master.datasource.dart';

abstract interface class DesignationMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getDesignationList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateDesignation({
    required Map<String, dynamic> requestBody,
  });

  Future<Either<Failure, int>> deleteDesignation({
    required int designationtMasterId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportDesignation({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> getModulesPermissionsList({
    required int designationMasterId,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateModulePermissions({
    required Map<String, dynamic> requestBody,
  });
}

class DesignationRepositoryImpl implements DesignationMasterRepository {
  final DesignationMasterDatasource designationMasterDatasource;

  DesignationRepositoryImpl(this.designationMasterDatasource);

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateDesignation({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      var result = await designationMasterDatasource
          .apicallAddUpdateDesignationMaster(requestBody: requestBody);
      return right(result);
    } catch (error) {
      return left(Failure(
        message: ErrorHandler.getErrorMessage(error),
        isMenuChanged: ErrorHandler.isMenuChangedException(error),
      ));
    }
  }

  @override
  Future<Either<Failure, int>> deleteDesignation({
    required int designationtMasterId,
    required String uniqueKey,
  }) async {
    try {
      var result = await designationMasterDatasource
          .apicallDeleteDesignationMaster(
            designationMasterId: designationtMasterId,
            uniqueKey: uniqueKey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(
        message: ErrorHandler.getErrorMessage(error),
        isMenuChanged: ErrorHandler.isMenuChangedException(error),
      ));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDesignationList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await designationMasterDatasource
          .apicallPullDesignationMaster(
            pageNumber: pageNumber,
            pageSize: pageSize,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(
        message: ErrorHandler.getErrorMessage(error),
        isMenuChanged: ErrorHandler.isMenuChangedException(error),
      ));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportDesignation({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await designationMasterDatasource
          .apicallPullDesignationMasterForExport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(
        message: ErrorHandler.getErrorMessage(error),
        isMenuChanged: ErrorHandler.isMenuChangedException(error),
      ));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getModulesPermissionsList({
    required int designationMasterId,
  }) async {
    try {
      var result = await designationMasterDatasource
          .apiCallPullModulePermissions(
            designationMasterId: designationMasterId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(
        message: ErrorHandler.getErrorMessage(error),
        isMenuChanged: ErrorHandler.isMenuChangedException(error),
      ));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateModulePermissions({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      var result = await designationMasterDatasource
          .apiCallToAddUpdateModulePermissions(requestBody: requestBody);
      return right(result);
    } catch (error) {
      return left(Failure(
        message: ErrorHandler.getErrorMessage(error),
        isMenuChanged: ErrorHandler.isMenuChangedException(error),
      ));
    }
  }
}
