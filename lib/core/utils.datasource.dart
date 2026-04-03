
import 'dart:convert';

import 'package:k3h_erp_app/core/models/approval_log_history.model.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/models/modules_workflow_approval.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

import 'local_storage_manager.dart';

abstract interface class UtilsDatasource {
  Future<Map<String, dynamic>> apicallPullMenu({required int employeeId});

  Future<Map<String, dynamic>> apicallExcelImport({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>>
  apicallPullMaterialMasterSubMaterialMasterUOMMaster({required int projectId});

  Future<Map<String, dynamic>> apicalPullExcelSample({
    required String tableName,
  });

  Future<UserModel> apicallIsPullEmployeeWithMenuList();

  Future<Map<String, dynamic>> apiCallToPullProjectSummary({
    required int projectId,
  });

  Future<Map<String, dynamic>> apiCallSendOTPModuleBased({
    required String mobileNumber,
    required String module,
  });
  Future<Map<String, dynamic>> apiCallUpdateModulesWorkflowApproval({
    required String moduleName,
    required int id,
    required int projectId,
    required bool isApproved,
    required String remark,
    int? subId,
    int? subSubId,
    int? subSubSubId,
  });

  Future<Map<String, dynamic>> apiCallAddUpdateModulesWorkflowApproval({
    required String employeeId,
    required int projectId,
    required int modulesMasterId,
    required int subModulesMasterId,
    required int subSubModulesMasterId,
  });
  Future<Map<String, dynamic>> apiCallPullModuleApprovalStatus({
    required String moduleName,
    required int id,
    required int projectId,
    int? subId,
    int? subSubId,
    int? subSubSubId,
  });

  Future<Map<String, dynamic>> apiCallPullModulesWorkflowApproval({
    int? employeeId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallDeleteModuleWorkflowApproval({
    required int employeeId,
    required int projectId,
    required int modulesMasterId,
    required int subModulesMasterId,
    required int subSubModulesMasterId,
  });
  Future<Map<String, dynamic>> apiCallPullPaginationProjectWithEmployee({
    required int projectId,
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> pullCountryStateCityDistrictVillage();
}

class UtilsDatasourceImpl implements UtilsDatasource {
  final client = BaseClient();

  // PULL MENU
  @override
  Future<Map<String, dynamic>> apicallPullMenu({
    required int employeeId,
  }) async {
    try {
      String pullMenuUrl({required int employeeId}) {
        return "Menu/PullMenu?EmployeeId=$employeeId";
      }

      var networkResponse = await client.getRequestWithAuthentication(
        pullMenuUrl(employeeId: employeeId),
      );
      return {
        'menuData': List<ModuleModel>.from(
          networkResponse["data"].map((e) => ModuleModel.fromJson(e)),
        ),
      };
    } catch (error) {
      rethrow;
    }
  }

  // EXCEL IMPORT
  @override
  Future<Map<String, dynamic>> apicallExcelImport({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var networkResponse = await client
          .multipartRequestWithAuthenticationBytes(
            "ExcelImport/ExcelImport",
            fileList,
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

  // PULL MATERIAL MASTER SUB MATERIAL MASTER UOM MASTER
  @override
  Future<Map<String, dynamic>>
  apicallPullMaterialMasterSubMaterialMasterUOMMaster({
    required int projectId,
  }) async {
    try {
      String pullMaterialMasterSubMaterialMasterUOMMaster({
        required int projectId,
      }) {
        return "Static/PullMaterialMasterSubMaterialMasterUOMMaster?ProjectId=$projectId";
      }

      var networkResponse = await client.getRequestWithAuthentication(
        pullMaterialMasterSubMaterialMasterUOMMaster(projectId: projectId),
      );
      // networkResponse["data"] contains the Data object from API response
      final data = networkResponse["data"] as Map<String, dynamic>;
      return {
        "MaterialMasterSubMaterialMasterData":
            data["MaterialMasterSubMaterialMasterData"],
        "UomMasterData": data["UomMasterData"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  // PULL EXCEL SAMPLE
  @override
  Future<Map<String, dynamic>> apicalPullExcelSample({
    required String tableName,
  }) async {
    try {
      String pullExcelSample({required String tableName}) {
        return "ExcelImport/PullExcelSample?TableName=$tableName";
      }

      var networkResponse = await client.getRequestWithAuthentication(
        pullExcelSample(tableName: tableName),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  // PULL EMPLOYEE WITH MENU LIST
  @override
  Future<UserModel> apicallIsPullEmployeeWithMenuList() async {
    try {
      var networkResponse = await client.getRequestWithAuthentication(
        "Authentication/GetEmployeeWithMenu",
      );
      return UserModel.fromJson(networkResponse["data"][0]);
    } catch (error) {
      rethrow;
    }
  }

  // PULL PROJECT SUMMARY
  @override
  Future<Map<String, dynamic>> apiCallToPullProjectSummary({
    required int projectId,
  }) async {
    try {
      String pullProjectSummary({
        required int projectId,
        Map<String, dynamic>? queryParams,
      }) {
        String url = "Project/PullProjectSummary?ProjectId=$projectId";
        queryParams?.forEach((key, value) => url += "&$key=$value");
        return url;
      }

      var networkResponse = await client.getRequestWithAuthentication(
        pullProjectSummary(projectId: projectId),
      );
      return {
        'data': List<ProjectModel>.from(
          networkResponse["data"].map((e) => ProjectModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  //SEND MODULE BASED OTP
  @override
  Future<Map<String, dynamic>> apiCallSendOTPModuleBased({
    required String mobileNumber,
    required String module,
  }) async {
    try {
      String sendOTPUrl({
        required String mobileNumber,
        required String module,
      }) {
        String url =
            "/Authentication/SendOTPMobileNumberAndModule?MobileNumber=$mobileNumber&Module=$module";

        return url;
      }

      var networkResponse = await client.getRequestWithAuthentication(
        sendOTPUrl(mobileNumber: mobileNumber, module: module),
      );

      return {
        'data': networkResponse["data"],
        'message': networkResponse['message'] ?? 'OTP sent successfully',
      };
    } catch (error) {
      rethrow;
    }
  }

  // UPDATE MODULES WORKFLOW APPROVAL (FOR ACTION LIKE APPROVE AND REJECT)
  @override
  Future<Map<String, dynamic>> apiCallUpdateModulesWorkflowApproval({
    required String moduleName,
    required int id,
    required int projectId,
    required bool isApproved,
    required String remark,
    int? subId,
    int? subSubId,
    int? subSubSubId,
  }) async {
    try {
      final String url =
          "ModulesWorkflowApproval/UpdateModulesWorkflowApproval";

      final payload = {
        "ModuleName": moduleName,
        "Id": id,
        "ProjectId": projectId,
        "IsApproved": isApproved,
        "Remarks": remark,
        if (subId != null) "SubId": subId,
        if (subSubId != null) "SubSubId": subSubId,
        if (subSubSubId != null) "SubSubSubId": subSubSubId,
      };

      var networkResponse = await client.postRequestWithAuthentication(
        url,
        payload,
      );

      return {
        'data': networkResponse["data"],
        'message': networkResponse['message'],
      };
    } catch (error) {
      rethrow;
    }
  }

  // ADD UPDATE MODULES WORKFLOW APPROVAL (FOR ADDING EMPLOYEES TO APPROVAL MODULES)
  @override
  Future<Map<String, dynamic>> apiCallAddUpdateModulesWorkflowApproval({
    required String employeeId,
    required int projectId,
    required int modulesMasterId,
    required int subModulesMasterId,
    required int subSubModulesMasterId,
  }) async {
    try {
      final String url =
          "ModulesWorkflowApproval/AddUpdateModulesWorkflowApproval";

      final payload = {
        "EmployeeId": employeeId,
        "ProjectId": projectId,
        "ModulesMasterId": modulesMasterId,
        "SubModulesMasterId": subModulesMasterId,
        "SubSubModulesMasterId": subSubModulesMasterId,
      };

      var networkResponse = await client.postRequestWithAuthentication(
        url,
        payload,
      );

      return {
        'data': networkResponse["data"],
        'message': networkResponse['message'],
      };
    } catch (error) {
      rethrow;
    }
  }

  // MODULE BASED APPROVAL STATUS
  @override
  Future<Map<String, dynamic>> apiCallPullModuleApprovalStatus({
    required String moduleName,
    required int id,
    required int projectId,
    int? subId,
    int? subSubId,
    int? subSubSubId,
  }) async {
    try {
      String updateModulesWorkflowApprovalUrl({
        required String moduleName,
        required int id,
        required int projectId,
      }) {
        String url =
            "ModulesWorkflowApproval/PullModuleApprovalStatus?ModuleName=$moduleName&Id=$id&ProjectId=$projectId";

        if (subId != null) url += "&SubId=$subId";
        if (subSubId != null) url += "&SubSubId=$subSubId";
        if (subSubSubId != null) url += "&SubSubSubId=$subSubSubId";

        return url;
      }

      var networkResponse = await client.getRequestWithAuthentication(
        updateModulesWorkflowApprovalUrl(
          moduleName: moduleName,
          id: id,
          projectId: projectId,
        ),
      );

      return {
        'data': List<ApprovalLogHistory>.from(
          networkResponse["data"].map((e) => ApprovalLogHistory.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  // PULL MODULES WORKFLOW APPROVAL FOR PROJECT DETAILS APPROVAL TAB
  @override
  Future<Map<String, dynamic>> apiCallPullModulesWorkflowApproval({
    int? employeeId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      String updateModulesWorkflowApprovalUrl({
        int? employeeId,
        required int projectId,
        Map<String, dynamic>? queryParams,
      }) {
        String url =
            "ModulesWorkflowApproval/PullModulesWorkflowApproval?ProjectId=$projectId";
        if (employeeId != null) {
          url += "&EmployeeId=$employeeId";
        }
        queryParams?.forEach((key, value) => url += "&$key=$value");
        return url;
      }

      var networkResponse = await client.getRequestWithAuthentication(
        updateModulesWorkflowApprovalUrl(
          employeeId: employeeId,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<ModulesWorkflowApprovalModel>.from(
          networkResponse["data"].map(
            (e) => ModulesWorkflowApprovalModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  // DELETE EMPLOYEE FROM MODULE WORKFLOW APPROVAL
  @override
  Future<Map<String, dynamic>> apiCallDeleteModuleWorkflowApproval({
    required int employeeId,
    required int projectId,
    required int modulesMasterId,
    required int subModulesMasterId,
    required int subSubModulesMasterId,
  }) async {
    try {
      String deleteModulesWorkflowApprovalUrl({
        required int employeeId,
        required int projectId,
        required int modulesMasterId,
      }) {
        String url =
            "ModulesWorkflowApproval/DeleteModulesWorkflowApproval"
            "?EmployeeId=$employeeId"
            "&ProjectId=$projectId"
            "&ModulesMasterId=$modulesMasterId"
            "&SubModulesMasterId=$subModulesMasterId"
            "&SubSubModulesMasterId=$subSubModulesMasterId";

        return url;
      }

      var networkResponse = await client.deleteRequestWithAuthentication(
        deleteModulesWorkflowApprovalUrl(
          employeeId: employeeId,
          projectId: projectId,
          modulesMasterId: modulesMasterId,
        ),
      );

      return {
        'message': networkResponse['message'],
        'success': networkResponse['success'] ?? true,
      };
    } catch (error) {
      rethrow;
    }
  }

  // PULL PAGINATION PROJECT WITH EMPLOYEE
  @override
  Future<Map<String, dynamic>> apiCallPullPaginationProjectWithEmployee({
    required int projectId,
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      String url =
          "Project/PullPaginationProjectWithEmployee?"
          "ProjectId=$projectId"
          "&PageNumber=$pageNumber"
          "&PageSize=$pageSize";

      queryParams?.forEach((key, value) => url += "&$key=$value");

      final networkResponse = await client.getRequestWithAuthentication(url);

      return {
        'data': List<ModulesApprovalEmployeeDataModel>.from(
          networkResponse["data"].map(
            (e) => ModulesApprovalEmployeeDataModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> pullCountryStateCityDistrictVillage() async {
    const String url = 'Static/PullCountryStateCityDistrictVillage';

    final response = await client.getRequestWithAuthentication(url);

    final data = response['data']['CountryStateCityDistrictVillageData'];

    /// STORE IN CACHE
    await LocalStorageManager().setRawString(
      StorageKey.addressMasterData,
      jsonEncode(data),
    );

    return response;
  }

}
