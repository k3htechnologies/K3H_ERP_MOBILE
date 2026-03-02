import 'package:k3h_erp_app/features/sales/booking/data/model/payment_schedule_master.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class PaymentScheduleMasterDatasource {
  Future<Map<String, dynamic>> apicallPullPaymentScheduleMaster({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdatePaymentScheduleMaster({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallPullPaymentScheduleMasterForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class PaymentScheduleMasterDatasourceImpl
    extends PaymentScheduleMasterDatasource {
  final BaseClient baseClient = BaseClient();

  // ----------------------------------------------------------
  // Pull Payment Schedule Master
  // ----------------------------------------------------------

  @override
  Future<Map<String, dynamic>> apicallPullPaymentScheduleMaster({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPaymentScheduleMasterUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "PaymentScheduleMaster/PullPaymentScheduleMaster?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";

      queryParams?.forEach((key, value) {
        url += "&$key=$value";
      });

      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullPaymentScheduleMasterUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<PaymentScheduleMasterModel>.from(
          networkResponse["data"].map(
            (e) => PaymentScheduleMasterModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        // Retry on token expiry
        return await apicallPullPaymentScheduleMaster(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  // ----------------------------------------------------------
  // Add / Update Payment Schedule Master
  // ----------------------------------------------------------

  @override
  Future<Map<String, dynamic>> apicallAddUpdatePaymentScheduleMaster({
    required Map<String, dynamic> body,
  }) async {
    String url = "PaymentScheduleMaster/AddUpdatePaymentScheduleMaster";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        url,
        body,
      );

      return {
        'data': List<PaymentScheduleMasterModel>.from(
          networkResponse["data"].map(
            (e) => PaymentScheduleMasterModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return await apicallAddUpdatePaymentScheduleMaster(body: body);
      }
      rethrow;
    }
  }

  // ----------------------------------------------------------
  // Pull Payment Schedule Master For Export
  // ----------------------------------------------------------

  @override
  Future<Map<String, dynamic>> apicallPullPaymentScheduleMasterForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPaymentScheduleMasterExportUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "PaymentScheduleMaster/PullPaymentScheduleMaster?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";

      queryParams?.forEach((key, value) {
        url += "&$key=$value";
      });

      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullPaymentScheduleMasterExportUrl(
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
        return await apicallPullPaymentScheduleMasterForExport(
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
