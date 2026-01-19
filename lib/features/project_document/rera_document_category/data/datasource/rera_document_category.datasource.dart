import 'package:k3h_erp_app/features/project_document/rera_document_category/data/model/rera_document_category.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class RERADocumentCategoryDatasource {
  Future<Map<String, dynamic>> apicallPullProjectRERADocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateProjectRERADocumentCategory({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteProjectRERADocumentCategory({
    required int projectDocumentCategoryId,
    required int projectId,
    required String uniqueKey,
  });
}

class RERADocumentCategoryDatasourceImpl
    implements RERADocumentCategoryDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullProjectRERADocumentCategory({
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
          "ProjectRERADocumentCategory/PullProjectRERADocumentCategory?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
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
        'data': List<RERADocumentCategoryModel>.from(
          networkResponse["data"].map(
            (e) => RERADocumentCategoryModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullProjectRERADocumentCategory(
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
  Future<Map<String, dynamic>> apicallAddUpdateProjectRERADocumentCategory({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateProjectDocumentCategoryUrl =
        "ProjectRERADocumentCategory/AddUpdateProjectRERADocumentCategory";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateProjectDocumentCategoryUrl,
        body,
      );
      return {
        'data': List<RERADocumentCategoryModel>.from(
          networkResponse["data"].map(
            (e) => RERADocumentCategoryModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateProjectRERADocumentCategory(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteProjectRERADocumentCategory({
    required int projectDocumentCategoryId,
    required int projectId,
    required String uniqueKey,
  }) async {
    String deleteProjectRERAocumentCategoryUrl({
      required int projectRERADocumentCategoryId,
      required int projectId,
      required String uniqueKey,
    }) {
      return "ProjectRERADocumentCategory/DeleteProjectRERADocumentCategory?ProjectRERADocumentCategoryId=$projectRERADocumentCategoryId&ProjectId=$projectId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteProjectRERAocumentCategoryUrl(
          projectRERADocumentCategoryId: projectDocumentCategoryId,
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
        apicallDeleteProjectRERADocumentCategory(
          projectDocumentCategoryId: projectDocumentCategoryId,
          projectId: projectId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }
}
