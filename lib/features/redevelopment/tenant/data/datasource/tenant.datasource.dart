import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant_document.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class TenantDatasource {
  Future<Map<String, dynamic>> apicallPullTenant({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullTenantDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateTenant({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallAddUpdateTenantDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeleteTenant({
    required int tenantId,
    required String uniqueKey,
    required int projectId,
    required int buildingId,
  });

  Future<Map<String, dynamic>> apicallDeleteTenantDocument({
    required int tenantDocumentId,
    required String uniqueKey,
    required int projectId,
    required int buildingId,
  });

  Future<Map<String, dynamic>> apicallPullTenantForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });
}

class TenantDataSourceImpl implements TenantDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullTenant({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullTenantUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Tenant/PullTenant?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&BuildingId=$buildingId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullTenantUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<TenantModel>.from(
          networkResponse["data"].map((e) => TenantModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullTenant(
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
  Future<Map<String, dynamic>> apicallPullTenantDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullTenantDocumentUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Tenant/PullTenantDocument?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&BuildingId=$buildingId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullTenantDocumentUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<TenantDocumentModel>.from(
          networkResponse["data"].map((e) => TenantDocumentModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullTenantDocument(
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
  Future<Map<String, dynamic>> apicallAddUpdateTenant({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateTenantUrl = "Tenant/AddUpdateTenant";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateTenantUrl,
            fileList,
            body,
          );
      return {
        'data': List<TenantModel>.from(
          networkResponse["data"].map((e) => TenantModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateTenant(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateTenantDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateTenantDocumentUrl = "Tenant/AddUpdateTenantDocument";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateTenantDocumentUrl,
            fileList,
            body,
          );
      return {
        'data': List<TenantDocumentModel>.from(
          networkResponse["data"].map((e) => TenantDocumentModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateTenantDocument(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteTenant({
    required int tenantId,
    required String uniqueKey,
    required int projectId,
    required int buildingId,
  }) async {
    String deleteTenantUrl({
      required int tenantId,
      required String uniqueKey,
      required int buildingId,
      required int projectId,
    }) {
      return "Tenant/DeleteTenant?TenantId=$tenantId&Uniquekey=$uniqueKey&BuildingId=$buildingId&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteTenantUrl(
          tenantId: tenantId,
          uniqueKey: uniqueKey,
          buildingId: buildingId,
          projectId: projectId,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteTenant(
          tenantId: tenantId,
          uniqueKey: uniqueKey,
          projectId: projectId,
          buildingId: buildingId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteTenantDocument({
    required int tenantDocumentId,
    required String uniqueKey,
    required int projectId,
    required int buildingId,
  }) async {
    String deleteTenantDocumentUrl({
      required int tenantDocumentId,
      required String uniqueKey,
      required int buildingId,
      required int projectId,
    }) {
      return "Tenant/DeleteTenantDocument?TenantDocumentId=$tenantDocumentId&Uniquekey=$uniqueKey&BuildingId=$buildingId&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteTenantDocumentUrl(
          tenantDocumentId: tenantDocumentId,
          uniqueKey: uniqueKey,
          buildingId: buildingId,
          projectId: projectId,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteTenantDocument(
          tenantDocumentId: tenantDocumentId,
          uniqueKey: uniqueKey,
          projectId: projectId,
          buildingId: buildingId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullTenantForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullTenantExport({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Tenant/PullTenant?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&BuildingId=$buildingId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullTenantExport(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullTenantForExport(
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
}
