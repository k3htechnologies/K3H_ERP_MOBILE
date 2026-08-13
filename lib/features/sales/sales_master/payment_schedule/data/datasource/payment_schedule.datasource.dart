import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule/data/model/payment_schedule.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class PaymentScheduleDatasource {
  Future<Map<String, dynamic>> apicallPullPaymentScheduleMaster({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdatePaymentScheduleMaster({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeletePaymentSchedule({
    required int paymentScheduleId,
    required String uniqueKey,
    required int projectId,
  });

  Future<Map<String, dynamic>> apicallPullPaymentScheduleMasterForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class PaymentScheduleDatasourceImpl extends PaymentScheduleDatasource {
  final BaseClient baseClient = BaseClient();

  // PULL PAYMENT SCHEDULE MASTER

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

      url += queryParamsFormatter(queryParams: queryParams);

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

  // ADD UPDATE PAYMENT SCHEDULE MASTER

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

  // EXPORT PAYMENT SCHEDULE MASTER FOR EXPORT
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

      url += queryParamsFormatter(queryParams: queryParams);

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

  // DELETE PAYMENT SCHEDULE
  @override
  Future<Map<String, dynamic>> apicallDeletePaymentSchedule({
    required int paymentScheduleId,
    required String uniqueKey,
    required int projectId,
  }) async {
    String deletePaymentScheduleUrl({
      required int paymentScheduleId,
      required String uniqueKey,
      required int projectId,
    }) {
      return "PaymentScheduleMaster/DeletePaymentScheduleMaster?PaymentScheduleMasterId=$paymentScheduleId&Uniquekey=$uniqueKey&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deletePaymentScheduleUrl(
          paymentScheduleId: paymentScheduleId,
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
        apicallDeletePaymentSchedule(
          paymentScheduleId: paymentScheduleId,
          uniqueKey: uniqueKey,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }
}
