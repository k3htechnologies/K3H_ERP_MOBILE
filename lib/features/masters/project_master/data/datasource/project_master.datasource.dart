import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/model/project_with_bank_details.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class ProjectMasterDatasource {
  Future<Map<String, dynamic>> apicallPullProject({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateProjectMaster({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallGetProjectWithCompany({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallGetProjectWithBankDetails({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallGetProjectWithEmployee({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateProjectWithBankDetails({
    required Map<String, dynamic> bankRequestBody,
  });

  Future<Map<String, dynamic>> apicallAddUpdateProjectWithCompany({
    required Map<String, dynamic> requestBody,
  });

  Future<Map<String, dynamic>> apicallAddUpdateProjectWithEmployee({
    required Map<String, dynamic> requestBody,
  });

  Future<Map<String, dynamic>> apicallDeleteProjectWithBankDetails({
    required int projectWithBankDetailsId,
    required String uniqueKey,
    required int projectId,
  });

  Future<Map<String, dynamic>> apicallPullProjectMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallDeleteProjectWithEmployee({
    required int projectId,
    required String uniquekey,
    required String employeeId,
  });
}

class ProjectMasterDatasourceImpl implements ProjectMasterDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullProject({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectDetailsUrl({
      required int pageNumber,
      required int pageSize,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Project/PullProject?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectDetailsUrl(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<ProjectModel>.from(
          networkResponse["data"].map((e) => ProjectModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullProject(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateProjectMaster({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateProjectMasterUrl = "Project/AddUpdateProject";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateProjectMasterUrl,
            fileList,
            body,
          );
      return {
        'data': List<ProjectModel>.from(
          networkResponse["data"].map((e) => ProjectModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateProjectMaster(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallGetProjectWithCompany({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectWithCompanyUrl({required int projectId}) {
      String url = "Project/PullProjectWithCompany?ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectWithCompanyUrl(projectId: projectId),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallGetProjectWithCompany(projectId: projectId);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallGetProjectWithBankDetails({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectWithBankDetailsUrl({
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url = "Project/PullProjectWithBankDetails?ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectWithBankDetailsUrl(
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<ProjectWithBankDetailsModel>.from(
          networkResponse["data"].map(
            (e) => ProjectWithBankDetailsModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallGetProjectWithBankDetails(
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallGetProjectWithEmployee({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectWithEmployeeUrl({required int projectId}) {
      var url = "Project/PullProjectWithEmployee?ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectWithEmployeeUrl(projectId: projectId),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallGetProjectWithEmployee(projectId: projectId);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateProjectWithBankDetails({
    required Map<String, dynamic> bankRequestBody,
  }) async {
    String addUpdateProjectWithBankDetailsUrl =
        "Project/AddUpdateProjectWithBankDetails";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateProjectWithBankDetailsUrl,
        bankRequestBody,
      );
      return {
        'data': networkResponse["data"],
        'message': networkResponse["message"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateProjectWithBankDetails(
          bankRequestBody: bankRequestBody,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateProjectWithCompany({
    required Map<String, dynamic> requestBody,
  }) async {
    String addUpdateProjectCompanyUrl = "Project/AddUpdateProjectWithCompany";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateProjectCompanyUrl,
        requestBody,
      );
      return {
        'data': networkResponse["data"],
        'message': networkResponse["message"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateProjectWithCompany(requestBody: requestBody);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateProjectWithEmployee({
    required Map<String, dynamic> requestBody,
  }) async {
    String addUpdateProjectWithEmployeeUrl = "Project/AddUpdateProjectEmployee";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateProjectWithEmployeeUrl,
        requestBody,
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateProjectWithEmployee(requestBody: requestBody);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteProjectWithBankDetails({
    required int projectWithBankDetailsId,
    required String uniqueKey,
    required int projectId,
  }) async {
    String deleteProjectWithBankDetailsUrl({
      required int projectWithBankDetailsId,
      required String uniquekey,
      required int projectId,
    }) {
      return "Project/DeleteProjectWithBankDetails?ProjectWithBankDetailsId=$projectWithBankDetailsId&Uniquekey=$uniquekey&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteProjectWithBankDetailsUrl(
          projectWithBankDetailsId: projectWithBankDetailsId,
          uniquekey: uniqueKey,
          projectId: projectId,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteProjectWithBankDetails(
          projectWithBankDetailsId: projectWithBankDetailsId,
          uniqueKey: uniqueKey,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullProjectMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectDetailsExportUrl({
      required int pageNumber,
      required int pageSize,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Project/PullProject?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectDetailsExportUrl(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullProjectMasterForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteProjectWithEmployee({
    required int projectId,
    required String uniquekey,
    required String employeeId,
  }) async {
    String deleteProjectWithEmployee({
      required int projectId,
      required String uniquekey,
      required String employeeId,
    }) {
      return "Project/DeleteProjectWithEmployee?ProjectId=$projectId&Uniquekey=$uniquekey&EmployeeId=$employeeId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteProjectWithEmployee(
          projectId: projectId,
          uniquekey: uniquekey,
          employeeId: employeeId,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteProjectWithEmployee(
          projectId: projectId,
          uniquekey: uniquekey,
          employeeId: employeeId,
        );
      }
      rethrow;
    }
  }
}
