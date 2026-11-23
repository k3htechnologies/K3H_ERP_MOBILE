import 'package:k3h_erp_app/features/crm/crm_report/client_loan_report/data/model/client_loan_report.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class ClientLoanReportDatasource {
  Future<Map<String, dynamic>> apiCallPullProjectWiseClientLoanReport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallPullClientLoanReportForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class ClientLoanReportDatasourceImpl extends ClientLoanReportDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullProjectWiseClientLoanReport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectWiseClientLoanReportURL({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ClientLoanReport/PullProjectWiseClientLoanReport?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectWiseClientLoanReportURL(
          queryParams: queryParams,
          pageSize: pageSize,
          pageNumber: pageNumber,
        ),
      );

      return {
        'data': List<ClientLoanReportModel>.from(
          networkResponse["data"].map((e) => ClientLoanReportModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullProjectWiseClientLoanReport(
          queryParams: queryParams,
          pageNumber: pageNumber,
          pageSize: pageSize,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullClientLoanReportForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullTermSheetExportUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ClientLoanReport/PullProjectWiseClientLoanReport?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullTermSheetExportUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullClientLoanReportForExport(
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
