import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/data/model/leave_encashment_master.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class LeaveEncashmentMasterDataSource {
  Future<Map<String, dynamic>> apiCallPullLeaveEncashment({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallDeleteLeaveEncashment({
    required int leaveEncashmentSlabsId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apiCallAddUpdateLeaveEncashment({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apiCallPullLeaveEncashmentForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class LeaveEncashmentMasterDataSourceImp
    extends LeaveEncashmentMasterDataSource {
  final BaseClient baseClient = BaseClient();

  // GET LEAVE ENCASHMENT
  @override
  Future<Map<String, dynamic>> apiCallPullLeaveEncashment({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullAssetsUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "LeaveEncashmentMasterSlabs/PullLeaveEncashmentMasterSlabs?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullAssetsUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );

      return {
        'data':
            networkResponse['data'].runtimeType == String
                ? networkResponse['data']
                : List<LeaveEncashmentMasterModel>.from(
                  networkResponse['data'].map(
                    (e) => LeaveEncashmentMasterModel.fromJson(e),
                  ),
                ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullLeaveEncashment(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  // DELETE LEAVE ENCASHMENT
  @override
  Future<Map<String, dynamic>> apiCallDeleteLeaveEncashment({
    required int leaveEncashmentSlabsId,
    required String uniqueKey,
  }) async {
    String deleteLeaveEncashmentMasterUrl({
      required int leaveEncashmentSlabsId,
      required String uniqueKey,
    }) {
      return "LeaveEncashmentMasterSlabs/DeleteLeaveEncashmentMasterSlabs?LeaveEncashmentMasterSlabsId=$leaveEncashmentSlabsId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteLeaveEncashmentMasterUrl(
          leaveEncashmentSlabsId: leaveEncashmentSlabsId,
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

  //ADD / UPDATE LEAVE ENCASHMENT
  @override
  Future<Map<String, dynamic>> apiCallAddUpdateLeaveEncashment({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateLeaveEncashmentUrl =
        "LeaveEncashmentMasterSlabs/AddUpdateLeaveEncashmentMasterSlabs";

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
        apiCallAddUpdateLeaveEncashment(body: body);
      }
      rethrow;
    }
  }

  // EXPORT LEAVE ENCASHMENT
  @override
  Future<Map<String, dynamic>> apiCallPullLeaveEncashmentForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullLeaveEncashmentExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "LeaveEncashmentMasterSlabs/PullLeaveEncashmentMasterSlabs?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullLeaveEncashmentExportUrl(
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
        apiCallPullLeaveEncashmentForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
