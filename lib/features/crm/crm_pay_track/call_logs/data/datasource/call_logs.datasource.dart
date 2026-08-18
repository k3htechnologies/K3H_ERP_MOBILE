import 'package:k3h_erp_app/features/crm/crm_pay_track/call_logs/data/model/pay_track_call_log.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class CallLogsDatasource {
  Future<Map<String, dynamic>> apiCallPullCallLog({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallToUpdateCallLog({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apicallDeleteCallLogs({
    required int payTrackCallLogId,
    required String uniqueKey,
    required int projectId,
    required int bookingId,
  });
  Future<Map<String, dynamic>> apiCallPullCallLogsForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class CallLogsDatasourceImpl extends CallLogsDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullCallLog({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPayTrackUrl({
      Map<String, dynamic>? queryParams,
      required int pageSize,
      required int pageNumber,
      required int projectId,
    }) {
      String url =
          "PayTrackCallLog/PullPayTrackCallLog?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
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
        ),
      );

      return {
        'data': List<PayTrackCallLogModel>.from(
          networkResponse['data'].map((e) => PayTrackCallLogModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullCallLog(
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
  Future<Map<String, dynamic>> apiCallToUpdateCallLog({
    required Map<String, dynamic> body,
  }) async {
    String updateCallLogUrl = "PayTrackCallLog/UpdatePayTrackCallLog";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        updateCallLogUrl,
        body,
      );
      return {
        'data': List<PayTrackCallLogModel>.from(
          networkResponse["data"].map((e) => PayTrackCallLogModel.fromJson(e)),
        ),
        'message': networkResponse["message"],
        'totalNumberOfRecord': networkResponse["totalNumberOfRecord"],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallToUpdateCallLog(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteCallLogs({
    required int payTrackCallLogId,
    required String uniqueKey,
    required int projectId,
    required int bookingId,
  }) async {
    String deletePayTrackCallLogsUrl({
      required int payTrackCallLogId,
      required int projectId,
      required int bookingId,
      required String uniqueKey,
    }) {
      return "PayTrackCallLog/DeletePayTrackCallLog?PayTrackCallLogId=$payTrackCallLogId"
          "&ProjectId=$projectId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deletePayTrackCallLogsUrl(
          payTrackCallLogId: payTrackCallLogId,
          bookingId: bookingId,
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
        apicallDeleteCallLogs(
          payTrackCallLogId: payTrackCallLogId,
          projectId: projectId,
          bookingId: bookingId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullCallLogsForExport({
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
        return apiCallPullCallLogsForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
