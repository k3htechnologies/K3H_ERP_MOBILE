import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/project_setup_status.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class MaterialRequisitionDatasource {
  Future<Map<String, dynamic>> apicallPullMaterialRequisition({
    required int pageNumber,
    required int pageSize,
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
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullCheckProjectSetupStatus({
    required int projectId,
    required String pageName,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullMaterialRequisitionDetails({
    required int materialRequisitionId,
    required int projectId,
  });
}

class MaterialRequisitionDataSourceImpl
    implements MaterialRequisitionDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullMaterialRequisition({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      String pullmaterialRequisitionUrl({
        required int pageSize,
        required int pageNumber,
        Map<String, dynamic>? queryParams,
      }) {
        String url =
            "MaterialRequisition/PullMaterialRequisition?PageSize=$pageSize&PageNumber=$pageNumber";
        url += queryParamsFormatter(queryParams: queryParams);
        return url;
      }

      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullmaterialRequisitionUrl(
          pageNumber: pageNumber,
          pageSize: pageSize,
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
      if (error is TokenExpiredException) {
        apicallPullMaterialRequisition(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
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
      if (error is TokenExpiredException) {
        apicallDeleteMaterialRequisition(
          projectId: projectId,
          materialRequisitionId: materialRequisitionId,
          uniqueKey: uniqueKey,
        );
      }
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
      if (error is TokenExpiredException) {
        apicallCloseMaterialRequisition(
          materialRequisitionId: materialRequisitionId,
          uniqueKey: uniqueKey,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullMaterialRequisitionForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullmaterialRequisitionUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "MaterialRequisition/PullMaterialRequisition?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullmaterialRequisitionUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );

      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullMaterialRequisitionForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullCheckProjectSetupStatus({
    required int projectId,
    required String pageName,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      String pullCheckProjectSetupStatusUrl({
        required int projectId,
        required String pageName,
        Map<String, dynamic>? queryParams,
      }) {
        String url =
            "Project/CheckProjectSetupStatus?PageName=$pageName&ProjectId=$projectId";
        url += queryParamsFormatter(queryParams: queryParams);
        return url;
      }

      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullCheckProjectSetupStatusUrl(
          projectId: projectId,
          pageName: pageName,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<ProjectSetupStatusModel>.from(
          networkResponse["data"].map(
            (e) => ProjectSetupStatusModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullMaterialRequisitionDetails({
    required int materialRequisitionId,
    required int projectId,
  }) async {
    try {
      String url =
          "MaterialRequisition/PullMaterialRequisitionDetails"
          "?MaterialRequisitionId=$materialRequisitionId"
          "&ProjectId=$projectId";

      var networkResponse = await baseClient.getRequestWithAuthentication(url);

      return {
        'data': List<MaterialRequisitionModel>.from(
          networkResponse["data"].map(
            (e) => MaterialRequisitionModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return await apicallPullMaterialRequisitionDetails(
          materialRequisitionId: materialRequisitionId,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }
}
