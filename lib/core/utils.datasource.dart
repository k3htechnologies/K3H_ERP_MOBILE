import 'package:k3h_erp_app/core/models/approval_log_history.model.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';

abstract interface class UtilsDatasource {
  Future<Map<String, dynamic>> apicallPullMenu({
    required int employeeId,
    required int projectId,
  });

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

  Future<Map<String, dynamic>> apiCallToPullProjectSummery({
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
  Future<Map<String, dynamic>> apiCallPullModuleApprovalStatus({
    required String moduleName,
    required int id,
    required int projectId,
    int? subId,
    int? subSubId,
    int? subSubSubId,
  });
}

class UtilsDatasourceImpl implements UtilsDatasource {
  final client = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullMenu({
    required int employeeId,
    required int projectId,
  }) async {
    try {
      String pullMenuUrl({required int employeeId, required int projectId}) {
        return "Menu/PullMenu?EmployeeId=$employeeId&ProjectId=$projectId";
      }

      var networkResponse = await client.getRequestWithAuthentication(
        pullMenuUrl(employeeId: employeeId, projectId: projectId),
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

  @override
  Future<Map<String, dynamic>> apiCallToPullProjectSummery({
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

      var networkResponse = await client.getRequestWithoutAuthentication(
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

      var networkResponse = await client.getRequestWithoutAuthentication(
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
}
