import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/data/model/deduction_master.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class DeductionMasterDatasource {
  Future<Map<String, dynamic>> apicallPullDeductionMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateDeductionMaster({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteDeductionMaster({
    required int deductionMasterId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallPullDeductionMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class DeductionMasterDatasourceImpl extends DeductionMasterDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullDeductionMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullDeductionsUrl({
      required int pageNumber,
      required int pageSize,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "DeductionMaster/PullDeductionMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) {
        url += "&$key=$value";
      });
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullDeductionsUrl(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<DeductionMasterModel>.from(
          networkResponse["data"].map((e) => DeductionMasterModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullDeductionMaster(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateDeductionMaster({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateDeductionUrl = "DeductionMaster/AddUpdateDeductionMaster";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateDeductionUrl,
        body,
      );
      return {
        'data': List<DeductionMasterModel>.from(
          networkResponse["data"].map((e) => DeductionMasterModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateDeductionMaster(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteDeductionMaster({
    required int deductionMasterId,
    required String uniqueKey,
  }) async {
    String deleteDeductionUrl({
      required int deductionMasterId,
      required String uniqueKey,
    }) {
      return "DeductionMaster/DeleteDeductionMaster?DeductionMasterId=$deductionMasterId&UniqueKey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteDeductionUrl(
          deductionMasterId: deductionMasterId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteDeductionMaster(
          deductionMasterId: deductionMasterId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullDeductionMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullDeductionsExportUrl({
      required int pageNumber,
      required int pageSize,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "DeductionMaster/PullDeductionMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) {
        url += "&$key=$value";
      });
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullDeductionsExportUrl(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullDeductionMasterForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
