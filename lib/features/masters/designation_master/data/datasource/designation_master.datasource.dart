import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/model/designation.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class DesignationMasterDatasource {
  Future<Map<String, dynamic>> apicallPullDesignationMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateDesignationMaster({
    required Map<String, dynamic> requestBody,
  });

  Future<Map<String, dynamic>> apicallDeleteDesignationMaster({
    required int designationMasterId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallPullDesignationMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallPullModulePermissions({
    required int designationMasterId,
  });

  Future<Map<String, dynamic>> apiCallToAddUpdateModulePermissions({
    required Map<String, dynamic> requestBody,
  });
}

class DesignationDataSoucreImp implements DesignationMasterDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullDesignationMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullDesignationUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "DesignationMaster/PullDesignationMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullDesignationUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<DesignationMasterModel>.from(
          networkResponse["data"].map(
            (e) => DesignationMasterModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateDesignationMaster({
    required Map<String, dynamic> requestBody,
  }) async {
    String addUpdateDesignationUrl =
        "DesignationMaster/AddUpdateDesignationMaster";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateDesignationUrl,
        requestBody,
      );
      return {
        'data': List<DesignationMasterModel>.from(
          networkResponse["data"].map(
            (e) => DesignationMasterModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteDesignationMaster({
    required int designationMasterId,
    required String uniqueKey,
  }) async {
    String deleteDesignationUrl({
      required int designationMasterId,
      required String uniqueKey,
    }) {
      return "DesignationMaster/DeleteDesignationMaster?DesignationMasterId=$designationMasterId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteDesignationUrl(
          designationMasterId: designationMasterId,
          uniqueKey: uniqueKey,
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

  @override
  Future<Map<String, dynamic>> apicallPullDesignationMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullDesignationExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "DesignationMaster/PullDesignationMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullDesignationExportUrl(
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
        apicallPullDesignationMasterForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullModulePermissions({
    required int designationMasterId,
  }) async {
    String pullModulePermissionUrl({required int designationMasterId}) {
      return "ModulesPermissions/PullModulesPermissions?DesignationMasterId=$designationMasterId";
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullModulePermissionUrl(designationMasterId: designationMasterId),
      );
      return {
        "data": List<ModuleModel>.from(
          networkResponse['data'].map((e) => ModuleModel.fromJson(e)),
        ),
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullModulePermissions(designationMasterId: designationMasterId);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallToAddUpdateModulePermissions({
    required Map<String, dynamic> requestBody,
  }) async {
    String addUpdateModulePermissionUrl =
        'ModulesPermissions/AddUpdateModulesPermissions';

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateModulePermissionUrl,
        requestBody,
      );
      return {
        "data": List<ModuleModel>.from(
          networkResponse['data'].map((e) => ModuleModel.fromJson(e)),
        ),
        "message": networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallToAddUpdateModulePermissions(requestBody: requestBody);
      }
      rethrow;
    }
  }
}
