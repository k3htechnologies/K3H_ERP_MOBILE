import 'package:k3h_erp_app/features/project_document/approval_document/data/model/approval_document.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class ApprovalDocumentDatasource {
  Future<Map<String, dynamic>> apicallPullProjectApprovalDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallAddUpdateApprovalDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeleteApprovalDocument({
    required int approvalDocumentId,
    required int projectId,
    required int approvalDocumentCategoryId,
    required String uniqueKey,
  });
}

class ApprovalDocumentDatasourceImpl implements ApprovalDocumentDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullProjectApprovalDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectApprovalDocumentUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ApprovalDocument/PullApprovalDocument?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectApprovalDocumentUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<ApprovalDocumentModel>.from(
          networkResponse["data"].map((e) => ApprovalDocumentModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullProjectApprovalDocument(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallAddUpdateApprovalDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateProjectApprovalDocumentUrl =
        "ApprovalDocument/AddUpdateApprovalDocument";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateProjectApprovalDocumentUrl,
            fileList,
            body,
          );
      return {
        'data': List<ApprovalDocumentModel>.from(
          networkResponse["data"].map((e) => ApprovalDocumentModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateApprovalDocument(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteApprovalDocument({
    required int approvalDocumentId,
    required int projectId,
    required int approvalDocumentCategoryId,
    required String uniqueKey,
  }) async {
    String deleteProjectApprovalDocumentUrl({
      required int approvalDocumentId,
      required int approvalDocumentCategoryId,
      required int projectId,
      required String uniqueKey,
    }) {
      return "ApprovalDocument/DeleteApprovalDocument?ApprovalDocumentId=$approvalDocumentId&ProjectId=$projectId&ApprovalDocumentCategoryId=$approvalDocumentCategoryId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteProjectApprovalDocumentUrl(
          approvalDocumentId: approvalDocumentId,
          approvalDocumentCategoryId: approvalDocumentCategoryId,
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
        apicallDeleteApprovalDocument(
          approvalDocumentId: approvalDocumentId,
          projectId: projectId,
          approvalDocumentCategoryId: approvalDocumentCategoryId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }
}
