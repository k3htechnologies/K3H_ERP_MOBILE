import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/data/model/construction_area.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/data/model/construction_area_comparative.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class ConstructionAreaDatasource {
  Future<Map<String, dynamic>> apicallPullConstructionArea({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallPullConstructionAreaComparative({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallAddUpdateConstructionAreaComparative({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
}

class ConstructionAreaDatasourceImpl extends ConstructionAreaDatasource {
  final BaseClient baseClient = BaseClient();
  @override
  Future<Map<String, dynamic>> apicallPullConstructionArea({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullConstructionAreaUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ConstructionArea/PullConstructionArea?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullConstructionAreaUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<ConstructionAreaModel>.from(
          networkResponse["data"].map((e) => ConstructionAreaModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullConstructionArea(
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
  Future<Map<String, dynamic>> apicallPullConstructionAreaComparative({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullConstructionAreaComparativeUrl({
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ConstructionAreaComparative/PullConstructionAreaComparative?ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullConstructionAreaComparativeUrl(
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<ConstructionAreaComparativeModel>.from(
          networkResponse["data"].map(
            (e) => ConstructionAreaComparativeModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullConstructionAreaComparative(
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallAddUpdateConstructionAreaComparative({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateBaselineCostPlanDocumentUrl =
        "ConstructionAreaComparative/AddUpdateConstructionAreaComparative";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateBaselineCostPlanDocumentUrl,
            fileList,
            body,
          );
      return {
        'data': List<ConstructionAreaComparativeModel>.from(
          networkResponse["data"].map(
            (e) => ConstructionAreaComparativeModel.fromJson(e),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateConstructionAreaComparative(
          body: body,
          fileList: fileList,
        );
      }
      rethrow;
    }
  }
}
