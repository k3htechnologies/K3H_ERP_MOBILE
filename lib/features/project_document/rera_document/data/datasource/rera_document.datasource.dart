import 'package:k3h_erp_app/features/project_document/rera_document/data/model/rera_document.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class RERADocumentDatasource {
  Future<Map<String, dynamic>> apicallPullProjectRERADocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallAddUpdateRERADocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeleteRERADocument({
    required int projectRERADocumentId,
    required int projectId,
    required int projectRERADocumentCategoryId,
    required String uniqueKey,
  });
}

class RERADocumentDatasourceImpl implements RERADocumentDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullProjectRERADocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectRERADocumentUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ProjectRERADocument/PullProjectRERADocument?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectRERADocumentUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<RERADocumentModel>.from(
          networkResponse["data"].map((e) => RERADocumentModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullProjectRERADocument(
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
  Future<Map<String, dynamic>> apiCallAddUpdateRERADocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateProjectRERADocumentUrl =
        "ProjectRERADocument/AddUpdateProjectRERADocument";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateProjectRERADocumentUrl,
            fileList,
            body,
          );
      return {
        'data': List<RERADocumentModel>.from(
          networkResponse["data"].map((e) => RERADocumentModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateRERADocument(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteRERADocument({
    required int projectRERADocumentId,
    required int projectId,
    required int projectRERADocumentCategoryId,
    required String uniqueKey,
  }) async {
    String deleteProjectRERADocumentUrl({
      required int projectRERADocumentId,
      required int projectRERADocumentCategoryId,
      required int projectId,
      required String uniqueKey,
    }) {
      return "ProjectRERADocument/DeleteProjectRERADocument?ProjectRERADocumentId=$projectRERADocumentId&ProjectId=$projectId&ProjectRERADocumentCategoryId=$projectRERADocumentCategoryId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteProjectRERADocumentUrl(
          projectRERADocumentId: projectRERADocumentId,
          projectRERADocumentCategoryId: projectRERADocumentCategoryId,
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
        apicallDeleteRERADocument(
          projectRERADocumentId: projectRERADocumentId,
          projectId: projectId,
          projectRERADocumentCategoryId: projectRERADocumentCategoryId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }
}
