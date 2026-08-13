import 'package:k3h_erp_app/features/crm/crm_report/dcr/data/model/dcr.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class DCRDatasource {
  Future<Map<String, dynamic>> apiCallPullDailyCollectionReport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallPullDailyCollectionReportForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class DCRDatasourceImpl extends DCRDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullDailyCollectionReport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullDailyCollectionReportURL({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "CollectionReport/PullDailyCollectionReport?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullDailyCollectionReportURL(
          queryParams: queryParams,
          pageSize: pageSize,
          pageNumber: pageNumber,
        ),
      );

      return {
        'data': List<DcrModel>.from(
          networkResponse["data"].map((e) => DcrModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullDailyCollectionReport(
          queryParams: queryParams,
          pageNumber: pageNumber,
          pageSize: pageSize,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullDailyCollectionReportForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullDailyCollectionReportUrl({
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
        pullDailyCollectionReportUrl(
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
        apiCallPullDailyCollectionReportForExport(
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
