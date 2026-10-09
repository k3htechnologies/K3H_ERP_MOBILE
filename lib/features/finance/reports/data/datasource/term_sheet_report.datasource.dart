import 'package:k3h_erp_app/features/finance/reports/data/model/term_sheet_report.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class TermSheetReportDatasource {
  Future<Map<String, dynamic>> apiCallPullTermSheetReport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallPullTermSheetReportForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class TermSheetReportDatasourceImpl implements TermSheetReportDatasource {
  final BaseClient baseClient = BaseClient();
  @override
  Future<Map<String, dynamic>> apiCallPullTermSheetReport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullTermSheetReportUrl({Map<String, dynamic>? queryParams}) {
      String url =
          "TermSheetReport/PullTermSheetReport?pageNumber=$pageNumber&pageSize=$pageSize";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullTermSheetReportUrl(queryParams: queryParams),
      );
      return {
        'data': List<TermSheetReportModel>.from(
          networkResponse["data"].map((e) => TermSheetReportModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullTermSheetReport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullTermSheetReportForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullTermSheetReportUrl({Map<String, dynamic>? queryParams}) {
      String url =
          "TermSheetReport/PullTermSheetReport?pageNumber=$pageNumber&pageSize=$pageSize";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullTermSheetReportUrl(queryParams: queryParams),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullTermSheetReportForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
