import 'package:k3h_erp_app/features/project_document/test_document_category/data/model/test_document_category.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class TestDocumentCategoryDatasource {
  Future<Map<String, dynamic>> apicallPullTestDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallAddUpdateTestDocumentCategory({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apicallDeleteTestDocumentCategory({
    required int testDocumentCategoryId,
    required int projectId,
    required String uniqueKey,
  });
  Future<Map<String, dynamic>> apicallPullTestDocumentCategoryForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class TestDocumentCategoryDatasourceImpl
    extends TestDocumentCategoryDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullTestDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectDocumentCategoryUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "TestDocumentCategory/PullTestDocumentCategory?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectDocumentCategoryUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<TestDocumentCategoryModel>.from(
          networkResponse["data"].map(
            (e) => TestDocumentCategoryModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullTestDocumentCategory(
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
  Future<Map<String, dynamic>> apicallAddUpdateTestDocumentCategory({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateProjectDocumentCategoryUrl =
        "TestDocumentCategory/AddUpdateTestDocumentCategory";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateProjectDocumentCategoryUrl,
        body,
      );
      return {
        'data': List<TestDocumentCategoryModel>.from(
          networkResponse["data"].map(
            (e) => TestDocumentCategoryModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateTestDocumentCategory(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteTestDocumentCategory({
    required int testDocumentCategoryId,
    required int projectId,
    required String uniqueKey,
  }) async {
    String deleteProjectRERAocumentCategoryUrl({
      required int testRERADocumentCategoryId,
      required int projectId,
      required String uniqueKey,
    }) {
      return "TestDocumentCategory/DeleteTestDocumentCategory?TestDocumentCategoryId=$testRERADocumentCategoryId&ProjectId=$projectId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteProjectRERAocumentCategoryUrl(
          testRERADocumentCategoryId: testDocumentCategoryId,
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
        apicallDeleteTestDocumentCategory(
          testDocumentCategoryId: testDocumentCategoryId,
          projectId: projectId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullTestDocumentCategoryForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullChannelPartnerExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "TestDocumentCategory/PullTestDocumentCategory?PageSize=$pageSize&PageNumber=$pageNumber&projectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullChannelPartnerExportUrl(
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
        apicallPullTestDocumentCategoryForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }
}
