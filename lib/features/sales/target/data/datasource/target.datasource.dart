import 'package:k3h_erp_app/features/sales/target/data/model/target.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class TargetDatasource {
  Future<Map<String, dynamic>> apicallPullTarget({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required DateTime targetMonth,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateTarget({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteTarget({
    required int saleTargetId,
    required String uniqueKey,
    required int projectId,
  });
}

class TargetDatasourceImpl extends TargetDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullTarget({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required DateTime targetMonth,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullTargetUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required String targetMonth,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "SaleTarget/PullSaleTarget?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&TargetMonth=$targetMonth";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullTargetUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          targetMonth: targetMonth.toIso8601String(),
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<TargetModel>.from(
          networkResponse["data"].map((e) => TargetModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullTarget(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          targetMonth: targetMonth,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateTarget({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateSaleTargetUrl = "SaleTarget/AddUpdateSaleTarget";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateSaleTargetUrl,
        body,
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateTarget(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteTarget({
    required int saleTargetId,
    required String uniqueKey,
    required int projectId,
  }) async {
    String deleteTargetUrl({
      required int projectId,
      required int saleTargetId,
      required String uniqueKey,
    }) {
      return "SaleTarget/DeleteSaleTarget?SaleTargetId=$saleTargetId&Uniquekey=$uniqueKey&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteTargetUrl(
          projectId: projectId,
          saleTargetId: saleTargetId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteTarget(
          saleTargetId: saleTargetId,
          uniqueKey: uniqueKey,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }
}
