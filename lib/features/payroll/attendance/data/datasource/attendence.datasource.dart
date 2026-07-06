import 'package:k3h_erp_app/features/payroll/attendance/data/model/attendance.model.dart';
import 'package:k3h_erp_app/features/payroll/attendance/data/model/attendance_regularization.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class AttendanceDataSource {
  Future<Map<String, dynamic>> apicallPullAttendance({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallPullAttendanceRegulariation({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallAddUpdateAttendanceRegularization({
    required Map<String, dynamic> queryParams,
  });
}

class AttendanceDataSourceImpl implements AttendanceDataSource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullAttendance({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullAttendanceUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Attendance/PullAttendance?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullAttendanceUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<AttendanceModel>.from(
          networkResponse["data"].map((e) => AttendanceModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullAttendance(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullAttendanceRegulariation({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullAttendanceRegularizeUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "AttendanceRegularization/PullAttendanceRegularization?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullAttendanceRegularizeUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<AttendanceRegularizationModel>.from(
          networkResponse["data"].map(
            (e) => AttendanceRegularizationModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullAttendance(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateAttendanceRegularization({
    required Map<String, dynamic> queryParams,
  }) async {
    try {
      @override
      String addAttendanceRegularizeUrl =
          'AttendanceRegularization/AddUpdateAttendanceRegularization';
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addAttendanceRegularizeUrl,
        queryParams,
      );
      return {
        'data': List<AttendanceModel>.from(
          networkResponse["data"].map((e) => AttendanceModel.fromJson(e)),
        ),
        // 'warningMessage': networkResponse['warningMessage'],
        'totalNumberOfRecord': networkResponse["totalNumberOfRecord"],
      };
    } catch (e) {
      rethrow;
    }
  }
}
