import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/achivement_drill_down_report.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

import '../model/closing_achievement_report.model.dart';
import '../model/project_achievement_report.model.dart';
import '../model/sourcing_achievement_report.model.dart';

abstract interface class AchievementReportDatasource {
  Future<Map<String, dynamic>> apiCallPullProjectAchievementReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallPullClosingAchievementReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallPullSourcingAchievementReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallPullProjectAchievementReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallPullClosingAchievementReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallPullSourcingAchievementReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallPullAchievementDrillDownReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    required String tabName,
    required String columnName,
    required AchievementDrillDownType achivementDrillDownType,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallPullAchievementDrillDownReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    required String tabName,
    required String columnName,
    Map<String, dynamic>? queryParams,
  });
}

class AchievementReportDatasourceImpl extends AchievementReportDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullProjectAchievementReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectAchievementReportUrl({
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "AchievementReport/PullProjectAchievementReport?pageNumber=$pageNumber&pageSize=$pageSize&FilterType=$filterType";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectAchievementReportUrl(queryParams: queryParams),
      );

      return {
        'data': List<ProjectAchievementReportModel>.from(
          networkResponse["data"].map(
            (e) => ProjectAchievementReportModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullProjectAchievementReport(
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
  Future<Map<String, dynamic>> apiCallPullClosingAchievementReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullClosingAchievementReportUrl({
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "AchievementReport/PullClosingAchievementReport?pageNumber=$pageNumber&pageSize=$pageSize&FilterType=$filterType";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullClosingAchievementReportUrl(queryParams: queryParams),
      );

      return {
        'data': List<ClosingAchievementReportModel>.from(
          networkResponse["data"].map(
            (e) => ClosingAchievementReportModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullClosingAchievementReport(
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
  Future<Map<String, dynamic>> apiCallPullSourcingAchievementReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullSourcingAchievementReportUrl({
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "AchievementReport/PullSourcingAchievementReport?pageNumber=$pageNumber&pageSize=$pageSize&FilterType=$filterType";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullSourcingAchievementReportUrl(queryParams: queryParams),
      );

      return {
        'data': List<SourcingAchievementReportModel>.from(
          networkResponse["data"].map(
            (e) => SourcingAchievementReportModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullSourcingAchievementReport(
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
  Future<Map<String, dynamic>> apiCallPullProjectAchievementReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectAchievementReportUrl({
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "AchievementReport/PullProjectAchievementReport?pageNumber=$pageNumber&pageSize=$pageSize&FilterType=$filterType";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectAchievementReportUrl(queryParams: queryParams),
      );

      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullProjectAchievementReportForExport(
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
  Future<Map<String, dynamic>> apiCallPullClosingAchievementReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullClosingAchievementReportUrl({
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "AchievementReport/PullClosingAchievementReport?pageNumber=$pageNumber&pageSize=$pageSize&FilterType=$filterType";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullClosingAchievementReportUrl(queryParams: queryParams),
      );

      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullClosingAchievementReportForExport(
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
  Future<Map<String, dynamic>> apiCallPullSourcingAchievementReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullSourcingAchievementReportUrl({
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "AchievementReport/PullSourcingAchievementReport?pageNumber=$pageNumber&pageSize=$pageSize&FilterType=$filterType";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullSourcingAchievementReportUrl(queryParams: queryParams),
      );

      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullSourcingAchievementReportForExport(
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
  Future<Map<String, dynamic>> apiCallPullAchievementDrillDownReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    required String tabName,
    required String columnName,
    required AchievementDrillDownType achivementDrillDownType,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullAchievementDrillDownReportUrl({
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "AchievementReport/PullAchievementDrillDownReport"
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
        pullAchievementDrillDownReportUrl(queryParams: queryParams),
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
        return apiCallPullAchievementDrillDownReport(
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
  Future<Map<String, dynamic>> apiCallPullAchievementDrillDownReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    required String tabName,
    required String columnName,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullAchievementDrillDownReportUrl({
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "AchievementReport/PullAchievementDrillDownReport"
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
        pullAchievementDrillDownReportUrl(queryParams: queryParams),
      );

      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullAchievementDrillDownReportForExport(
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
