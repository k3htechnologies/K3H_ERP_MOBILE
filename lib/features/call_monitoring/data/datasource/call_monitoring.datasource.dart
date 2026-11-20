import 'package:k3h_erp_app/features/call_monitoring/data/model/call_monitoring.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class CallMonitoringDatasource {
  Future<Map<String, dynamic>> apiCallPullCallMonitoring({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int id,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallToAddCallMonitoring({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apiCallToUpdateCallMonitoring({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apicallDeleteCallMonitoring({
    required int callMonitoringId,
    required String uniqueKey,
    required int projectId,
  });
  Future<Map<String, dynamic>> apiCallPullCallMonitoringForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class CallMonitoringDatasourceImpl extends CallMonitoringDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullCallMonitoring({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int id,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPayTrackUrl({
      Map<String, dynamic>? queryParams,
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required int id,
    }) {
      String url =
          "PayTrackCallLog/PullPayTrackCallLog?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&Id=$id";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullPayTrackUrl(
          pageSize: pageSize,
          projectId: projectId,
          pageNumber: pageNumber,
          queryParams: queryParams,
          id: id,
        ),
      );

      return {
        'data': List<CallMonitoringModel>.from(
          networkResponse['data'].map((e) => CallMonitoringModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullCallMonitoring(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
          id: id,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallToAddCallMonitoring({
    required Map<String, dynamic> body,
  }) async {
    const String url = "CallMonitoring/AddCallMonitoring";

    try {
      final networkResponse = await baseClient.postRequestWithAuthentication(
        url,
        body,
      );

      return {
        'data': networkResponse['data'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallToAddCallMonitoring(body: body);
      }

      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallToUpdateCallMonitoring({
    required Map<String, dynamic> body,
  }) async {
    String updateCallLogUrl = "PayTrackCallLog/UpdatePayTrackCallLog";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        updateCallLogUrl,
        body,
      );
      return {
        'data': List<CallMonitoringModel>.from(
          networkResponse["data"].map((e) => CallMonitoringModel.fromJson(e)),
        ),
        'message': networkResponse["message"],
        'totalNumberOfRecord': networkResponse["totalNumberOfRecord"],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallToUpdateCallMonitoring(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteCallMonitoring({
    required int callMonitoringId,
    required String uniqueKey,
    required int projectId,
  }) async {
    String deletePayTrackCallMonitoringUrl({
      required int callMonitoringId,
      required int projectId,
      required String uniqueKey,
    }) {
      return "PayTrackCallLog/DeletePayTrackCallLog?CallMonitoringId=$callMonitoringId"
          "&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deletePayTrackCallMonitoringUrl(
          callMonitoringId: callMonitoringId,
          projectId: projectId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteCallMonitoring(
          callMonitoringId: callMonitoringId,
          projectId: projectId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullCallMonitoringForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullAopAchievementReportUrl({Map<String, dynamic>? queryParams}) {
      String url =
          "PayTrackCallLog/PullPayTrackCallLog?pageNumber=$pageNumber&pageSize=$pageSize";
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
        return apiCallPullCallMonitoringForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
