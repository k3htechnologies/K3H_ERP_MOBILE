import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/datasource/material_requisition.datasource.dart';

abstract interface class MaterialRequisitionRepository {
  Future<Either<Failure, Map<String, dynamic>>> getMaterialRequisitionList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateMaterialRequisition({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteMaterialRequisition({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportRequisition({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class MaterialRequisitionRepositoryImpl
    implements MaterialRequisitionRepository {
  final MaterialRequisitionDatasource materialRequisitionDatasource;

  MaterialRequisitionRepositoryImpl({
    required this.materialRequisitionDatasource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMaterialRequisitionList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await materialRequisitionDatasource
          .apicallPullMaterialRequisition(
            pageNumber: pageNumber,
            pageSize: pageSize,
            projectId: projectId,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateMaterialRequisition({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await materialRequisitionDatasource
          .apicallAddUpdateMaterialRequisition(body: body, fileList: fileList);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteMaterialRequisition({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  }) async {
    try {
      var result = await materialRequisitionDatasource
          .apicallDeleteMaterialRequisition(
            projectId: projectId,
            materialRequisitionId: materialRequisitionId,
            uniqueKey: uniqueKey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportRequisition({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await materialRequisitionDatasource
          .apicallPullMaterialRequisitionForExport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            projectId: projectId,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
