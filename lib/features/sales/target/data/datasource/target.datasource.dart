import 'package:k3h_erp_app/features/sales/target/data/model/sales_target_closing.model.dart';
import 'package:k3h_erp_app/features/sales/target/data/model/sales_target_sourcing.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class TargetDatasource {
  Future<Map<String, dynamic>> apicallPullSaleTargetClosing({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallPullSaleTargetSourcing({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullSaleTargetSourcingExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullSaleTargetClosingExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class TargetDatasourceImpl extends TargetDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullSaleTargetClosing({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullSaleTargetClosingUrl({Map<String, dynamic>? queryParams}) {
      String url =
          "SaleTarget/PullSaleTargetClosing?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullSaleTargetClosingUrl(queryParams: queryParams),
      );
      return {
        'data': List<SaleTargetClosingModel>.from(
          networkResponse["data"].map(
            (e) => SaleTargetClosingModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullSaleTargetClosing(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullSaleTargetSourcing({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullSaleTargetSourcingUrl({Map<String, dynamic>? queryParams}) {
      String url =
          "SaleTarget/PullSaleTargetSourcing?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullSaleTargetSourcingUrl(queryParams: queryParams),
      );
      return {
        'data': List<SalesTargetSourcingModel>.from(
          networkResponse["data"].map(
            (e) => SalesTargetSourcingModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullSaleTargetSourcing(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullSaleTargetSourcingExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullSaleTargetClosingUrlExport({
      required int pageNumber,
      required int pageSize,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "SaleTarget/PullSaleTargetSourcing?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullSaleTargetClosingUrlExport(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullSaleTargetSourcingExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullSaleTargetClosingExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullSaleTargetClosingUrlExport({
      required int pageNumber,
      required int pageSize,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "SaleTarget/PullSaleTargetClosing?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullSaleTargetClosingUrlExport(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullSaleTargetClosingExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
