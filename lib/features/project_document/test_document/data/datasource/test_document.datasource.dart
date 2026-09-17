import 'package:k3h_erp_app/features/project_document/test_document/data/model/test_document.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class TestDocumentDatasource {
  Future<Map<String, dynamic>> apicallPullTestDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallAddUpdateTestDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Map<String, dynamic>> apicallDeleteTestDocument({
    required int testDocumentId,
    required int projectId,
    required int testDocumentCategoryId,
    required String uniqueKey,
  });
}

class TestDocumentDatasourceImpl extends TestDocumentDatasource {
  final BaseClient baseClient = BaseClient();
  @override
  Future<Map<String, dynamic>> apicallPullTestDocument({
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
          "TestDocument/PullTestDocument?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
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
        'data': List<TestDocumentModel>.from(
          networkResponse["data"].map((e) => TestDocumentModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullTestDocument(
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
  Future<Map<String, dynamic>> apiCallAddUpdateTestDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateProjectDocumentUrl = "TestDocument/AddUpdateTestDocument";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateProjectDocumentUrl,
            fileList,
            body,
          );
      return {
        'data': List<TestDocumentModel>.from(
          networkResponse["data"].map((e) => TestDocumentModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateTestDocument(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteTestDocument({
    required int testDocumentId,
    required int projectId,
    required int testDocumentCategoryId,
    required String uniqueKey,
  }) async {
    String deleteProjectDocumentUrl({
      required int testDocumentId,
      required int projectId,
      required int testDocumentCategoryId,
      required String uniqueKey,
    }) {
      return "TestDocument/DeleteTestDocument?TestDocumentId=$testDocumentId&ProjectId=$projectId&TestDocumentCategoryId=$testDocumentCategoryId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteProjectDocumentUrl(
          testDocumentId: testDocumentId,
          testDocumentCategoryId: testDocumentCategoryId,
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
        apicallDeleteTestDocument(
          testDocumentId: testDocumentId,
          projectId: projectId,
          testDocumentCategoryId: testDocumentCategoryId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }
}
