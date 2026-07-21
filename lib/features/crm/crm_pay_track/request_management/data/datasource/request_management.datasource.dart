import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_ledger_summary.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/booking_applicant_modification_request.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/flat_alteration_requests.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/parking_modification_request.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/refund_amount_payment_ledger.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class RequestManagementDatasource {
  Future<Map<String, dynamic>> apicallPullFlatAlterationRequest({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullParkingModificationRequest({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullBookingApplicantModificationRequest({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> deleteBookingApplicantModificationRequest({
    required int projectId,
    required int bookingApplicantModificationRequestId,
    required int bookingId,
  });
  Future<Map<String, dynamic>> apicallAddFlatAlterationRequest({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeleteFlatAlterationRequest({
    required int flatAlterationRequestId,
    required String uniqueKey,
    required int bookingId,
    required int projectId,
  });
  Future<Map<String, dynamic>> apicallAddParkingModificationRequest({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Map<String, dynamic>> apicallDeletParkingModificationRequest({
    required int parkingModificationRequestId,
    required String uniqueKey,
    required int bookingId,
    required int projectId,
  });
  Future<Map<String, dynamic>>
  apicallUpdateBookingApplicantModificationRequest({
    required int bookingId,
    required int projectId,
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Map<String, dynamic>>
  apicallAmountRefundedAgainstBookingAddUpdateRefundedAmount({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apicallPullRefundedAmountLedger({
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallAddUpdateRefundedAmountLedger({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Map<String, dynamic>> deleteRefundedAmountLedger({
    required int projectId,
    required int refundedAmountLedgerId,
    required int bookingId,
    required String uniqueKey,
  });
}

class RequestManagementDatasourceImpl extends RequestManagementDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullFlatAlterationRequest({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String url({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required int bookingId,
      Map<String, dynamic>? queryParams,
    }) {
      String finalUrl =
          "BookingModificationRequest/PullFlatAlterationRequest?PageSize=$pageSize"
          "&PageNumber=$pageNumber&ProjectId=$projectId&BookingId=$bookingId";

      queryParams?.forEach((key, value) => finalUrl += "&$key=$value");
      return finalUrl;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        url(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          bookingId: bookingId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<FlatAlterationRequestsModel>.from(
          networkResponse["data"].map(
            (e) => FlatAlterationRequestsModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullFlatAlterationRequest(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          bookingId: bookingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullParkingModificationRequest({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String url({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required int bookingId,
      Map<String, dynamic>? queryParams,
    }) {
      String finalUrl =
          "BookingModificationRequest/PullParkingModificationRequest?PageSize=$pageSize"
          "&PageNumber=$pageNumber&ProjectId=$projectId&BookingId=$bookingId";

      queryParams?.forEach((key, value) => finalUrl += "&$key=$value");
      return finalUrl;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        url(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          bookingId: bookingId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<ParkingModificationRequestModel>.from(
          networkResponse["data"].map(
            (e) => ParkingModificationRequestModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullParkingModificationRequest(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          bookingId: bookingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullBookingApplicantModificationRequest({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String url({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required int bookingId,
      Map<String, dynamic>? queryParams,
    }) {
      String finalUrl =
          "BookingModificationRequest/PullBookingApplicantModificationRequest?PageSize=$pageSize"
          "&PageNumber=$pageNumber&ProjectId=$projectId&BookingId=$bookingId";

      queryParams?.forEach((key, value) => finalUrl += "&$key=$value");
      return finalUrl;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        url(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          bookingId: bookingId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<BookingApplicantModificationRequestModel>.from(
          networkResponse["data"].map(
            (e) => BookingApplicantModificationRequestModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullBookingApplicantModificationRequest(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          bookingId: bookingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddFlatAlterationRequest({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    const url = "BookingModificationRequest/AddFlatAlterationRequest";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(url, fileList, body);

      return {
        'data': List<FlatAlterationRequestsModel>.from(
          networkResponse["data"].map(
            (e) => FlatAlterationRequestsModel.fromJson(e),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddFlatAlterationRequest(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddParkingModificationRequest({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    const url = "BookingModificationRequest/AddParkingModificationRequest";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(url, fileList, body);

      return {
        'data': List<ParkingModificationRequestModel>.from(
          networkResponse["data"].map(
            (e) => ParkingModificationRequestModel.fromJson(e),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddParkingModificationRequest(
          body: body,
          fileList: fileList,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>>
  apicallUpdateBookingApplicantModificationRequest({
    required int bookingId,
    required int projectId,
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    const url =
        "BookingModificationRequest/BookingApplicantModificationRequest";

    body.addAll({
      "BookingId": bookingId.toString(),
      "ProjectId": projectId.toString(),
    });

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(url, fileList, body);

      return {
        'data': List<BookingApplicantModificationRequestModel>.from(
          networkResponse["data"].map(
            (e) => BookingApplicantModificationRequestModel.fromJson(e),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallUpdateBookingApplicantModificationRequest(
          bookingId: bookingId,
          projectId: projectId,
          body: body,
          fileList: fileList,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>>
  apicallAmountRefundedAgainstBookingAddUpdateRefundedAmount({
    required Map<String, dynamic> body,
  }) async {
    const url = "AmountRefundedAgainstBooking/AddUpdateRefundedAmount";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        url,
        body,
      );

      return {
        'data': networkResponse['data'],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAmountRefundedAgainstBookingAddUpdateRefundedAmount(
          body: body,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullRefundedAmountLedger({
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String url({
      required int projectId,
      required int bookingId,
      Map<String, dynamic>? queryParams,
    }) {
      String finalUrl =
          "AmountRefundedAgainstBooking/PullRefundedAmountLedger?ProjectId=$projectId&BookingId=$bookingId";

      queryParams?.forEach((key, value) => finalUrl += "&$key=$value");
      return finalUrl;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        url(
          projectId: projectId,
          bookingId: bookingId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<RefundedAmountLedgerModel>.from(
          networkResponse["data"].map(
            (e) => RefundedAmountLedgerModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullRefundedAmountLedger(
          projectId: projectId,
          bookingId: bookingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateRefundedAmountLedger({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String url = "AmountRefundedAgainstBooking/AddUpdateRefundedAmountLedger";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(url, fileList, body);

      return {
        'data': List<PayTrackPaymentLedgerSummaryModel>.from(
          networkResponse["data"].map(
            (e) => PayTrackPaymentLedgerSummaryModel.fromJson(e),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddUpdateRefundedAmountLedger(
          body: body,
          fileList: fileList,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> deleteRefundedAmountLedger({
    required int projectId,
    required int refundedAmountLedgerId,
    required int bookingId,
    required String uniqueKey,
  }) async {
    String deleteRefundedAmountLedgerUrl({
      required int projectId,
      required int refundedAmountLedgerId,
      required int bookingId,
      required String uniqueKey,
    }) {
      return "AmountRefundedAgainstBooking/DeleteRefundedAmountLedger?RefundedAmountLedgerId=$refundedAmountLedgerId&Uniquekey=$uniqueKey&BookingId=$bookingId&ProjectId=$projectId";
    }

    try {
      final networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteRefundedAmountLedgerUrl(
          projectId: projectId,
          refundedAmountLedgerId: refundedAmountLedgerId,
          bookingId: bookingId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse['data'],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        deleteRefundedAmountLedger(
          projectId: projectId,
          refundedAmountLedgerId: refundedAmountLedgerId,
          bookingId: bookingId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> deleteBookingApplicantModificationRequest({
    required int projectId,
    required int bookingApplicantModificationRequestId,
    required int bookingId,
  }) async {
    String deleteBookingApplicantModificationRequestUrl({
      required int projectId,
      required int bookingApplicantModificationRequestId,
      required int bookingId,
    }) {
      return "BookingModificationRequest/DeleteBookingApplicantModificationRequest?BookingApplicantModificationRequestId=$bookingApplicantModificationRequestId&BookingId=$bookingId&ProjectId=$projectId";
    }

    try {
      final networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteBookingApplicantModificationRequestUrl(
          projectId: projectId,
          bookingApplicantModificationRequestId:
              bookingApplicantModificationRequestId,
          bookingId: bookingId,
        ),
      );
      return {
        'data': networkResponse['data'],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        deleteBookingApplicantModificationRequest(
          projectId: projectId,
          bookingApplicantModificationRequestId:
              bookingApplicantModificationRequestId,
          bookingId: bookingId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteFlatAlterationRequest({
    required int flatAlterationRequestId,
    required String uniqueKey,
    required int bookingId,
    required int projectId,
  }) async {
    String deleteDepartmentUrl({
      required int flatAlterationRequestId,
      required String uniqueKey,
      required int bookingId,
      required int projectId,
    }) {
      return "BookingModificationRequest/DeleteFlatAlterationRequest?FlatAlterationRequestId=$flatAlterationRequestId&Uniquekey=$uniqueKey&BookingId=$bookingId&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteDepartmentUrl(
          flatAlterationRequestId: flatAlterationRequestId,
          uniqueKey: uniqueKey,
          bookingId: bookingId,
          projectId: projectId,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['TotalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallDeleteFlatAlterationRequest(
          flatAlterationRequestId: flatAlterationRequestId,
          uniqueKey: uniqueKey,
          bookingId: bookingId,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeletParkingModificationRequest({
    required int parkingModificationRequestId,
    required String uniqueKey,
    required int bookingId,
    required int projectId,
  }) async {
    String deleteDepartmentUrl({
      required int parkingModificationRequestId,
      required String uniqueKey,
      required int bookingId,
      required int projectId,
    }) {
      return "BookingModificationRequest/DeleteParkingModificationRequest?ParkingModificationRequestId=$parkingModificationRequestId&Uniquekey=$uniqueKey&BookingId=$bookingId&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteDepartmentUrl(
          parkingModificationRequestId: parkingModificationRequestId,
          uniqueKey: uniqueKey,
          bookingId: bookingId,
          projectId: projectId,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['TotalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallDeletParkingModificationRequest(
          parkingModificationRequestId: parkingModificationRequestId,
          uniqueKey: uniqueKey,
          bookingId: bookingId,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }
}
