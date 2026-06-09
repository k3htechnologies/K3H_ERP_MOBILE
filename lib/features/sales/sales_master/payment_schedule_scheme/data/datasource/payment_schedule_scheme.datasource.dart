import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule_scheme/data/model/payment_schedule_scheme.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class PaymentScheduleSchemeDatasource {
  Future<Map<String, dynamic>> apicallPullPaymentScheduleScheme({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallAddUpdatePaymentScheduleScheme({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apicallDeletePaymentScheduleScheme({
    required int paymentScheduleSchemeId,
    required String uniqueKey,
    required int projectId,
  });

  Future<Map<String, dynamic>> apicallPullScheduleSchemeForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class PaymentScheduleSchemeDatasourceImpl
    extends PaymentScheduleSchemeDatasource {
  final BaseClient baseClient = BaseClient();

  // PULL PAYMENT SCHEDULE SCHEME
  @override
  Future<Map<String, dynamic>> apicallPullPaymentScheduleScheme({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPaymentScheduleSchemeUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "PaymentScheduleSchemeMaster/PullPaymentScheduleSchemeMaster?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";

      queryParams?.forEach((key, value) {
        url += "&$key=$value";
      });

      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullPaymentScheduleSchemeUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<PaymentScheduleSchemeModel>.from(
          networkResponse["data"].map(
            (e) => PaymentScheduleSchemeModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return await apicallPullPaymentScheduleScheme(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  // ADD UPDATE PAYMENT SCHEDULE SCHEME
  @override
  Future<Map<String, dynamic>> apicallAddUpdatePaymentScheduleScheme({
    required Map<String, dynamic> body,
  }) async {
    String url =
        "PaymentScheduleSchemeMaster/AddUpdatePaymentScheduleSchemeMaster";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        url,
        body,
      );

      return {
        'data': List<PaymentScheduleSchemeModel>.from(
          networkResponse["data"].map(
            (e) => PaymentScheduleSchemeModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return await apicallAddUpdatePaymentScheduleScheme(body: body);
      }
      rethrow;
    }
  }

  // DELETE PAYMENT SCHEDULE
  @override
  Future<Map<String, dynamic>> apicallDeletePaymentScheduleScheme({
    required int paymentScheduleSchemeId,
    required String uniqueKey,
    required int projectId,
  }) async {
    String deletePaymentScheduleSchemeUrl({
      required int paymentScheduleSchemeId,
      required String uniqueKey,
      required int projectId,
    }) {
      return "PaymentScheduleSchemeMaster/DeletePaymentScheduleSchemeMaster?PaymentScheduleSchemeMasterId=$paymentScheduleSchemeId&Uniquekey=$uniqueKey&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deletePaymentScheduleSchemeUrl(
          paymentScheduleSchemeId: paymentScheduleSchemeId,
          uniqueKey: uniqueKey,
          projectId: projectId,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeletePaymentScheduleScheme(
          paymentScheduleSchemeId: paymentScheduleSchemeId,
          uniqueKey: uniqueKey,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }

  // PULL PAYMENT SCHEDULE SCHEME FOR EXPORT
  @override
  Future<Map<String, dynamic>> apicallPullScheduleSchemeForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullScheduleSchemeExportUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "PaymentScheduleSchemeMaster/PullPaymentScheduleSchemeMaster?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";

      queryParams?.forEach((key, value) {
        url += "&$key=$value";
      });

      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullScheduleSchemeExportUrl(
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
        return await apicallPullScheduleSchemeForExport(
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
