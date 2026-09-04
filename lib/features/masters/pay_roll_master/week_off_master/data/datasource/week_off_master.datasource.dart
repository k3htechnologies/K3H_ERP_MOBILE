import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/data/model/week_off_master.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class WeekOffMasterDataSource {
  Future<Map<String, dynamic>> apiCallPullWeekOff({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallDeleteWeekOff({
    required int weekOffId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apiCallAddUpdateWeekOff({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apiCallPullWeekOffForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class WeekOffMasterDataSourceImp extends WeekOffMasterDataSource {
  final BaseClient baseClient = BaseClient();

  // GET WEEK OFF
  @override
  Future<Map<String, dynamic>> apiCallPullWeekOff({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullWeekOffUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "WeekOffPolicyMaster/PullWeekOffPolicyMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullWeekOffUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );

      return {
        'data':
            networkResponse['data'].runtimeType == String
                ? networkResponse['data']
                : List<WeekOffMasterModel>.from(
                  networkResponse['data'].map(
                    (e) => WeekOffMasterModel.fromJson(e),
                  ),
                ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullWeekOff(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  // DELETE WEEK OFF
  @override
  Future<Map<String, dynamic>> apiCallDeleteWeekOff({
    required int weekOffId,
    required String uniqueKey,
  }) async {
    String deleteWeekOffMasterUrl({
      required int weekOffMasterId,
      required String uniqueKey,
    }) {
      return "WeekOffPolicyMaster/DeleteWeekOffPolicyMaster?WeekOffPolicyMasterId=$weekOffMasterId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteWeekOffMasterUrl(
          weekOffMasterId: weekOffId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      rethrow;
    }
  }

  // ADD / UPDATE WEEK OFF
  @override
  Future<Map<String, dynamic>> apiCallAddUpdateWeekOff({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateWeekOffUrl =
        "WeekOffPolicyMaster/AddUpdateWeekOffPolicyMaster";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateWeekOffUrl,
        body,
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateWeekOff(body: body);
      }
      rethrow;
    }
  }

  // EXPORT WEEK OFF
  @override
  Future<Map<String, dynamic>> apiCallPullWeekOffForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullWeekOffExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "WeekOffPolicyMaster/PullWeekOffPolicyMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullWeekOffExportUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullWeekOffForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
