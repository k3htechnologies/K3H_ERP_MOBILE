import 'package:k3h_erp_app/core/models/branch.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/employee_education_details.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/data/model/asset_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/employee_document.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/data/model/week_off_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/data/model/shift_master_mapping.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class EmployeeMasterDataSource {
  Future<Map<String, dynamic>> apiCallToPullEmployeeMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  });

  Future<Map<String, dynamic>> apicallPullEmployeeEducationDetails({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallToPullEmployeeDocument({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  });

  Future<Map<String, dynamic>> apiCallToPullEmployeeAsset({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  });

  Future<Map<String, dynamic>> apiCallToPullEmployeeShiftManagementMapping({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  });

  Future<Map<String, dynamic>> apiCallToPullEmployeeWeekOffMapping({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  });

  Future<Map<String, dynamic>> apiCallToAddUpdateEmployeeMaster({
    required Map<String, dynamic> requestBody,
  });

  Future<Map<String, dynamic>> apiCallToAddUpdateEmployeeDocument({
    required Map<String, String> requestBody,
    required List<Map<String, dynamic>> fileList,
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
      if (error is TokenExpiredException) {
        apiCallToPullEmployeeMaster(
          pageNumber: pageNumber,
          pageSize: pageSize,
          query: query,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullEmployeeEducationDetails({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullEmployeeEducationDetailsUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "EmployeeEducationDetails/PullEmployeeEducationDetails?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullEmployeeEducationDetailsUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<EmployeeEducationDetailsModel>.from(
          networkResponse["data"].map(
            (e) => EmployeeEducationDetailsModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullEmployeeEducationDetails(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallToPullEmployeeDocument({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  }) async {
    String pullEmployeeDocumentUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "EmployeeDocument/PullEmployeeDocument?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullEmployeeDocumentUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: query,
        ),
      );
      return {
        'data': List<EmployeeDocumentModel>.from(
          networkResponse['data'].map((e) => EmployeeDocumentModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallToPullEmployeeDocument(
          pageNumber: pageNumber,
          pageSize: pageSize,
          query: query,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallToPullEmployeeAsset({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  }) async {
    String pullEmployeeAssetUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "AssetMasterMappingMapping/PullAssetMasterMapping?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullEmployeeAssetUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: query,
        ),
      );
      return {
        'data': List<AssetMappingModel>.from(
          networkResponse['data'].map((e) => AssetMappingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallToPullEmployeeAsset(
          pageNumber: pageNumber,
          pageSize: pageSize,
          query: query,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallToPullEmployeeShiftManagementMapping({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  }) async {
    String pullEmployeeShiftManagementUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ShiftManagementMasterMapping/PullShiftManagementMasterMapping?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullEmployeeShiftManagementUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: query,
        ),
      );
      return {
        'data': List<ShiftMappingModel>.from(
          networkResponse['data'].map((e) => ShiftMappingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallToPullEmployeeShiftManagementMapping(
          pageNumber: pageNumber,
          pageSize: pageSize,
          query: query,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallToPullEmployeeWeekOffMapping({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  }) async {
    String pullEmployeeShiftManagementUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "WeekOffPolicyMasterMapping/PullWeekOffPolicyMasterMapping?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullEmployeeShiftManagementUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: query,
        ),
      );
      return {
        'data': List<WeekOffMappingModel>.from(
          networkResponse['data'].map((e) => WeekOffMappingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallToPullEmployeeWeekOffMapping(
          pageNumber: pageNumber,
          pageSize: pageSize,
          query: query,
        );
      }
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
      if (error is TokenExpiredException) {
        apiCallToAddUpdateEmployeeMaster(requestBody: requestBody);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallToAddUpdateEmployeeDocument({
    required Map<String, String> requestBody,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateEmployee = 'EmployeeDocument/AddUpdateEmployeeDocument';

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateEmployee,
            fileList,
            requestBody,
          );
      return {
        'data': List<EmployeeDocumentModel>.from(
          networkResponse['data'].map((e) => EmployeeDocumentModel.fromJson(e)),
        ),
        'successMessage': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallToAddUpdateEmployeeDocument(
          requestBody: requestBody,
          fileList: fileList,
        );
      }
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
      if (error is TokenExpiredException) {
        apicallPullBankListMaster(
          pageNumber: pageNumber,
          pageSize: pageSize,
          query: query,
        );
      }
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
      if (error is TokenExpiredException) {
        apicallPullBranchMaster(
          pageNumber: pageNumber,
          pageSize: pageSize,
          query: query,
        );
      }
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
      if (error is TokenExpiredException) {
        apicallPullEmployeeMasterForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
