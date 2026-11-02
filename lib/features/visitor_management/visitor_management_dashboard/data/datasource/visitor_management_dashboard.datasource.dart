import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/data/model/visitor_management_dashboard.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class VisitorManagementDashboardDatasource {
  Future<Map<String, dynamic>> apiCallPullGatePassDashboard({
    required String filterType,
    Map<String, dynamic>? queryParams,
  });
}

class VisitorManagementDashboardDatasourceImpl
    extends VisitorManagementDashboardDatasource {
  final BaseClient baseClient = BaseClient();
  @override
  Future<Map<String, dynamic>> apiCallPullGatePassDashboard({
    required String filterType,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullSalesDashboardUrl({Map<String, dynamic>? queryParams}) {
      String url = "GatePassDashboard/PullGatePassDashboard?Type=$filterType";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullSalesDashboardUrl(queryParams: queryParams),
      );
      final rawData = networkResponse["data"] ?? networkResponse["Data"];

      if (rawData == null) {
        return {'data': null, 'totalNumberOfRecord': 0};
      }
      final GatePassDashboardModel model = GatePassDashboardModel.fromJson(
        rawData,
      );

      return {
        'data': model,
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullGatePassDashboard(
          queryParams: queryParams,
          filterType: filterType,
        );
      }
      rethrow;
    }
  }
}
