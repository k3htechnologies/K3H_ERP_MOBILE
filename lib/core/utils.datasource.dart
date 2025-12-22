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
}
