import 'package:k3h_erp_app/features/sales/payment_schedule_summary/data/model/cost_sheet.model.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/data/model/payment_schedule_master_report.model.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/data/model/project_inventory_structure.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class PaymentScheduleDataSource {
  Future<Map<String, dynamic>> apicallPullProjectInventoryStructure({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullPaymentScheduleMasterReport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required Map<String, dynamic> queryParams,
  });
  Future<Map<String, dynamic>> apicallPullCostSheetReport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required Map<String, dynamic> queryParams,
  });
}

class PaymentScheduleDataSourceImpl implements PaymentScheduleDataSource {
  final BaseClient _baseClient = BaseClient();

  // ------------------ GET PROJECT INVENTORY ------------------
  @override
  Future<Map<String, dynamic>> apicallPullProjectInventoryStructure({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectInventoryStructureUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Inventory/PullProjectInventoryStructure?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await _baseClient.getRequestWithAuthentication(
        pullProjectInventoryStructureUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<ProjectInventoryStructure>.from(
          networkResponse["data"].map(
            (e) => ProjectInventoryStructure.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullProjectInventoryStructure(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  // ------------------ GET PAYMENT SCHEDULE MASTER REPORT ------------------
  @override
  Future<Map<String, dynamic>> apicallPullPaymentScheduleMasterReport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required Map<String, dynamic> queryParams,
  }) async {
    String pullPaymentScheduleMasterReportUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required Map<String, dynamic> queryParams,
    }) {
      String url =
          "PaymentScheduleMaster/PullPaymentScheduleMasterReport"
          "?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";

      queryParams.forEach((key, value) => url += "&$key=$value");

      return url;
    }

    try {
      var networkResponse = await _baseClient.getRequestWithAuthentication(
        pullPaymentScheduleMasterReportUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<PaymentScheduleMasterReport>.from(
          networkResponse["data"].map(
            (e) => PaymentScheduleMasterReport.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullPaymentScheduleMasterReport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  // ------------------ GET COST SHEET REPORT ------------------
  @override
  Future<Map<String, dynamic>> apicallPullCostSheetReport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required Map<String, dynamic> queryParams,
  }) async {
    String pullCostSheetReportUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required Map<String, dynamic> queryParams,
    }) {
      String url =
          "PaymentScheduleMaster/PullCostSheetReport?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";

      queryParams.forEach((key, value) => url += "&$key=$value");

      return url;
    }

    try {
      var networkResponse = await _baseClient.getRequestWithAuthentication(
        pullCostSheetReportUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<CostSheetReport>.from(
          networkResponse["data"].map((e) => CostSheetReport.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullCostSheetReport(
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
