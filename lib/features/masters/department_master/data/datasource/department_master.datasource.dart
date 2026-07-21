import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class DepartmentMasterDatasource {
  Future<Map<String, dynamic>> apicallPullDepartmentMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateDepartmentMaster({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteDepartmentMaster({
    required int departmentMasterId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallPullDepartmentMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class DepartmentMasterDataSourceImpl implements DepartmentMasterDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullDepartmentMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullDepartmentUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "DepartmentMaster/PullDepartmentMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullDepartmentUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<DepartmentModel>.from(
          networkResponse["data"].map((e) => DepartmentModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullDepartmentMaster(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateDepartmentMaster({
    required Map<String, dynamic> body,
  }) async {
    try {
      String addUpdateDepartmentUrl =
          "DepartmentMaster/AddUpdateDepartmentMaster";

      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateDepartmentUrl,
        body,
      );
      return {
        'data': List<DepartmentModel>.from(
          networkResponse["data"].map((e) => DepartmentModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddUpdateDepartmentMaster(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteDepartmentMaster({
    required int departmentMasterId,
    required String uniqueKey,
  }) async {
    String deleteDepartmentUrl({
      required int departmentMasterId,
      required String uniqueKey,
    }) {
      return "DepartmentMaster/DeleteDepartmentMaster?DepartmentMasterId=$departmentMasterId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteDepartmentUrl(
          departmentMasterId: departmentMasterId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['TotalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallDeleteDepartmentMaster(
          departmentMasterId: departmentMasterId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullDepartmentMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullDepartmentExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "DepartmentMaster/PullDepartmentMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullDepartmentExportUrl(
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
        apicallPullDepartmentMasterForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
