import 'package:k3h_erp_app/features/procurement/material_requisition/purchase_order/data/model/purchase_order.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';

abstract class PurchaseOrderDatasource {
  Future<Map<String, dynamic>> apiCallToPullMaterialPurchaseOrder({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apiCallToAddUpdateMaterialPurchaseOrder({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apiCallToDeleteMaterialPurchaseOrder({
    required int projectId,
    required int materialRequisitionPOId,
    required String uniqueKey,
    required int materialRequisitionId,
  });

  Future<Map<String, dynamic>>
  apicallGenerateMaterialRequisitionPurchaseOrderPdf({
    required Map<String, dynamic> body,
  });
}

class PurchaseOrderDatasourceImpl implements PurchaseOrderDatasource {
  final baseClient = BaseClient();
  @override
  Future<Map<String, dynamic>> apiCallToPullMaterialPurchaseOrder({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  }) async {
    try {
      String pullMaterialPurchaseOrderUrl({
        required int projectId,
        required int materialRequisitionId,
        required String uniqueKey,
        Map<String, dynamic>? queryParams,
      }) {
        String url =
            "MaterialRequisitionPurchaseOrder/PullMaterialRequisitionPurchaseOrder?MaterialRequisitionId=$materialRequisitionId&Uniquekey=$uniqueKey&ProjectId=$projectId";
        queryParams?.forEach((key, value) => url += "&$key=$value");
        return url;
      }

      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullMaterialPurchaseOrderUrl(
          projectId: projectId,
          materialRequisitionId: materialRequisitionId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': List<PurchaseOrderModel>.from(
          networkResponse["data"].map((e) => PurchaseOrderModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallToAddUpdateMaterialPurchaseOrder({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      String addUpdateMaterialPurchaseOrderUrl =
          "MaterialRequisitionPurchaseOrder/AddUpdateMaterialRequisitionPurchaseOrder";
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateMaterialPurchaseOrderUrl,
            fileList,
            body,
          );
      var list = List<PurchaseOrderModel>.from(
        networkResponse['data'].map((x) => PurchaseOrderModel.fromJson(x)),
      );
      return {'data': list, 'message': networkResponse['message']};
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallToDeleteMaterialPurchaseOrder({
    required int projectId,
    required int materialRequisitionPOId,
    required String uniqueKey,
    required int materialRequisitionId,
  }) async {
    try {
      String generateMaterialRequisitionPurchaseOrderPdf =
          "MaterialRequisitionPurchaseOrder/DeleteMaterialRequisitionPurchaseOrder?ProjectId=$projectId&MaterialRequisitionPurchaseOrderId=$materialRequisitionPOId&Uniquekey=$uniqueKey&MaterialRequisitionId=$materialRequisitionId";
      var networResponse = await baseClient.deleteRequestWithAuthentication(
        generateMaterialRequisitionPurchaseOrderPdf,
      );

      return {'message': networResponse['message']};
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>>
  apicallGenerateMaterialRequisitionPurchaseOrderPdf({
    required Map<String, dynamic> body,
  }) async {
    try {
      String generateMaterialRequisitionPurchaseOrderPdf =
          "MaterialRequisitionPurchaseOrder/GenerateMaterialRequisitionPurchaseOrderPdf";
      var networkResponse = await baseClient.postRequestWithAuthentication(
        generateMaterialRequisitionPurchaseOrderPdf,
        body,
      );

      return {
        'data': List<PurchaseOrderModel>.from(
          networkResponse["data"].map((e) => PurchaseOrderModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }
}
