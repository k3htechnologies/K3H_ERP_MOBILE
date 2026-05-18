import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_ledger.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

import '../model/pay_track_payment_schedule.model.dart';

abstract interface class PaymentDatasource {
  Future<Map<String, dynamic>> apicallPullPayTrackPaymentSchedule({
    required int bookingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullPayTrackPaymentLedger({
    required int bookingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdatePayTrackPaymentLedger({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeletePayTrackPaymentLedger({
    required int projectId,
    required int payTrackPaymentLedgerId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallPullPayTrackPaymentLedgerForExport({
    required int bookingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallAddUpdatePayTrackPaymentScheduleDemand({
    required Map<String, String> body,
  });
}

class PaymentDatasourceImpl extends PaymentDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullPayTrackPaymentSchedule({
    required int bookingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String url({
      required int bookingId,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String finalUrl =
          "PayTrack/PullPayTrackPaymentSchedule?BookingId=$bookingId&ProjectId=$projectId";

      queryParams?.forEach((key, value) => finalUrl += "&$key=$value");
      return finalUrl;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        url(
          bookingId: bookingId,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<PayTrackPaymentScheduleModel>.from(
          networkResponse["data"].map(
            (e) => PayTrackPaymentScheduleModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullPayTrackPaymentSchedule(
          bookingId: bookingId,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullPayTrackPaymentLedger({
    required int bookingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String url({
      required int bookingId,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String finalUrl =
          "PayTrack/PullPayTrackPaymentLedger?BookingId=$bookingId&ProjectId=$projectId";

      queryParams?.forEach((key, value) => finalUrl += "&$key=$value");
      return finalUrl;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        url(
          bookingId: bookingId,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<PayTrackPaymentLedgerModel>.from(
          networkResponse["data"].map(
            (e) => PayTrackPaymentLedgerModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullPayTrackPaymentLedger(
          bookingId: bookingId,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdatePayTrackPaymentLedger({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String url = "PayTrack/AddUpdatePayTrackPaymentLedger";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(url, fileList, body);

      return {
        'data': List<PayTrackPaymentLedgerModel>.from(
          networkResponse["data"].map(
            (e) => PayTrackPaymentLedgerModel.fromJson(e),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddUpdatePayTrackPaymentLedger(
          body: body,
          fileList: fileList,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeletePayTrackPaymentLedger({
    required int projectId,
    required int payTrackPaymentLedgerId,
    required String uniqueKey,
  }) async {
    String url({
      required int projectId,
      required int payTrackPaymentLedgerId,
      required String uniqueKey,
    }) {
      return "PayTrack/DeletePayTrackPaymentLedger?"
          "ProjectId=$projectId"
          "&PayTrackPaymentLedgerId=$payTrackPaymentLedgerId"
          "&UniqueKey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        url(
          projectId: projectId,
          payTrackPaymentLedgerId: payTrackPaymentLedgerId,
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
        return apicallDeletePayTrackPaymentLedger(
          projectId: projectId,
          payTrackPaymentLedgerId: payTrackPaymentLedgerId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullPayTrackPaymentLedgerForExport({
    required int bookingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String url({
      required int bookingId,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String finalUrl =
          "PayTrack/PullPayTrackPaymentLedger?BookingId=$bookingId&ProjectId=$projectId";

      queryParams?.forEach((key, value) => finalUrl += "&$key=$value");
      return finalUrl;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        url(
          bookingId: bookingId,
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
        return apicallPullPayTrackPaymentLedgerForExport(
          bookingId: bookingId,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdatePayTrackPaymentScheduleDemand({
    required Map<String, String> body,
  }) async {
    String url = "PayTrack/AddUpdatePayTrackPaymentScheduleDemand";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        url,
        body,
      );

      return {
        'data': List<PayTrackPaymentLedgerModel>.from(
          networkResponse["data"].map(
            (e) => PayTrackPaymentLedgerModel.fromJson(e),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddUpdatePayTrackPaymentScheduleDemand(body: body);
      }
      rethrow;
    }
  }
}
