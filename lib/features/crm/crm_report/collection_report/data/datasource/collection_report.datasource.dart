import 'package:k3h_erp_app/features/crm/crm_report/collection_report/data/model/collection_report.model.dart';
import 'package:k3h_erp_app/features/crm/crm_report/collection_report/data/model/collection_report_project_wise.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class CollectionReportDatasource {
  Future<Map<String, dynamic>> apiCallPullProjectWiseCollectionReport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallPullProjectWiseCollectionReportForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallPullCollectionReport({
    required int projectId,
    required String projectName,
    Map<String, dynamic>? queryParams,
  });
}

class CollectionReportDatasourceImpl extends CollectionReportDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullProjectWiseCollectionReport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectWiseCollectionReporttURL({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "CollectionReport/PullProjectWiseCollectionReport?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectWiseCollectionReporttURL(
          queryParams: queryParams,
          pageSize: pageSize,
          pageNumber: pageNumber,
        ),
      );

      return {
        'data': List<CollectionReportModel>.from(
          networkResponse["data"].map((e) => CollectionReportModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullProjectWiseCollectionReport(
          queryParams: queryParams,
          pageNumber: pageNumber,
          pageSize: pageSize,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullProjectWiseCollectionReportForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectWiseCollectionReportUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "CollectionReport/PullDailyCollectionReport?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectWiseCollectionReportUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullProjectWiseCollectionReportForExport(
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
  Future<Map<String, dynamic>> apiCallPullCollectionReport({
    required int projectId,
    required String projectName,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectCollectionReporttURL({
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "CollectionReport/PullCollectionReport?ProjectId=$projectId&ProjectName=$projectName";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectCollectionReporttURL(queryParams: queryParams),
      );

      return {
        'data': List<CollectionReportProjectWiseModel>.from(
          networkResponse["data"].map(
            (e) => CollectionReportProjectWiseModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullCollectionReport(
          projectId: projectId,
          projectName: projectName,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
