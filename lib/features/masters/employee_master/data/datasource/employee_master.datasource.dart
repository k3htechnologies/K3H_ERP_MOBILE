import 'package:k3h_erp_app/core/models/branch.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';

abstract interface class EmployeeMasterDataSource {
  Future<Map<String, dynamic>> apiCallToPullEmployeeMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  });
  Future<Map<String, dynamic>> apiCallToAddUpdateEmployeeMaster({
    required Map<String, dynamic> requestBody,
  });

  Future<Map<String, dynamic>> apicallPullBankListMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  });

  Future<Map<String, dynamic>> apicallPullBranchMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  });

  Future<Map<String, dynamic>> apicallPullEmployeeMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class EmployeeMasterDataSourceImpl extends EmployeeMasterDataSource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallToPullEmployeeMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  }) async {
    String pullEmployeeUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Employee/PullEmployee?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullEmployeeUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: query,
        ),
      );
      return {
        'data': List<UserModel>.from(
          networkResponse['data'].map((e) => UserModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallToAddUpdateEmployeeMaster({
    required Map<String, dynamic> requestBody,
  }) async {
    String addUpdateEmployee = 'Employee/AddUpdateEmployee';

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateEmployee,
        requestBody,
      );
      return {
        'data': List<UserModel>.from(
          networkResponse['data'].map((e) => UserModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullBankListMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  }) async {
    String pullBankMasterUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "BankListMaster/PullBankListMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullBankMasterUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: query,
        ),
      );
      return {
        "data": networkResponse['data'],
        "totalNumberOfRecord": networkResponse["totalNumberOfRecord"],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullBranchMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  }) async {
    String pullBranchMasterUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "BranchMaster/PullBranchMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullBranchMasterUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: query,
        ),
      );
      return {
        'data': List<BranchModel>.from(
          networkResponse["data"].map((e) => BranchModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullEmployeeMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullEmployeeExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Employee/PullEmployee?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullEmployeeExportUrl(
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
      rethrow;
    }
  }
}
