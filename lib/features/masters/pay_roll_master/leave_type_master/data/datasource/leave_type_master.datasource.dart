import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/model/leave_type_master.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class LeaveTypeMasterDataSource {
  Future<Map<String, dynamic>> apiCallPullLeaveType({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallDeleteLeaveType({
    required int leaveTypeId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apiCallAddUpdateLeaveType({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apiCallPullLeaveTypeForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class LeaveTypeMasterDataSourceImp extends LeaveTypeMasterDataSource {
  final BaseClient baseClient = BaseClient();

  // GET LEAVE TYPE
  @override
  Future<Map<String, dynamic>> apiCallPullLeaveType({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullLeaveTypeUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "LeaveTypeMaster/PullLeaveTypeMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullLeaveTypeUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );

      return {
        'data':
            networkResponse['data'].runtimeType == String
                ? networkResponse['data']
                : List<LeaveTypeModel>.from(
                  networkResponse['data'].map(
                    (e) => LeaveTypeModel.fromJson(e),
                  ),
                ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullLeaveType(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  // DELETE LEAVE TYPE
  @override
  Future<Map<String, dynamic>> apiCallDeleteLeaveType({
    required int leaveTypeId,
    required String uniqueKey,
  }) async {
    String deleteLeaveTypeMasterUrl({
      required int leaveTypeMasterId,
      required String uniqueKey,
    }) {
      return "LeaveTypeMaster/DeleteLeaveTypeMaster?LeaveTypeMasterId=$leaveTypeMasterId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteLeaveTypeMasterUrl(
          leaveTypeMasterId: leaveTypeId,
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

  // ADD / UPDATE LEAVE TYPE
  @override
  Future<Map<String, dynamic>> apiCallAddUpdateLeaveType({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateLeaveEncashmentUrl =
        "LeaveTypeMaster/AddUpdateLeaveTypeMaster";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateLeaveEncashmentUrl,
        body,
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateLeaveType(body: body);
      }
      rethrow;
    }
  }

  // EXPORT LEAVE TYPE
  @override
  Future<Map<String, dynamic>> apiCallPullLeaveTypeForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullLeaveTypeExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "LeaveTypeMaster/PullLeaveTypeMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullLeaveTypeExportUrl(
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
        apiCallPullLeaveTypeForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
