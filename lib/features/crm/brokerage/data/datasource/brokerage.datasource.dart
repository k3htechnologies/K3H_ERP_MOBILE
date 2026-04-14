import 'package:k3h_erp_app/features/crm/brokerage/data/model/brokerage.model.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/brokerage_invoice.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

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

  Future<Map<String, dynamic>> apicallPullBrokerageBookingForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
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
    String pullDepartmentUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Brokerage/PullBrokerageBooking?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullDepartmentUrl(
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
    String pullBrokerageInvoice({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required int bookingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Brokerage/PullBrokerageInvoice?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&BookingId=$bookingId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      final networkResponse = await baseClient.getRequestWithAuthentication(
        pullBrokerageInvoice(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          bookingId: bookingId,
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
        return apicallPullBrokerageInvoice(
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
    String addUpdateBrokerageInvoice = "Brokerage/AddUpdateBrokerageInvoice";

    try {
      final networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateBrokerageInvoice,
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
    String deleteCrmBrokerageInvoice({
      required int projectId,
      required int brokerageInvoiceId,
      required int bookingId,
      required String uniqueKey,
    }) {
      return "Brokerage/DeleteBrokerageInvoice?BrokerageInvoiceId=$brokerageInvoiceId&BookingId=$bookingId&Uniquekey=$uniqueKey&ProjectId=$projectId";
    }

    try {
      final networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteCrmBrokerageInvoice(
          projectId: projectId,
          brokerageInvoiceId: brokerageInvoiceId,
          bookingId: bookingId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
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
    String pullBrokerageBooking({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Brokerage/PullBrokerageBooking?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      final networkResponse = await baseClient.getRequestWithAuthentication(
        pullBrokerageBooking(
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
}
