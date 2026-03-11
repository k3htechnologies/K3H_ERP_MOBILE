import 'package:k3h_erp_app/features/payroll/payroll_dashboard/data/model/payroll_dashboard_model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class PayrollDashboardDatasource {
  Future<Map<String, dynamic>> apiCallPullPayrollDashboard({
    Map<String, dynamic>? queryParams,
  });
}

class PayrollDashboardDatasourceImpl implements PayrollDashboardDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullPayrollDashboard({
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPayrollDashboardUrl({Map<String, dynamic>? queryParams}) {
      String url = "PayrollDashboard/PullPayrollDashboard";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullPayrollDashboardUrl(queryParams: queryParams),
      );
      final rawData = networkResponse["data"] ?? networkResponse["Data"];

      if (rawData == null) {
        return {'data': null, 'totalNumberOfRecord': 0};
      }
      final PayrollDashboardModel model = PayrollDashboardModel.fromJson(
        rawData,
      );

      return {
        'data': model,
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullPayrollDashboard(queryParams: queryParams);
      }
      rethrow;
    }
  }
}
