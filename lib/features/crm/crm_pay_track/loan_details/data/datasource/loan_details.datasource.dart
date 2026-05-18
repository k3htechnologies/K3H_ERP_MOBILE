import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/data/model/loan_details.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class BookingLoanDetailsDatasource {
  Future<Map<String, dynamic>> apicallPullBookingLoanDetails({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateBookingLoanDetails({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteBookingLoanDetails({
    required int bookingLoanDetailsId,
    required String uniqueKey,
    required int projectId,
    required int bookingId,
  });

  Future<Map<String, dynamic>> apicallUpdateBookingLoanDetailsStatus({
    required Map<String, dynamic> body,
  });
}

class BookingLoanDetailsDatasourceImpl extends BookingLoanDetailsDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullBookingLoanDetails({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullBookingLoanDetailsUrl({
      required int pageSize,
      required int pageNumber,
      required int bookingId,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "BookingLoanDetails/PullBookingLoanDetails?PageSize=$pageSize"
          "&PageNumber=$pageNumber&BookingId=$bookingId&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullBookingLoanDetailsUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          bookingId: bookingId,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<BookingLoanDetailsModel>.from(
          networkResponse["data"].map(
            (e) => BookingLoanDetailsModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullBookingLoanDetails(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          bookingId: bookingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateBookingLoanDetails({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateBookingLoanDetailsUrl =
        "BookingLoanDetails/AddUpdateBookingLoanDetails";
    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateBookingLoanDetailsUrl,
        body,
      );
      return {
        'data': List<BookingLoanDetailsModel>.from(
          networkResponse["data"].map(
            (e) => BookingLoanDetailsModel.fromJson(e),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateBookingLoanDetails(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteBookingLoanDetails({
    required int bookingLoanDetailsId,
    required String uniqueKey,
    required int projectId,
    required int bookingId,
  }) async {
    String deleteBookingLoanDetailsUrl({
      required int bookingLoanDetailsId,
      required int projectId,
      required int bookingId,
      required String uniqueKey,
    }) {
      return "BookingLoanDetails/DeleteBookingLoanDetails?BookingLoanDetailsId=$bookingLoanDetailsId"
          "&ProjectId=$projectId&BookingId=$bookingId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteBookingLoanDetailsUrl(
          bookingLoanDetailsId: bookingLoanDetailsId,
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
        apicallDeleteBookingLoanDetails(
          bookingLoanDetailsId: bookingLoanDetailsId,
          projectId: projectId,
          bookingId: bookingId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallUpdateBookingLoanDetailsStatus({
    required Map<String, dynamic> body,
  }) async {
    String updateBookingLoanDetailsStatusUrl =
        "BookingLoanDetails/UpdateBookingLoanDetailsStatus";
    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        updateBookingLoanDetailsStatusUrl,
        body,
      );
      return {
        'data': List<BookingLoanDetailsModel>.from(
          networkResponse["data"].map(
            (e) => BookingLoanDetailsModel.fromJson(e),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateBookingLoanDetails(body: body);
      }
      rethrow;
    }
  }
}
