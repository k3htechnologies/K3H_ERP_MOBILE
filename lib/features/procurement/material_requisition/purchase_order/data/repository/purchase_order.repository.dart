import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/purchase_order/data/datasource/purchase_order.datasource.dart';

abstract interface class PurchaseOrderRepository {
  Future<Either<Failure, Map<String, dynamic>>> getPurchaseOrder({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdatePurchaseOrder({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deletePurchaseOrder({
    required int projectId,
    required int materialRequisitionPOId,
    required String uniqueKey,
    required int materialRequisitionId,
  });

  Future<Either<Failure, Map<String, dynamic>>> generatePurchaseOrder({
    required Map<String, dynamic> body,
  });
}

class PurchaseOrderRepositoryImpl implements PurchaseOrderRepository {
  final PurchaseOrderDatasource purchaseOrderDatasource;

  const PurchaseOrderRepositoryImpl({required this.purchaseOrderDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPurchaseOrder({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  }) async {
    try {
      var result = await purchaseOrderDatasource
          .apiCallToPullMaterialPurchaseOrder(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdatePurchaseOrder({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await purchaseOrderDatasource
          .apiCallToAddUpdateMaterialPurchaseOrder(
            body: body,
            fileList: fileList,
          );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deletePurchaseOrder({
    required int projectId,
    required int materialRequisitionPOId,
    required String uniqueKey,
    required int materialRequisitionId,
  }) async {
    try {
      var result = await purchaseOrderDatasource
          .apiCallToDeleteMaterialPurchaseOrder(
            projectId: projectId,
            materialRequisitionPOId: materialRequisitionPOId,
            uniqueKey: uniqueKey,
            materialRequisitionId: materialRequisitionId,
          );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> generatePurchaseOrder({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await purchaseOrderDatasource
          .apicallGenerateMaterialRequisitionPurchaseOrderPdf(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
