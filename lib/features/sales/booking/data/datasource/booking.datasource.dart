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
  Future<Map<String, dynamic>> apiCallPullPaymentScheduleStages({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallCancelBooking({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apiCallPullBookingForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class BookingDatasourceImpl extends BookingDatasource {
  final BaseClient baseClient = BaseClient();

  // PULL BOOKING
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

  // ADD / UPADATE BOOKING
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

  // PULL PAYMENT SCHEDULE
  @override
  Future<Map<String, dynamic>> apiCallPullPaymentScheduleStages({
    required int pageNumber,
    required int pageSize,
    required int projectId,

    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPaymentScheduleStagesUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Booking/PullPaymentScheduleStages"
          "?PageSize=$pageSize"
          "&PageNumber=$pageNumber"
          "&ProjectId=$projectId"
          "&InventoryBuildingId=$inventoryBuildingId"
          "&InventoryFlatFloorBasementPodiumWingId=$inventoryFlatFloorBasementPodiumWingId";

      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullPaymentScheduleStagesUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<Map<String, dynamic>>.from(networkResponse["data"] ?? []),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullPaymentScheduleStages(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          inventoryBuildingId: inventoryBuildingId,
          inventoryFlatFloorBasementPodiumWingId:
              inventoryFlatFloorBasementPodiumWingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  //  CANCEL BOOKING
  @override
  Future<Map<String, dynamic>> apiCallCancelBooking({
    required Map<String, dynamic> body,
  }) async {
    String closeBookingUrl = "Booking/CancelBooking";
    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        closeBookingUrl,
        body,
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallCancelBooking(body: body);
      }
      rethrow;
    }
  }

  // EXPORT BOOKING
  @override
  Future<Map<String, dynamic>> apiCallPullBookingForExport({
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
        'data': networkResponse["data"],
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
}
