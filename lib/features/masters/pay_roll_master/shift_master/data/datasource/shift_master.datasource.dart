import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/data/model/shift_master.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class ShiftMasterDataSource {
  Future<Map<String, dynamic>> apiCallPullShift({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallDeleteShift({
    required int shiftId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apiCallAddUpdateShift({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apiCallPullShiftForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class ShiftMasterDataSourceImp extends ShiftMasterDataSource {
  final BaseClient baseClient = BaseClient();

  // GET SHIFT
  @override
  Future<Map<String, dynamic>> apiCallPullShift({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullShiftUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ShiftManagementMaster/PullShiftManagementMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullShiftUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );

      return {
        'data':
            networkResponse['data'].runtimeType == String
                ? networkResponse['data']
                : List<ShiftMasterModel>.from(
                  networkResponse['data'].map(
                    (e) => ShiftMasterModel.fromJson(e),
                  ),
                ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullShift(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  // DELETE SHIFT
  @override
  Future<Map<String, dynamic>> apiCallDeleteShift({
    required int shiftId,
    required String uniqueKey,
  }) async {
    String deleteShiftMasterUrl({
      required int shiftMasterId,
      required String uniqueKey,
    }) {
      return "ShiftManagementMaster/DeleteShiftManagementMaster?ShiftManagementMasterId=$shiftMasterId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteShiftMasterUrl(shiftMasterId: shiftId, uniqueKey: uniqueKey),
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

  // ADD / UPDATE SHIFT
  @override
  Future<Map<String, dynamic>> apiCallAddUpdateShift({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateShiftUrl =
        "ShiftManagementMaster/AddUpdateShiftManagementMaster";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateShiftUrl,
        body,
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateShift(body: body);
      }
      rethrow;
    }
  }

  // EXPORT SHIFT
  @override
  Future<Map<String, dynamic>> apiCallPullShiftForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullShiftExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ShiftManagementMaster/PullShiftManagementMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullShiftExportUrl(
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
        apiCallPullShiftForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
