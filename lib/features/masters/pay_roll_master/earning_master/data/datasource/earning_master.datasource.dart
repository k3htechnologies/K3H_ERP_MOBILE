import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/data/model/earning_master.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class EarningMasterDatasource {
  Future<Map<String, dynamic>> apiCallPullEarningMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateEarningMaster({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteEarningMaster({
    required int earningMasterId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallPullEarningMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class EarningMasterDatasourceImpl extends EarningMasterDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullEarningMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String getEarningsUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "EarningMaster/PullEarningMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) {
        url += "&$key=$value";
      });
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        getEarningsUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<EarningMasterModel>.from(
          networkResponse["data"].map((e) => EarningMasterModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullEarningMaster(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateEarningMaster({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateEarningUrl = "EarningMaster/AddUpdateEarningMaster";
    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateEarningUrl,
        body,
      );
      return {
        'data': List<EarningMasterModel>.from(
          networkResponse["data"].map((e) => EarningMasterModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateEarningMaster(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteEarningMaster({
    required int earningMasterId,
    required String uniqueKey,
  }) async {
    String deleteEarningUrl(int earningMasterId, String uniqueKey) {
      return "EarningMaster/DeleteEarningMaster?EarningMasterId=$earningMasterId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteEarningUrl(earningMasterId, uniqueKey),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteEarningMaster(
          earningMasterId: earningMasterId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullEarningMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String getEarningsExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "EarningMaster/PullEarningMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) {
        url += "&$key=$value";
      });
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        getEarningsExportUrl(
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
        apicallPullEarningMasterForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
