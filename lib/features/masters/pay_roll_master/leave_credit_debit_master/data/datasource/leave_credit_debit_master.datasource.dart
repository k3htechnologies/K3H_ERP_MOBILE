import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_debit_master/data/model/leave_credit_debit_master.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class LeaveCreditDebitMasterDatasource {
  Future<Map<String, dynamic>> apicallPullLeaveCreditDebitMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateLeaveCreditDebitMaster({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteLeaveCreditDebitMaster({
    required int leaveCreditConfigurationId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallPullLeaveCreditDebitMasterExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class LeaveCreditDebitMasterDatasourceImpl
    extends LeaveCreditDebitMasterDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullLeaveCreditDebitMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullLeaveCreditDebitUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "LeaveCreditConfiguration/PullLeaveCreditConfiguration?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullLeaveCreditDebitUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<LeaveCreditDebitMasterModel>.from(
          networkResponse["data"].map(
            (e) => LeaveCreditDebitMasterModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullLeaveCreditDebitMaster(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateLeaveCreditDebitMaster({
    required Map<String, dynamic> body,
  }) async {
    try {
      String addUpdateLeaveCreditDebitMasterUrl =
          "LeaveCreditConfiguration/AddUpdateLeaveCreditConfiguration";

      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateLeaveCreditDebitMasterUrl,
        body,
      );
      return {
        'data': List<LeaveCreditDebitMasterModel>.from(
          networkResponse["data"].map(
            (e) => LeaveCreditDebitMasterModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddUpdateLeaveCreditDebitMaster(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteLeaveCreditDebitMaster({
    required int leaveCreditConfigurationId,
    required String uniqueKey,
  }) async {
    String deleteLeaveCreditDebitUrl({
      required int leaveCreditConfigurationId,
      required String uniqueKey,
    }) {
      return "LeaveCreditConfiguration/DeleteLeaveCreditConfiguration?LeaveCreditConfigurationId=$leaveCreditConfigurationId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteLeaveCreditDebitUrl(
          leaveCreditConfigurationId: leaveCreditConfigurationId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['TotalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallDeleteLeaveCreditDebitMaster(
          leaveCreditConfigurationId: leaveCreditConfigurationId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullLeaveCreditDebitMasterExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullLeaveCreditDebitExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "LeaveCreditConfiguration/PullLeaveCreditConfiguration?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullLeaveCreditDebitExportUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullLeaveCreditDebitMasterExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
