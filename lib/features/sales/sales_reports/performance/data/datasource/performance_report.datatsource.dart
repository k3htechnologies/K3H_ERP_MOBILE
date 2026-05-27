import 'package:k3h_erp_app/features/sales/sales_reports/performance/data/model/performance_report_sourcing.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/performance/data/model/performance_report_closing.model.dart';
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

  Future<Map<String, dynamic>> apicallPerformanceReportForExport({
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
      queryParams?.forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) {
          url += "&$key=$value";
        }
      });
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
      final List<dynamic> dataList = rawData as List;

      final List<PerformanceReportSourcingModel> modelList =
          dataList
              .map((e) => PerformanceReportSourcingModel.fromJson(e))
              .toList();

      return {
        'data': modelList,
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullPerformanceSourcingReport(
          reportType: reportType,
          projectId: projectId,
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
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
      queryParams?.forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) {
          url += "&$key=$value";
        }
      });
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

      final List<dynamic> dataList = rawData as List;
      final List<PerformanceReportClosingModel> modelList =
          dataList
              .map((e) => PerformanceReportClosingModel.fromJson(e))
              .toList();

      return {
        'data': modelList,
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullPerformanceClosingReport(
          reportType: reportType,
          projectId: projectId,
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPerformanceReportForExport({
    required int projectId,
    required int pageSize,
    required int pageNumber,
    required String reportType,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPerformanceReportExportUrl({Map<String, dynamic>? queryParams}) {
      String url =
          "PerformanceReport/PullPerformanceReport?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&ReportType=$reportType";
      queryParams?.forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) {
          url += "&$key=$value";
        }
      });
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullPerformanceReportExportUrl(queryParams: queryParams),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPerformanceReportForExport(
          projectId: projectId,
          pageNumber: pageNumber,
          pageSize: pageSize,
          reportType: reportType,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
