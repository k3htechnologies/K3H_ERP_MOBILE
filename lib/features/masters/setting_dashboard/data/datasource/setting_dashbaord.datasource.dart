import 'package:k3h_erp_app/features/masters/setting_dashboard/data/model/setting_dashboard.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class SettingDashbaordDatasource {
  Future<Map<String, dynamic>> apiCallPullSettingsDashboard({
    Map<String, dynamic>? queryParams,
  });
}

class SettingDashboardDatasourceImpl implements SettingDashbaordDatasource {
  final BaseClient baseClient = BaseClient();
  @override
  Future<Map<String, dynamic>> apiCallPullSettingsDashboard({
    Map<String, dynamic>? queryParams,
  }) async {
    String pullSalesDashboardUrl({Map<String, dynamic>? queryParams}) {
      String url = "SettingsDashboard/PullSettingsDashboard";
      queryParams?.forEach((key, value) => url += "&$key=$value");
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
      final SettingDashboardModel model = SettingDashboardModel.fromJson(
        rawData,
      );

      return {
        'data': model,
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullSettingsDashboard(queryParams: queryParams);
      }
      rethrow;
    }
  }
}
