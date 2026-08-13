import 'package:k3h_erp_app/features/crm/brokerage/data/model/brokerage.model.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/brokerage_invoice.model.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/paid_brokerage_booking.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class BrokerageDatasource {
  Future<Map<String, dynamic>> apicallPullBrokerageBooking({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullBrokerageInvoice({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> addUpdateBrokerageInvoice({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> deleteBrokerageInvoice({
    required int projectId,
    required int brokerageInvoiceId,
    required int bookingId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> pullPaidBrokerageBooking({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> addUpdatePaidBrokerageBooking({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> deletePaidBrokerageBooking({
    required int projectId,
    required int bookingId,
    required int paidBrokerageBookingId,
    required int brokerageInvoiceId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallPullBrokerageBookingForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallPullBrokerageInvoiceForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> pullPaidBrokerageBookingForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });
}

class BrokerageDatasourceImpl extends BrokerageDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullBrokerageBooking({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullBrokerageBookingUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Brokerage/PullBrokerageBooking?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullBrokerageBookingUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<BrokerageModel>.from(
          networkResponse["data"].map((e) => BrokerageModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullBrokerageBooking(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullBrokerageInvoice({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullBrokerageInvoiceUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required int bookingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Brokerage/PullBrokerageInvoice?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&BookingId=$bookingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      final networkResponse = await baseClient.getRequestWithAuthentication(
        pullBrokerageInvoiceUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          bookingId: bookingId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<BrokerageInvoiceModel>.from(
          (networkResponse['data'] as List<dynamic>).map(
            (e) => BrokerageInvoiceModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullBrokerageInvoice(
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
  Future<Map<String, dynamic>> addUpdateBrokerageInvoice({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateBrokerageInvoiceUrl = "Brokerage/AddUpdateBrokerageInvoice";

    try {
      final networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateBrokerageInvoiceUrl,
            fileList,
            body,
          );
      return {
        'data': List<BrokerageInvoiceModel>.from(
          (networkResponse['data'] as List<dynamic>).map(
            (e) => BrokerageInvoiceModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return addUpdateBrokerageInvoice(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> deleteBrokerageInvoice({
    required int projectId,
    required int brokerageInvoiceId,
    required int bookingId,
    required String uniqueKey,
  }) async {
    String deleteCrmBrokerageInvoiceUrl({
      required int projectId,
      required int brokerageInvoiceId,
      required int bookingId,
      required String uniqueKey,
    }) {
      return "Brokerage/DeleteBrokerageInvoice?BrokerageInvoiceId=$brokerageInvoiceId&BookingId=$bookingId&Uniquekey=$uniqueKey&ProjectId=$projectId";
    }

    try {
      final networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteCrmBrokerageInvoiceUrl(
          projectId: projectId,
          brokerageInvoiceId: brokerageInvoiceId,
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
        deleteBrokerageInvoice(
          projectId: projectId,
          brokerageInvoiceId: brokerageInvoiceId,
          bookingId: bookingId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> pullPaidBrokerageBooking({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPaidCrmBrokerageBookingUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required int bookingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Brokerage/PullPaidBrokerageBooking?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&BookingId=$bookingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      final networkResponse = await baseClient.getRequestWithAuthentication(
        pullPaidCrmBrokerageBookingUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          bookingId: bookingId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<PaidBrokerageBookingModel>.from(
          (networkResponse['data'] as List<dynamic>).map(
            (e) => PaidBrokerageBookingModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        pullPaidBrokerageBooking(
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
  Future<Map<String, dynamic>> addUpdatePaidBrokerageBooking({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdatePaidCrmBrokerageBookingURL =
        "Brokerage/AddUpdatePaidBrokerageBooking";

    try {
      final networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdatePaidCrmBrokerageBookingURL,
            fileList,
            body,
          );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        addUpdatePaidBrokerageBooking(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> deletePaidBrokerageBooking({
    required int projectId,
    required int bookingId,
    required int paidBrokerageBookingId,
    required String uniqueKey,
    required int brokerageInvoiceId,
  }) async {
    String deletePaidCrmBrokerageBookingUrl({
      required int projectId,
      required int paidBrokerageBookingId,
      required String uniqueKey,
      required int brokerageInvoiceId,
      required int bookingId,
    }) {
      return "Brokerage/DeletePaidBrokerageBooking?PaidBrokerageBookingId=$paidBrokerageBookingId&Uniquekey=$uniqueKey&ProjectId=$projectId&BookingId=$bookingId&BrokerageInvoiceId=$brokerageInvoiceId";
    }

    try {
      final networkResponse = await baseClient.deleteRequestWithAuthentication(
        deletePaidCrmBrokerageBookingUrl(
          projectId: projectId,
          paidBrokerageBookingId: paidBrokerageBookingId,
          uniqueKey: uniqueKey,
          brokerageInvoiceId: brokerageInvoiceId,
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
        deletePaidBrokerageBooking(
          projectId: projectId,
          paidBrokerageBookingId: paidBrokerageBookingId,
          uniqueKey: uniqueKey,
          brokerageInvoiceId: brokerageInvoiceId,
          bookingId: bookingId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullBrokerageBookingForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullBrokerageBookingUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Brokerage/PullBrokerageBooking?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      final networkResponse = await baseClient.getRequestWithAuthentication(
        pullBrokerageBookingUrl(
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
        return apicallPullBrokerageBookingForExport(
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
  Future<Map<String, dynamic>> apicallPullBrokerageInvoiceForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullBrokerageInvoiceUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required int bookingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Brokerage/PullBrokerageInvoice?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&BookingId=$bookingId";

      url += queryParamsFormatter(queryParams: queryParams);

      return url;
    }

    try {
      final networkResponse = await baseClient.getRequestWithAuthentication(
        pullBrokerageInvoiceUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          bookingId: bookingId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullBrokerageInvoiceForExport(
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
  Future<Map<String, dynamic>> pullPaidBrokerageBookingForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPaidBrokerageBookingUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required int bookingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Brokerage/PullPaidBrokerageBooking?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&BookingId=$bookingId";

      url += queryParamsFormatter(queryParams: queryParams);

      return url;
    }

    try {
      final networkResponse = await baseClient.getRequestWithAuthentication(
        pullPaidBrokerageBookingUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          bookingId: bookingId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return pullPaidBrokerageBookingForExport(
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
}
