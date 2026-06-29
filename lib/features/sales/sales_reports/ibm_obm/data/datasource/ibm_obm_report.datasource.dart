import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

import '../model/ibm_obm_report.model.dart';

abstract interface class IbmObmReportDatasource {
  Future<Map<String, dynamic>> apiCallPullIbmObmReport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallPullIbmObmReportForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class IbmObmReportDatasourceImpl implements IbmObmReportDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullIbmObmReport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullIbmObmReportUrl({Map<String, dynamic>? queryParams}) {
      String url =
          "IbmObmReport/PullIbmObmReport"
          "?PageSize=$pageSize"
          "&PageNumber=$pageNumber";

      url += queryParamsFormatter(queryParams: queryParams);

      return url;
    }

    try {
      final networkResponse = await baseClient.getRequestWithAuthentication(
        pullIbmObmReportUrl(queryParams: queryParams),
      );

      return {
        'data': List<IbmObmReportModel>.from(
          (networkResponse["data"] as List).map(
            (e) => IbmObmReportModel.fromJson(e as Map<String, dynamic>),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullIbmObmReport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullIbmObmReportForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullIbmObmReportUrl({Map<String, dynamic>? queryParams}) {
      String url =
          "IbmObmReport/PullIbmObmReport"
          "?PageSize=$pageSize"
          "&PageNumber=$pageNumber";

      url += queryParamsFormatter(queryParams: queryParams);

      return url;
    }

    try {
      final networkResponse = await baseClient.getRequestWithAuthentication(
        pullIbmObmReportUrl(queryParams: queryParams),
      );

      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'] ?? 0,
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullIbmObmReportForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
