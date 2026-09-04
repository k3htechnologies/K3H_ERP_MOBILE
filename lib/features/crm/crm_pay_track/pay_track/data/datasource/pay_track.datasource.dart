import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

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
      Map<String, dynamic>? queryParams,
      required int pageSize,
      required int pageNumber,
      required int projectId,
    }) {
      String url =
          "PayTrack/PullPayTrackBooking?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
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
      url += queryParamsFormatter(queryParams: queryParams);
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
      url += queryParamsFormatter(queryParams: queryParams);
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
}
