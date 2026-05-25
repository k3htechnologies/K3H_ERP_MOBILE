import 'package:k3h_erp_app/features/crm/dashboard/data/model/crm_dashboard.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class CrmDashboardDatasource {
  Future<Map<String, dynamic>> apiCallPullDashboard({
    Map<String, dynamic>? queryParams,
  });
}

class CrmDashboardDatasourceImpl implements CrmDashboardDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullDashboard({
    Map<String, dynamic>? queryParams,
  }) async {
    String pullDashboardUrl({Map<String, dynamic>? queryParams}) {
      String url = "CrmDashboard/CrmPullDashboard";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullDashboardUrl(queryParams: queryParams),
      );
      final rawData = networkResponse["data"] ?? networkResponse["Data"];

      if (rawData == null) {
        return {'data': null, 'totalNumberOfRecord': 0};
      }
      final CrmDashboardModel model = CrmDashboardModel.fromJson(rawData);

      return {
        'data': model,
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullDashboard(queryParams: queryParams);
      }
      rethrow;
    }
  }
}
