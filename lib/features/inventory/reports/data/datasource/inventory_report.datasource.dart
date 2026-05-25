import 'package:k3h_erp_app/features/inventory/reports/data/model/inventory_parking_details.model.dart';
import 'package:k3h_erp_app/features/inventory/reports/data/model/inventory_parking_overall_report.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

abstract interface class InventoryReportDatasource {
  Future<Map<String, dynamic>> apicallPullProjectInventoryParkingDetails({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallPullInventoryParkingOverallReport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class InventoryReportDatasourceImpl implements InventoryReportDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullProjectInventoryParkingDetails({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullInventoryUrl({
      required int pageNumber,
      required int pageSize,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "InventoryParkingOverallReport/PullProjectInventoryParkingDetails?PageNumber=$pageNumber&PageSize=$pageSize";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullInventoryUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<InventoryParkingDetailsModel>.from(
          networkResponse["data"].map(
            (e) => InventoryParkingDetailsModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullProjectInventoryParkingDetails(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullInventoryParkingOverallReport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullInventoryUrl({
      required int pageNumber,
      required int pageSize,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "InventoryParkingOverallReport/PullInventoryParkingOverallReport?PageNumber=$pageNumber&PageSize=$pageSize&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullInventoryUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<InventoryParkingOverallReport>.from(
          networkResponse["data"].map(
            (e) => InventoryParkingOverallReport.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullInventoryParkingOverallReport(
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
