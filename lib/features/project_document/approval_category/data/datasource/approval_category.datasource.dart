import 'package:k3h_erp_app/features/project_document/approval_category/data/model/approval_category.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class ApprovalCategoryDatasource {
  Future<Map<String, dynamic>> apicallPullProjectApprovalDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateProjectApprovalDocumentCategory({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteProjectApprovalDocumentCategory({
    required int projectApprovalDocumentCategoryId,
    required int projectId,
    required String uniqueKey,
  });
  Future<Map<String, dynamic>> apicallPullProjectApprovalCategoryForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class ApprovalCategoryDatasourceImpl implements ApprovalCategoryDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullProjectApprovalDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectApprovalDocumentCategoryUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ApprovalDocumentCategory/PullApprovalDocumentCategory?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectApprovalDocumentCategoryUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<ApprovalDocumentCategoryModel>.from(
          networkResponse["data"].map(
            (e) => ApprovalDocumentCategoryModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullProjectApprovalDocumentCategory(
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
  Future<Map<String, dynamic>> apicallAddUpdateProjectApprovalDocumentCategory({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateProjectApprovalDocumentCategoryUrl =
        "ApprovalDocumentCategory/AddUpdateApprovalDocumentCategory";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateProjectApprovalDocumentCategoryUrl,
        body,
      );
      return {
        'data': List<ApprovalDocumentCategoryModel>.from(
          networkResponse["data"].map(
            (e) => ApprovalDocumentCategoryModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateProjectApprovalDocumentCategory(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteProjectApprovalDocumentCategory({
    required int projectApprovalDocumentCategoryId,
    required int projectId,
    required String uniqueKey,
  }) async {
    String deleteProjectApprovalDocumentCategoryUrl({
      required int projectApprovalDocumentCategoryId,
      required int projectId,
      required String uniqueKey,
    }) {
      return "ApprovalDocumentCategory/DeleteApprovalDocumentCategory?ApprovalDocumentCategoryId=$projectApprovalDocumentCategoryId&ProjectId=$projectId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteProjectApprovalDocumentCategoryUrl(
          projectApprovalDocumentCategoryId: projectApprovalDocumentCategoryId,
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
        apicallDeleteProjectApprovalDocumentCategory(
          projectApprovalDocumentCategoryId: projectApprovalDocumentCategoryId,
          projectId: projectId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullProjectApprovalCategoryForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectDocumentCategoryExportUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ApprovalDocumentCategory/PullApprovalDocumentCategory?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectDocumentCategoryExportUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullProjectApprovalCategoryForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
