import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/data/datasource/material_master.datasource.dart';

abstract interface class MaterialMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getMaterialList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateMaterial({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteMaterial({
    required int materialMasterId,
    required String uniqueKey,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportMaterial({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class MaterialMasterRepositoryImpl implements MaterialMasterRepository {
  final MaterialMasterDatasource materialMasterDatasource;
  MaterialMasterRepositoryImpl({required this.materialMasterDatasource});
  @override
  Future<Either<Failure, Map<String, dynamic>>> getMaterialList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await materialMasterDatasource.apicallPullMaterialMaster(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateMaterial({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await materialMasterDatasource
          .apicallAddUpdateMaterialMaster(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteMaterial({
    required int materialMasterId,
    required String uniqueKey,
  }) async {
    try {
      var result = await materialMasterDatasource.apicallDeleteMaterialMaster(
        materialMasterId: materialMasterId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportMaterial({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await materialMasterDatasource
          .apicallPullMaterialMasterForExport(
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
