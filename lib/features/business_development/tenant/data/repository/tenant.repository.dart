import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/business_development/tenant/data/datasource/tenant.datasource.dart';

abstract interface class TenantRepository {
  Future<Either<Failure, Map<String, dynamic>>> getTenantList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> getTenantDocumentList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateTenant({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateTenantDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteTenant({
    required int tenantId,
    required String uniquekey,
    required int projectId,
    required int buildingId,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteTenantDocument({
    required int tenantDocumentId,
    required String uniquekey,
    required int projectId,
    required int buildingId,
    required int tenantId,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportTenant({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });
}

class TenantRepositoryImpl implements TenantRepository {
  final TenantDatasource tenantDatasource;
  TenantRepositoryImpl({required this.tenantDatasource});
  @override
  Future<Either<Failure, Map<String, dynamic>>> getTenantList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await tenantDatasource.apicallPullTenant(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
        buildingId: buildingId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (e) {
      return left(Failure(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTenantDocumentList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await tenantDatasource.apicallPullTenantDocument(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
        buildingId: buildingId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (e) {
      return left(Failure(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateTenant({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await tenantDatasource.apicallAddUpdateTenant(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (e) {
      return left(Failure(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateTenantDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await tenantDatasource.apicallAddUpdateTenantDocument(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (e) {
      return left(Failure(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteTenant({
    required int tenantId,
    required String uniquekey,
    required int projectId,
    required int buildingId,
  }) async {
    try {
      var result = await tenantDatasource.apicallDeleteTenant(
        tenantId: tenantId,
        uniqueKey: uniquekey,
        projectId: projectId,
        buildingId: buildingId,
      );
      return right(result);
    } catch (e) {
      return left(Failure(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteTenantDocument({
    required int tenantDocumentId,
    required String uniquekey,
    required int projectId,
    required int buildingId,
    required int tenantId,
  }) async {
    try {
      var result = await tenantDatasource.apicallDeleteTenantDocument(
        tenantDocumentId: tenantDocumentId,
        uniqueKey: uniquekey,
        projectId: projectId,
        buildingId: buildingId,
        tenantId: tenantId,
      );
      return right(result);
    } catch (e) {
      return left(Failure(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportTenant({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await tenantDatasource.apicallPullTenantForExport(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
        buildingId: buildingId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
