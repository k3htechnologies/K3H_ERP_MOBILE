import 'package:k3h_erp_app/features/sales/sales_dashboard/data/model/project_wise_sales.dashboard.model.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/data/model/sales.dashboard.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class SalesDashboardDatasource {
  Future<Map<String, dynamic>> apiCallPullSalesDashboard({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallMarkTimeOutEnquiry({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apiCallPullProjectWiseSalesDashboard({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class SalesDashboardDatasourceImpl extends SalesDashboardDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullSalesDashboard({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullSalesDashboardUrl({Map<String, dynamic>? queryParams}) {
      String url = "SalesDashboard/PullSalesDashboard?ProjectId=$projectId";
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
      final SalesDashboardModel model = SalesDashboardModel.fromJson(rawData);

      return {
        'data': model,
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullSalesDashboard(
          queryParams: queryParams,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullProjectWiseSalesDashboard({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectWiseSalesDashboardUrl({
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "SalesDashboard/PullProjectWiseSalesDashboard?ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectWiseSalesDashboardUrl(queryParams: queryParams),
      );

      return {
        'data': ProjectWiseSalesDashboardModel.fromJson(
          networkResponse["data"],
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullProjectWiseSalesDashboard(
          queryParams: queryParams,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallMarkTimeOutEnquiry({
    required Map<String, dynamic> body,
  }) async {
    try {
      String markTimeOutEnquiryUrl = "Enquiry/EnquiryOutTime";

      var networkResponse = await baseClient.postRequestWithAuthentication(
        markTimeOutEnquiryUrl,
        body,
      );
      return {
        'isSuccess': networkResponse["IsSuccess"],
        'message': networkResponse["message"],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallMarkTimeOutEnquiry(body: body);
      }
      rethrow;
    }
  }
}
