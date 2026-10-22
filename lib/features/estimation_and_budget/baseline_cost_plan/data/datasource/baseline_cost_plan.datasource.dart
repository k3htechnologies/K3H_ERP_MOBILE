import 'package:k3h_erp_app/features/estimation_and_budget/baseline_cost_plan/data/model/baseline_cost_plan.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/baseline_cost_plan/data/model/baseline_cost_plan_category.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class BaselineCostPlanDatasource {
  Future<Map<String, dynamic>> apicallPullBaselineCostPlanDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullBaselineCostPlanDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallAddUpdateBaselineCostPlanDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeleteBaselineCostPlanDocument({
    required int baselineCostPlanDocumentId,
    required int projectId,
    required int baselineCostPlanDocumentCategoryId,
    required String uniqueKey,
  });
}

class BaselineCostPlanDatasourceImpl extends BaselineCostPlanDatasource {
  final BaseClient baseClient = BaseClient();
  @override
  Future<Map<String, dynamic>> apicallPullBaselineCostPlanDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullBaselineCostPlanDocumentCategoryUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "BaselineCostPlanDocumentCategory/PullBaselineCostPlanDocumentCategory?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullBaselineCostPlanDocumentCategoryUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<BaselineCostPlanDocumentCategory>.from(
          networkResponse["data"].map(
            (e) => BaselineCostPlanDocumentCategory.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullBaselineCostPlanDocumentCategory(
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
  Future<Map<String, dynamic>> apicallPullBaselineCostPlanDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullBaselineCostPlanDocumentUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "BaselineCostPlanDocument/PullBaselineCostPlanDocument?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullBaselineCostPlanDocumentUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<BaselineCostPlanDocumentModel>.from(
          networkResponse["data"].map(
            (e) => BaselineCostPlanDocumentModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullBaselineCostPlanDocument(
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
  Future<Map<String, dynamic>> apiCallAddUpdateBaselineCostPlanDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateBaselineCostPlanDocumentUrl =
        "BaselineCostPlanDocument/AddUpdateBaselineCostPlanDocument";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateBaselineCostPlanDocumentUrl,
            fileList,
            body,
          );
      return {
        'data': List<BaselineCostPlanDocumentModel>.from(
          networkResponse["data"].map(
            (e) => BaselineCostPlanDocumentModel.fromJson(e),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateBaselineCostPlanDocument(
          body: body,
          fileList: fileList,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteBaselineCostPlanDocument({
    required int baselineCostPlanDocumentId,
    required int projectId,
    required int baselineCostPlanDocumentCategoryId,
    required String uniqueKey,
  }) async {
    String deleteBaseplanCostPlanDocumentUrl({
      required int baselineCostPlanDocumentId,
      required int projectId,
      required int baselineCostPlanDocumentCategoryId,
      required String uniqueKey,
    }) {
      return "BaselineCostPlanDocument/DeleteBaselineCostPlanDocument"
          "?BaselineCostPlanDocumentId=$baselineCostPlanDocumentId"
          "&ProjectId=$projectId"
          "&BaselineCostPlanDocumentCategoryId=$baselineCostPlanDocumentCategoryId"
          "&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteBaseplanCostPlanDocumentUrl(
          baselineCostPlanDocumentId: baselineCostPlanDocumentId,
          baselineCostPlanDocumentCategoryId:
              baselineCostPlanDocumentCategoryId,
          projectId: projectId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteBaselineCostPlanDocument(
          baselineCostPlanDocumentId: baselineCostPlanDocumentId,
          projectId: projectId,
          baselineCostPlanDocumentCategoryId:
              baselineCostPlanDocumentCategoryId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }
}
