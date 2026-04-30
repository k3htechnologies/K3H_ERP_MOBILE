import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/data/datasource/grn.datasource.dart';

abstract interface class GrnRepository {
  Future<Either<Failure, Map<String, dynamic>>> getGRNList({
    required int materialRequisitionId,
    required String uniqueyKey,
    required int projectId,
    int? materialGrnId,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateGRN({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteGRN({
    required int materialRequisitionGRNId,
    required String uniqueKey,
    required int materialRequisitionId,
    required int projectId,
  });

  Future<Either<Failure, Map<String, dynamic>>> getGRNSummary({
    required int materialRequisitionId,
    required String uniqueyKey,
  });
}

class GrnRepositoryImpl implements GrnRepository {
  final GrnDatasource grnDatasource;

  GrnRepositoryImpl({required this.grnDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getGRNList({
    required int materialRequisitionId,
    required String uniqueyKey,
    required int projectId,
    int? materialGrnId,
  }) async {
    try {
      var result = await grnDatasource.apiCallToGetAllGRN(
        materialRequisitionId: materialRequisitionId,
        uniqueyKey: uniqueyKey,
        projectId: projectId,
      );

      return right(result);
    } catch (e) {
      return left(Failure(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateGRN({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await grnDatasource.apiCallToAddUpdateGRN(
        body: body,
        fileList: fileList,
      );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteGRN({
    required int materialRequisitionGRNId,
    required String uniqueKey,
    required int materialRequisitionId,
    required int projectId,
  }) async {
    try {
      var result = await grnDatasource.apiCallToDeleteGRN(
        materialRequisitionGRNId: materialRequisitionGRNId,
        uniqueKey: uniqueKey,
        materialRequisitionId: materialRequisitionId,
        projectId: projectId,
      );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getGRNSummary({
    required int materialRequisitionId,
    required String uniqueyKey,
  }) async {
    try {
      var result = await grnDatasource.apicallPullMaterialRequisitionGRNSummary(
        materialRequisitionId: materialRequisitionId,
        uniqueyKey: uniqueyKey,
      );
      return right(result);
    } catch (e) {
      return left(Failure(message: ErrorHandler.getErrorMessage(e)));
    }
  }
}
