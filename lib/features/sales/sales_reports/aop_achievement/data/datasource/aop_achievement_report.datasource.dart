import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/achivement_drill_down_report.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/aop_achievement/data/model/aop_achievement_report.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class AopAchievementReportDatasource {
  Future<Map<String, dynamic>> apiCallPullAopAchievementReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallPullAopAchievementReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallPullAopAchievementDrillDownReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    required String tabName,
    required String columnName,
    required AchievementDrillDownType achivementDrillDownType,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>>
  apiCallPullAopAchievementDrillDownReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    required String tabName,
    required String columnName,
    Map<String, dynamic>? queryParams,
  });
}

class AopAchievementReportDatasourceImpl
    extends AopAchievementReportDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullAopAchievementReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullAopAchievementReportUrl({Map<String, dynamic>? queryParams}) {
      String url =
          "AOPAchievementReport/PullAOPAchievementReport?pageNumber=$pageNumber&pageSize=$pageSize&FilterType=$filterType";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullAopAchievementReportUrl(queryParams: queryParams),
      );

      return {
        'data': List<AopAchievementReportModel>.from(
          networkResponse["data"].map(
            (e) => AopAchievementReportModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullAopAchievementReport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          filterType: filterType,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullAopAchievementReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullAopAchievementReportUrl({Map<String, dynamic>? queryParams}) {
      String url =
          "AOPAchievementReport/PullAOPAchievementReport?pageNumber=$pageNumber&pageSize=$pageSize&FilterType=$filterType";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullAopAchievementReportUrl(queryParams: queryParams),
      );

      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullAopAchievementReportForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          filterType: filterType,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullAopAchievementDrillDownReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    required String tabName,
    required String columnName,
    required AchievementDrillDownType achivementDrillDownType,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullAopAchievementDrillDownReportUrl({
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "AOPAchievementReport/PullAOPAchievementDrillDownReport"
          "?pageSize=$pageSize"
          "&pageNumber=$pageNumber"
          "&TabName=$tabName"
          "&ColumnName=${Uri.encodeQueryComponent(columnName)}"
          "&FilterType=$filterType";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullAopAchievementDrillDownReportUrl(queryParams: queryParams),
      );

      final data = List<AchievementDrillDownReportModel>.from(
        (networkResponse["data"] as List).map(
          (e) => AchievementDrillDownReportModel.fromJson(
            json: e as Map<String, dynamic>,
            type: achivementDrillDownType,
          ),
        ),
      );
      return {
        'data': data,
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullAopAchievementDrillDownReport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          filterType: filterType,
          tabName: tabName,
          columnName: columnName,
          queryParams: queryParams,
          achivementDrillDownType: achivementDrillDownType,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>>
  apiCallPullAopAchievementDrillDownReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    required String tabName,
    required String columnName,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullAopAchievementDrillDownReportUrl({
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "AOPAchievementReport/PullAOPAchievementDrillDownReport"
          "?pageSize=$pageSize"
          "&pageNumber=$pageNumber"
          "&TabName=$tabName"
          "&ColumnName=${Uri.encodeQueryComponent(columnName)}"
          "&FilterType=$filterType";

      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullAopAchievementDrillDownReportUrl(queryParams: queryParams),
      );

      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullAopAchievementDrillDownReportForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          filterType: filterType,
          tabName: tabName,
          columnName: columnName,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
