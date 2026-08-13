import 'package:k3h_erp_app/features/legal/dashboard/data/model/litigation_dashboard.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class LitigationDashboardDatasource {
  Future<Map<String, dynamic>> apiCallPullLitigationDashboard({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class LitigationDashboardDatasourceImpl
    implements LitigationDashboardDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullLitigationDashboard({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullLitigationDashboardUrl({Map<String, dynamic>? queryParams}) {
      String url =
          "LitigationDashboard/PullLitigationDashboard?ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullLitigationDashboardUrl(queryParams: queryParams),
      );
      final rawData = networkResponse["data"] ?? networkResponse["Data"];

      if (rawData == null) {
        return {'data': null, 'totalNumberOfRecord': 0};
      }
      final LitigationDashboardModel model = LitigationDashboardModel.fromJson(
        rawData,
      );

      return {
        'data': model,
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullLitigationDashboard(
          queryParams: queryParams,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }
}
