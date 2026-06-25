import 'package:k3h_erp_app/features/payroll/leave/model/leave.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

abstract interface class LeaveDatasource {
  Future<Map<String, dynamic>> apicallPullLeave({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateLeave({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeleteLeave({
    required int leaveId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallPullLeaveForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullLeaveConfigurated({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class LeaveDatasourceDataSourceImpl implements LeaveDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullLeave({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullLeaveUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url = "Leave/PullLeave?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullLeaveUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<LeaveModel>.from(
          networkResponse["data"].map((e) => LeaveModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullLeave(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateLeave({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      String addUpdateLeaveUrl = "Leave/AddUpdateLeave";

      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateLeaveUrl,
            fileList,
            body,
          );
      return {
        'data': List<LeaveModel>.from(
          networkResponse["data"].map((e) => LeaveModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddUpdateLeave(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteLeave({
    required int leaveId,
    required String uniqueKey,
  }) async {
    String deleteLeaveUrl({required int leaveId, required String uniqueKey}) {
      return "Leave/DeleteLeave?LeaveId=$leaveId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteLeaveUrl(leaveId: leaveId, uniqueKey: uniqueKey),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['TotalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallDeleteLeave(leaveId: leaveId, uniqueKey: uniqueKey);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullLeaveForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullLeaveExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url = "Leave/PullLeave?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);

      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullLeaveExportUrl(
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
        apicallPullLeaveForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  //  API CALL IS FOR PULLING THE CONFIGURED LEAVE TYPES TO SHOW IN THE LEAVE APPLICATION FORM
  @override
  Future<Map<String, dynamic>> apicallPullLeaveConfigurated({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullLeaveConfiguredUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Leave/PullLeaveConfigured?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);

      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullLeaveConfiguredUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      List<Map<String, dynamic>> leaveConfigs = List<Map<String, dynamic>>.from(
        networkResponse['data'] ?? [],
      );

      return {
        'data': leaveConfigs,
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullLeaveConfigurated(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
