import 'package:k3h_erp_app/features/project_document/document/data/model/document.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class DocumentDatasource {
  Future<Map<String, dynamic>> apicallPullProjectDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallAddUpdateDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeleteDocument({
    required int projectDocumentId,
    required int projectId,
    required int projectDocumentCategoryId,
    required String uniqueKey,
  });
}

class DocumentDatasourceImpl implements DocumentDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullProjectDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectDocumentUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ProjectDocument/PullProjectDocument?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectDocumentUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<DocumentModel>.from(
          networkResponse["data"].map((e) => DocumentModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullProjectDocument(
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
  Future<Map<String, dynamic>> apiCallAddUpdateDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateProjectDocumentUrl =
        "ProjectDocument/AddUpdateProjectDocument";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateProjectDocumentUrl,
            fileList,
            body,
          );
      return {
        'data': List<DocumentModel>.from(
          networkResponse["data"].map((e) => DocumentModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateDocument(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteDocument({
    required int projectDocumentId,
    required int projectId,
    required int projectDocumentCategoryId,
    required String uniqueKey,
  }) async {
    String deleteProjectDocumentUrl({
      required int projectDocumentId,
      required int projectDocumentCategoryId,
      required int projectId,
      required String uniqueKey,
    }) {
      return "ProjectDocument/DeleteProjectDocument?ProjectDocumentId=$projectDocumentId&ProjectId=$projectId&ProjectDocumentCategoryId=$projectDocumentCategoryId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteProjectDocumentUrl(
          projectDocumentId: projectDocumentId,
          projectDocumentCategoryId: projectDocumentCategoryId,
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
        apicallDeleteDocument(
          projectDocumentId: projectDocumentId,
          projectId: projectId,
          projectDocumentCategoryId: projectDocumentCategoryId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }
}
