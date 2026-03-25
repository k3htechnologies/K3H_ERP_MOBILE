import 'package:k3h_erp_app/features/sales/performance/data/model/performance_report_sourcing.model.dart';
import 'package:k3h_erp_app/features/sales/performance/data/model/performance_report_closing.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class PerformanceReportDatasource {
  Future<Map<String, dynamic>> apiCallPullPerformanceSourcingReport({
    required int projectId,
    required int pageSize,
    required int pageNumber,
    required String reportType,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallPullPerformanceClosingReport({
    required int projectId,
    required int pageSize,
    required int pageNumber,
    required String reportType,
    Map<String, dynamic>? queryParams,
  });
}

class PerformanceReportDatasourceImpl extends PerformanceReportDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullPerformanceSourcingReport({
    required int projectId,
    required int pageSize,
    required int pageNumber,
    required String reportType,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPerformanceSourcingReportUrl({
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "PerformanceReport/PullPerformanceReport?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&ReportType=$reportType";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullPerformanceSourcingReportUrl(queryParams: queryParams),
      );
      final rawData = networkResponse["data"] ?? networkResponse["Data"];

      if (rawData == null) {
        return {'data': null, 'totalNumberOfRecord': 0};
      }
      final PerformanceReportSourcingModel model =
          PerformanceReportSourcingModel.fromJson(rawData);

      return {
        'data': model,
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullPerformanceSourcingReport(
          queryParams: queryParams,
          reportType: reportType,
          projectId: projectId,
          pageSize: pageSize,
          pageNumber: pageNumber,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullPerformanceClosingReport({
    required int projectId,
    required int pageSize,
    required int pageNumber,
    required String reportType,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPerformanceClosingReportUrl({
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "PerformanceReport/PullPerformanceReport?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&ReportType=$reportType";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullPerformanceClosingReportUrl(queryParams: queryParams),
      );
      final rawData = networkResponse["data"] ?? networkResponse["Data"];

      if (rawData == null) {
        return {'data': null, 'totalNumberOfRecord': 0};
      }
      final PerformanceReportClosingModel model =
          PerformanceReportClosingModel.fromJson(rawData);

      return {
        'data': model,
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullPerformanceClosingReport(
          queryParams: queryParams,
          reportType: reportType,
          projectId: projectId,
          pageSize: pageSize,
          pageNumber: pageNumber,
        );
      }
      rethrow;
    }
  }
}
