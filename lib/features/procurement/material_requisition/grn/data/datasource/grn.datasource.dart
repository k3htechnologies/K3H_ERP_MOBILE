import 'package:k3h_erp_app/features/procurement/material_requisition/grn/data/model/grn.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';

abstract interface class GrnDatasource {
  Future<Map<String, dynamic>> apiCallToGetAllGRN({
    required int materialRequisitionId,
    required String uniqueyKey,
    required int projectId,
    int? materialGrnId,
  });

  Future<Map<String, dynamic>> apiCallToAddUpdateGRN({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apiCallToDeleteGRN({
    required int materialRequisitionGRNId,
    required String uniqueKey,
    required int materialRequisitionId,
  });

  Future<Map<String, dynamic>> apicallPullMaterialRequisitionGRNSummary({
    required int materialRequisitionId,
    required String uniqueyKey,
  });
}

class GrnDatasourceImpl implements GrnDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallToGetAllGRN({
    required int materialRequisitionId,
    required String uniqueyKey,
    required int projectId,
    int? materialGrnId,
  }) async {
    try {
      String pullGetAllGRNUrl({
        required int materialRequisitionId,
        required String uniqueyKey,
        required int projectId,
        int? materialGrnId,
        Map<String, dynamic>? queryParams,
      }) {
        String url =
            "MaterialRequisitionGRN/PullMaterialRequisitionGRN?MaterialRequisitionId=$materialRequisitionId&Uniquekey=$uniqueyKey&ProjectId=$projectId";
        queryParams?.forEach((key, value) => url += "&$key=$value");
        return url;
      }

      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullGetAllGRNUrl(
          materialRequisitionId: materialRequisitionId,
          uniqueyKey: uniqueyKey,
          projectId: projectId,
        ),
      );
      return {
        'data': List<GRNModel>.from(
          networkResponse["data"].map((e) => GRNModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallToAddUpdateGRN({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      String addUpdateGRN =
          "MaterialRequisitionGRN/AddUpdateMaterialRequisitionGRN";
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateGRN,
            fileList,
            body,
          );
      return {
        "message": networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallToDeleteGRN({
    required int materialRequisitionGRNId,
    required String uniqueKey,
    required int materialRequisitionId,
  }) async {
    try {
      String deleteGRNUrl =
          "MaterialRequisitionGRN/DeleteMaterialRequisitionGRN??MaterialRequisitionGRNId=$materialRequisitionGRNId&Uniquekey=$uniqueKey&MaterialRequisitionId=$materialRequisitionId";
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteGRNUrl,
      );
      return {
        "message": networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullMaterialRequisitionGRNSummary({
    required int materialRequisitionId,
    required String uniqueyKey,
  }) async {
    try {
      String pullMaterialRequisitionGRNSummaryUrl =
          "MaterialRequisitionGRN/PullMaterialRequisitionGRNSummary?MaterialRequisitionId=$materialRequisitionId&Uniquekey=$uniqueyKey";
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullMaterialRequisitionGRNSummaryUrl,
      );
      return {
        'data': List<MaterialRequisitionDetailModel>.from(
          networkResponse["data"].map(
            (e) => MaterialRequisitionDetailModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (e) {
      rethrow;
    }
  }
}
