import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/data/model/leave_credit_configuration_master.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class LeaveCreditConfigurationMasterDatasource {
  Future<Map<String, dynamic>> apicallPullLeaveCreditConfigurationMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateLeaveCreditConfigurationMaster({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteLeaveCreditConfigurationMaster({
    required int leaveCreditConfigurationId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallPullLeaveCreditConfigurationMasterExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class LeaveCreditConfigurationMasterDatasourceImpl
    extends LeaveCreditConfigurationMasterDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullLeaveCreditConfigurationMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullLeaveCreditConfigurationUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "LeaveCreditConfiguration/PullLeaveCreditConfiguration?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullLeaveCreditConfigurationUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<LeaveCreditConfigurationMasterModel>.from(
          networkResponse["data"].map(
            (e) => LeaveCreditConfigurationMasterModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullLeaveCreditConfigurationMaster(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateLeaveCreditConfigurationMaster({
    required Map<String, dynamic> body,
  }) async {
    try {
      String addUpdateLeaveCreditConfigurationMasterUrl =
          "LeaveCreditConfiguration/AddUpdateLeaveCreditConfiguration";

      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateLeaveCreditConfigurationMasterUrl,
        body,
      );
      return {
        'data': List<LeaveCreditConfigurationMasterModel>.from(
          networkResponse["data"].map(
            (e) => LeaveCreditConfigurationMasterModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddUpdateLeaveCreditConfigurationMaster(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteLeaveCreditConfigurationMaster({
    required int leaveCreditConfigurationId,
    required String uniqueKey,
  }) async {
    String deleteLeaveCreditConfigurationUrl({
      required int leaveCreditConfigurationId,
      required String uniqueKey,
    }) {
      return "LeaveCreditConfiguration/DeleteLeaveCreditConfiguration?LeaveCreditConfigurationId=$leaveCreditConfigurationId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteLeaveCreditConfigurationUrl(
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
        return apicallDeleteLeaveCreditConfigurationMaster(
          leaveCreditConfigurationId: leaveCreditConfigurationId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullLeaveCreditConfigurationMasterExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullLeaveCreditConfigurationExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "LeaveCreditConfiguration/PullLeaveCreditConfiguration?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullLeaveCreditConfigurationExportUrl(
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
        apicallPullLeaveCreditConfigurationMasterExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
