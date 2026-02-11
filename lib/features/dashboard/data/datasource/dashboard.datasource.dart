import 'package:k3h_erp_app/features/dashboard/data/model/dashboard.model.dart';
import 'package:k3h_erp_app/features/dashboard/data/model/user_dashboard.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class DashboardDatasource {
  Future<Map<String, dynamic>> apicallPullAttendance({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallAddAttendance({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apiCallPullDashboard({
    Map<String, dynamic>? queryParams,
  });
}

class DashboardDatasourceImpl implements DashboardDatasource {
  final BaseClient baseClient = BaseClient();
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
      queryParams?.forEach((key, value) => url += "&$key=$value");
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
        'data': List<DashboardModel>.from(
          networkResponse["data"].map((e) => DashboardModel.fromJson(e)),
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
  Future<Map<String, dynamic>> apicallAddAttendance({
    required Map<String, dynamic> body,
  }) async {
    String addAttendanceUrl = "Attendance/AddUpdateAttendance";
    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addAttendanceUrl,
        body,
      );
      return {
        'data': List<DashboardModel>.from(
          networkResponse["data"].map((e) => DashboardModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddAttendance(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullDashboard({
    Map<String, dynamic>? queryParams,
  }) async {
    String pullDashboardUrl({Map<String, dynamic>? queryParams}) {
      String url = "Dashboard/PullDashboard";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullDashboardUrl(queryParams: queryParams),
      );
      return {
        'data': List<UserDashboardModel>.from(
          networkResponse["data"].map((e) => UserDashboardModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullDashboard(queryParams: queryParams);
      }
      rethrow;
    }
  }
}
