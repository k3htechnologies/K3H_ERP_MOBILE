import 'package:k3h_erp_app/features/business_development/dashboard/data/model/redevelopment_dashboard.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class RedevelopmentDashboradDatasource {
  Future<Map<String, dynamic>> apiCallPullRedevelopmentDashboard({
    required int projectId,
    int? buildingId,
    Map<String, dynamic>? queryParams,
  });
}

class RedevelopmentDashboradDatasourceImpl
    extends RedevelopmentDashboradDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullRedevelopmentDashboard({
    required int projectId,
    int? buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullRedevelopmentDashboardUrl({Map<String, dynamic>? queryParams}) {
      String url =
          "RedevelopmentDashboard/PullRedevelopmentDashboard?ProjectId=$projectId&BuildingId=$buildingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullRedevelopmentDashboardUrl(queryParams: queryParams),
      );
      final rawData = networkResponse["data"] ?? networkResponse["Data"];

      if (rawData == null) {
        return {'data': null, 'totalNumberOfRecord': 0};
      }
      final RedevelopmentDashboardModel model =
          RedevelopmentDashboardModel.fromJson(rawData);

      return {
        'data': model,
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullRedevelopmentDashboard(
          queryParams: queryParams,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }
}
