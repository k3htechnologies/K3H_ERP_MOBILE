import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class BookingDatasource {
  Future<Map<String, dynamic>> apiCallPullBooking({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallAddUpdateBooking({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
}

class BookingDatasourceImpl extends BookingDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullBooking({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullBookingUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Booking/PullBooking?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullBookingUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<BookingModel>.from(
          networkResponse["data"].map(
            (e) => BookingModel.fromJson(e, setOtherCharge: true),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullBooking(
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
  Future<Map<String, dynamic>> apiCallAddUpdateBooking({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateBookingUrl = "Booking/AddUpdateBooking";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateBookingUrl,
            fileList,
            body,
          );
      return {
        'data': List<BookingModel>.from(
          networkResponse["data"].map((e) => BookingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateBooking(body: body, fileList: fileList);
      }
      rethrow;
    }
  }
}
