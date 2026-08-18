import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_booking_files.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class PayTrackBookingFilesDatasource {
  Future<Map<String, dynamic>> apiCallPullPayTrackBookingFiles({
    required int pageNumber,
    required int pageSize,
    required String fileType,
    required int bookingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallAddUpdatePayTrackBookingFiles({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeletePayTrackBookingFiles({
    required int payTrackBookingFilesId,
    required int projectId,
    required int bookingId,
    required String uniqueKey,
  });
}

class PayTrackBookingFilesDatasourceImpl
    extends PayTrackBookingFilesDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullPayTrackBookingFiles({
    required int pageNumber,
    required int pageSize,
    required String fileType,
    required int bookingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPayTrackBookingFilesUrl({
      Map<String, dynamic>? queryParams,
      required int pageSize,
      required int pageNumber,
      required String fileType,
      required int bookingId,
      required int projectId,
    }) {
      String url =
          "PayTrackBookingFiles/PullPayTrackBookingFiles?PageSize=$pageSize"
          "&PageNumber=$pageNumber&FileType=$fileType&BookingId=$bookingId&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullPayTrackBookingFilesUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          fileType: fileType,
          bookingId: bookingId,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<PayTrackBookingFilesModel>.from(
          networkResponse['data'].map(
            (e) => PayTrackBookingFilesModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullPayTrackBookingFiles(
          pageNumber: pageNumber,
          pageSize: pageSize,
          fileType: fileType,
          bookingId: bookingId,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallAddUpdatePayTrackBookingFiles({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdatePayTrackBookingFilesUrl =
        "PayTrackBookingFiles/AddUpdatePayTrackBookingFiles";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdatePayTrackBookingFilesUrl,
            fileList,
            body,
          );
      return {
        'data': List<PayTrackBookingFilesModel>.from(
          networkResponse["data"].map(
            (e) => PayTrackBookingFilesModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdatePayTrackBookingFiles(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeletePayTrackBookingFiles({
    required int payTrackBookingFilesId,
    required int projectId,
    required int bookingId,
    required String uniqueKey,
  }) async {
    String deletePayTrackBookingFilesUrl({
      Map<String, dynamic>? queryParams,
      required int payTrackBookingFilesId,
      required int projectId,
      required int bookingId,
      required String uniqueKey,
    }) {
      String url =
          "PayTrackBookingFiles/DeletePayTrackBookingFiles?PayTrackBookingFilesId=$payTrackBookingFilesId"
          "&ProjectId=$projectId&BookingId=$bookingId&Uniquekey=$uniqueKey";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deletePayTrackBookingFilesUrl(
          payTrackBookingFilesId: payTrackBookingFilesId,
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
        apicallDeletePayTrackBookingFiles(
          payTrackBookingFilesId: payTrackBookingFilesId,
          projectId: projectId,
          bookingId: bookingId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }
}
