import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building_document.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class BuildingDatasource {
  Future<Map<String, dynamic>> apicallPullBuilding({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullBuildingDetails({
    required int buildingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullBuildingDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateBuildingDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallAddUpdateBuilding({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallAddUpdateBuildingDetails({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallPullBuildingForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallDeleteBuilding({
    required int buildingId,
    required String uniqueKey,
    required int projectId,
  });
  Future<Map<String, dynamic>> apicallDeleteBuildingDocument({
    required int buildingId,
    required String uniqueKey,
    required int projectId,
    required int buildingDocumentId,
  });
}

class BuildingDatasourceImpl implements BuildingDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullBuilding({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullBuildingUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Building/PullBuilding?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullBuildingUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<RedevelopmentBuildingModel>.from(
          networkResponse["data"].map(
            (e) => RedevelopmentBuildingModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullBuilding(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullBuildingDetails({
    required int buildingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullBuildingDetailsUrl({
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "BuildingDetails/PullBuildingDetails?ProjectId=$projectId&BuildingId=$buildingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullBuildingDetailsUrl(
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<BuildingDetailsModel>.from(
          networkResponse["data"].map((e) => BuildingDetailsModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullBuildingDetails(
          buildingId: buildingId,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullBuildingDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullBuildingDocumentUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "BuildingDocument/PullBuildingDocument?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&BuildingId=$buildingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullBuildingDocumentUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<BuildingDocumentModel>.from(
          networkResponse["data"].map((e) => BuildingDocumentModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullBuildingDocument(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateBuildingDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateBuildingDocumentUrl =
        "BuildingDocument/AddUpdateBuildingDocument";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateBuildingDocumentUrl,
            fileList,
            body,
          );
      return {
        'data': List<BuildingDocumentModel>.from(
          networkResponse["data"].map((e) => BuildingDocumentModel.fromJson(e)),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateBuildingDocument(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateBuilding({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateBuildingUrl = "Building/AddUpdateBuilding";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateBuildingUrl,
        body,
      );
      return {
        'data': List<RedevelopmentBuildingModel>.from(
          networkResponse["data"].map(
            (e) => RedevelopmentBuildingModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateBuilding(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateBuildingDetails({
    required Map<String, dynamic> body,
  }) async {
    try {
      String addUpdateBuildingDetailsUrl =
          "BuildingDetails/AddUpdateBuildingDetails";

      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateBuildingDetailsUrl,
        body,
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
  Future<Map<String, dynamic>> apicallPullBuildingForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullBuildingExportUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Building/PullBuilding?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullBuildingExportUrl(
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
      if (error is TokenExpiredException) {
        apicallPullBuildingForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteBuilding({
    required int buildingId,
    required String uniqueKey,
    required int projectId,
  }) async {
    String deleteBuildingUrl({
      required int buildingId,
      required String uniqueKey,
      required int projectId,
    }) {
      return "Building/DeleteBuilding?BuildingId=$buildingId&Uniquekey=$uniqueKey&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteBuildingUrl(
          buildingId: buildingId,
          uniqueKey: uniqueKey,
          projectId: projectId,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteBuilding(
          buildingId: buildingId,
          uniqueKey: uniqueKey,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteBuildingDocument({
    required int buildingId,
    required String uniqueKey,
    required int projectId,
    required int buildingDocumentId,
  }) async {
    String deleteBuildingDocumentUrl({
      required int buildingId,
      required String uniqueKey,
      required int projectId,
      required int buildingDocumentId,
    }) {
      return "BuildingDocument/DeleteBuildingDocument?BuildingDocumentId=$buildingDocumentId&BuildingId=$buildingId&Uniquekey=$uniqueKey&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteBuildingDocumentUrl(
          buildingId: buildingId,
          uniqueKey: uniqueKey,
          projectId: projectId,
          buildingDocumentId: buildingDocumentId,
        ),
      );
      return {
        'data': networkResponse["data"],
        'message': networkResponse["message"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteBuildingDocument(
          buildingId: buildingId,
          uniqueKey: uniqueKey,
          projectId: projectId,
          buildingDocumentId: buildingDocumentId,
        );
      }
      rethrow;
    }
  }
}
