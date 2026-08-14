import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_call_log.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class PayTrackDatasource {
  Future<Map<String, dynamic>> apiCallPullPayTrack({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallPullPayTrackByBookingId({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallPullPayTrackCallLog({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallPullPayTrackForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>>
  apiCallUpdatePayTrackBookingRegistrationDateParking({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Map<String, dynamic>> apicallDeleteDeletePayTrackCallLogs({
    required int payTrackCallLogId,
    required String uniqueKey,
    required int projectId,
    required int bookingId,
  });
  Future<Map<String, dynamic>> apiCallToUpdatePayTrackCallLog({
    required Map<String, dynamic> body,
  });
}

class PayTrackDatasourceImpl extends PayTrackDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullPayTrack({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPayTrackUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "PayTrack/PullPayTrackBooking?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
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
        'data': List<PayTrackModel>.from(
          networkResponse['data'].map((e) => PayTrackModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullPayTrack(
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
  Future<Map<String, dynamic>> apiCallPullPayTrackByBookingId({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPayTrackUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required int bookingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "PayTrack/PullPayTrackBooking?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&BookingId=$bookingId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullPayTrackUrl(
          pageSize: pageSize,
          projectId: projectId,
          pageNumber: pageNumber,
          bookingId: bookingId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<PayTrackModel>.from(
          networkResponse['data'].map((e) => PayTrackModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullPayTrack(
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
  Future<Map<String, dynamic>> apiCallPullPayTrackCallLog({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPayTrackUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "PayTrackCallLog/PullPayTrackCallLog?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
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
        apiCallPullPayTrack(
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
  Future<Map<String, dynamic>> apiCallPullPayTrackForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPayTrackExportUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "PayTrack/PullPayTrackBooking?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullPayTrackExportUrl(
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
        apiCallPullPayTrackForExport(
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
  Future<Map<String, dynamic>>
  apiCallUpdatePayTrackBookingRegistrationDateParking({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdatePayTrackBookingFilesUrl =
        "Booking/UpdatePayTrackBookingRegistrationDateParking";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdatePayTrackBookingFilesUrl,
            fileList,
            body,
          );
      return {
        'data': List<BookingModel>.from(
          networkResponse["data"].map((e) => BookingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallUpdatePayTrackBookingRegistrationDateParking(
          body: body,
          fileList: fileList,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteDeletePayTrackCallLogs({
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
        apicallDeleteDeletePayTrackCallLogs(
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
  Future<Map<String, dynamic>> apiCallToUpdatePayTrackCallLog({
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
        apiCallToUpdatePayTrackCallLog(body: body);
      }
      rethrow;
    }
  }
}
