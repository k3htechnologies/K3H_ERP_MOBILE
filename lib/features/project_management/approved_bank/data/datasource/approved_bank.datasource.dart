import 'package:k3h_erp_app/features/project_management/approved_bank/data/model/approved_bank_file.model.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/data/model/approved_bank_folder.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class ApprovedBankDatasource {
  Future<Map<String, dynamic>> apicallPullApprovedBankFolder({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullApprovedBankFile({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateApprovedBankFolder({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallAddUpdateApprovedBankFile({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeleteApprovedBankFolder({
    required int approvedBankFolderId,
    required int projectId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallDeleteApprovedBankFile({
    required int approvedBankFileId,
    required int approvedBankFolderId,
    required int projectId,
    required String uniqueKey,
  });
}

class ApprovedBankDatasourceImpl extends ApprovedBankDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullApprovedBankFolder({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullApprovedBankFolderUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ApprovedBank/PullApprovedBankFolder?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullApprovedBankFolderUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<ApprovedBankFolderModel>.from(
          networkResponse["data"].map(
            (e) => ApprovedBankFolderModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullApprovedBankFolder(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullApprovedBankFile({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      String pullApprovedBankFileUrl({
        required int pageSize,
        required int pageNumber,
        required int projectId,
        Map<String, dynamic>? queryParams,
      }) {
        String url =
            "ApprovedBank/PullApprovedBankFile?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
        url += queryParamsFormatter(queryParams: queryParams);
        return url;
      }

      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullApprovedBankFileUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<ApprovedBankFileModel>.from(
          networkResponse["data"].map((e) => ApprovedBankFileModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullApprovedBankFile(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateApprovedBankFolder({
    required Map<String, dynamic> body,
  }) async {
    try {
      String addUpdateApprovedBankFolderUrl =
          "ApprovedBank/AddUpdateApprovedBankFolder";

      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateApprovedBankFolderUrl,
        body,
      );
      return {
        'data': List<ApprovedBankFolderModel>.from(
          networkResponse["data"].map(
            (e) => ApprovedBankFolderModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateApprovedBankFolder(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateApprovedBankFile({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      String addUpdateApprovedBankFileUrl =
          "ApprovedBank/AddUpdateApprovedBankFile";

      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateApprovedBankFileUrl,
            fileList,
            body,
          );
      return {
        'data': List<ApprovedBankFileModel>.from(
          networkResponse["data"].map((e) => ApprovedBankFileModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateApprovedBankFile(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteApprovedBankFolder({
    required int approvedBankFolderId,
    required int projectId,
    required String uniqueKey,
  }) async {
    try {
      String deleteApprovedBankFolderUrl({
        required int approvedBankFolderId,
        required int projectId,
        required String uniqueKey,
      }) {
        return "ApprovedBank/DeleteApprovedBankFolder?ApprovedBankFolderId=$approvedBankFolderId&Uniquekey=$uniqueKey&ProjectId=$projectId";
      }

      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteApprovedBankFolderUrl(
          approvedBankFolderId: approvedBankFolderId,
          projectId: projectId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteApprovedBankFolder(
          approvedBankFolderId: approvedBankFolderId,
          projectId: projectId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteApprovedBankFile({
    required int approvedBankFileId,
    required int approvedBankFolderId,
    required int projectId,
    required String uniqueKey,
  }) async {
    try {
      String deleteApprovedBankFileUrl({
        required int approvedBankFileId,
        required int approvedBankFolderId,
        required int projectId,
        required String uniqueKey,
      }) {
        return "ApprovedBank/DeleteApprovedBankFile?ApprovedBankFileId=$approvedBankFileId&Uniquekey=$uniqueKey&ProjectId=$projectId&ApprovedBankFolderId=$approvedBankFolderId";
      }

      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteApprovedBankFileUrl(
          approvedBankFileId: approvedBankFileId,
          approvedBankFolderId: approvedBankFolderId,
          projectId: projectId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteApprovedBankFile(
          approvedBankFileId: approvedBankFileId,
          approvedBankFolderId: approvedBankFolderId,
          projectId: projectId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }
}
