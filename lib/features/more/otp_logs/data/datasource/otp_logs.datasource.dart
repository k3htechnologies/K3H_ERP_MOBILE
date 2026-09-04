import 'package:k3h_erp_app/features/more/otp_logs/data/model/otp_logs.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class OtpLogsDatasource {
  Future<Map<String, dynamic>> apicallPullOTPLogs({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallPullOTPLogsForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class OtpLogsDatasourceImpl implements OtpLogsDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullOTPLogs({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullOtpLogsUrl({
      required int pageNumber,
      required int pageSize,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "OTPLogs/PullOTPLogs?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullOtpLogsUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<OtpLogsModel>.from(
          networkResponse["data"].map((e) => OtpLogsModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullOTPLogs(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullOTPLogsForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullOtpLogsExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "OTPLogs/PullOTPLogs?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullOtpLogsExportUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullOTPLogsForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
