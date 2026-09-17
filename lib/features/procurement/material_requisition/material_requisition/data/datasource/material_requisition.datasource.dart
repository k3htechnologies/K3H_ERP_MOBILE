import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class MaterialRequisitionDatasource {
  Future<Map<String, dynamic>> apicallPullMaterialRequisition({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateMaterialRequisition({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeleteMaterialRequisition({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  });
  Future<Map<String, dynamic>> apicallCloseMaterialRequisition({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallPullMaterialRequisitionForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class MaterialRequisitionDataSourceImpl
    implements MaterialRequisitionDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullMaterialRequisition({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      String pullmaterialRequisitionUrl({
        required int pageSize,
        required int pageNumber,
        required int projectId,
        Map<String, dynamic>? queryParams,
      }) {
        String url =
            "MaterialRequisition/PullMaterialRequisition?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
        url += queryParamsFormatter(queryParams: queryParams);
        return url;
      }

      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullmaterialRequisitionUrl(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<MaterialRequisitionModel>.from(
          networkResponse["data"].map(
            (e) => MaterialRequisitionModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateMaterialRequisition({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdatelmaterialRequisitionUrl =
        "MaterialRequisition/AddUpdateMaterialRequisition";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdatelmaterialRequisitionUrl,
            fileList,
            body,
          );
      return {
        'data': List<MaterialRequisitionModel>.from(
          networkResponse["data"].map(
            (e) => MaterialRequisitionModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateMaterialRequisition(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteMaterialRequisition({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  }) async {
    String deleteMaterialRequisitionUrl =
        "MaterialRequisition/DeleteMaterialRequisition?MaterialRequisitionId=$materialRequisitionId&Uniquekey=$uniqueKey&ProjectId=$projectId";

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteMaterialRequisitionUrl,
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallCloseMaterialRequisition({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  }) async {
    String closeMaterialRequisitionUrl =
        "MaterialRequisition/CloseMaterialRequisition";
    try {
      final payload = {
        "MaterialRequisitionId": materialRequisitionId,
        "Uniquekey": uniqueKey,
        "ProjectId": projectId,
      };
      var networkResponse = await baseClient.postRequestWithAuthentication(
        closeMaterialRequisitionUrl,
        payload,
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullMaterialRequisitionForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullmaterialRequisitionUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "MaterialRequisition/PullMaterialRequisition?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullmaterialRequisitionUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }
}
