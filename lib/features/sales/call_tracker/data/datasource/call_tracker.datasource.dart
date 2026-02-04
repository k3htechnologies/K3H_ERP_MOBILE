import 'package:k3h_erp_app/features/sales/call_tracker/data/model/call_log.model.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/data/model/calling_data.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class CallTrackerDataSource {
  Future<Map<String, dynamic>> apicallPullCallingData({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullCallLog({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallToAddCallLog({
    required Map<String, String> body,
  });
  Future<Map<String, dynamic>> apiCallToUpdateCallLog({
    required Map<String, String> body,
  });
  Future<Map<String, dynamic>> apicallDeleteCallLog({
    required int projectId,
    required int callLogId,
    required String uniqueKey,
  });
}

class CallTrackerDataSourceImpl implements CallTrackerDataSource {
  final BaseClient _baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullCallingData({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullCallingDataUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "CallTracker/PullCallingData?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await _baseClient.getRequestWithAuthentication(
        pullCallingDataUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<CallingDataModel>.from(
          networkResponse["data"].map((e) => CallingDataModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullCallingData(
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
  Future<Map<String, dynamic>> apicallPullCallLog({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullCallLogUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "CallLog/PullCallLog?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await _baseClient.getRequestWithAuthentication(
        pullCallLogUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<CallLogModel>.from(
          networkResponse["data"].map((e) => CallLogModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullCallLog(
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
  Future<Map<String, dynamic>> apiCallToAddCallLog({
    required Map<String, String> body,
  }) async {
    String addCallLogUrl = "CallLog/AddCallLog";

    try {
      var networkResponse = await _baseClient.postRequestWithAuthentication(
        addCallLogUrl,
        body,
      );
      return {
        'data': List<CallLogModel>.from(
          networkResponse["data"].map((e) => CallLogModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallToAddCallLog(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallToUpdateCallLog({
    required Map<String, String> body,
  }) async {
    String updateCallLogUrl = "CallLog/UpdateCallLog";

    try {
      var networkResponse = await _baseClient.postRequestWithAuthentication(
        updateCallLogUrl,
        body,
      );
      return {
        'data': List<CallLogModel>.from(
          networkResponse["data"].map((e) => CallLogModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallToUpdateCallLog(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteCallLog({
    required int projectId,
    required int callLogId,
    required String uniqueKey,
  }) async {
    String deleteCallLogUrl({
      required int projectId,
      required int callLogId,
      required String uniqueKey,
    }) {
      return "CallLog/DeleteCallLog?CallLogId=$callLogId&Uniquekey=$uniqueKey&ProjectId=$projectId";
    }

    try {
      var networkResponse = await _baseClient.deleteRequestWithAuthentication(
        deleteCallLogUrl(
          projectId: projectId,
          callLogId: callLogId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteCallLog(
          projectId: projectId,
          callLogId: callLogId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }
}
