import 'package:k3h_erp_app/features/payroll/payroll_report/data/model/payroll_report.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class PayrollReportDatasource {
  Future<Map<String, dynamic>> apicallPullApprovalStatus({
    int? id,
    String? moduleName,
    String? requestId,
  });

  Future<Map<String, dynamic>> apicallAddApproval({
    required Map<String, dynamic> body,
  });
}

class PayrollReportDatasourceImpl implements PayrollReportDatasource {
  final baseClient = BaseClient();

  /// PULL APPROVAL STATUS
  @override
  Future<Map<String, dynamic>> apicallPullApprovalStatus({
    int? id,
    String? moduleName,
    String? requestId,
  }) async {
    String buildUrl() {
      String url = "Approval/PullApprovalStatus?";

      if (id != null) url += "Id=$id&";
      if (moduleName != null) url += "ModuleName=$moduleName&";
      if (requestId != null) url += "RequestId=$requestId&";

      return url;
    }

    try {
      final networkResponse = await baseClient.getRequestWithAuthentication(
        buildUrl(),
      );

      return {
        'data': List<PayrollApprovalModel>.from(
          networkResponse["data"].map((e) => PayrollApprovalModel.fromJson(e)),
        ),
        'message': networkResponse["message"] ?? "",
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullApprovalStatus(
          id: id,
          moduleName: moduleName,
          requestId: requestId,
        );
      }
      rethrow;
    }
  }

  /// ADD APPROVAL
  @override
  Future<Map<String, dynamic>> apicallAddApproval({
    required Map<String, dynamic> body,
  }) async {
    try {
      String url = "Approval/AddApproval";

      final networkResponse = await baseClient.postRequestWithAuthentication(
        url,
        body,
      );

      return {
        'data': networkResponse["data"] ?? {},
        'message': networkResponse["message"] ?? "",
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddApproval(body: body);
      }
      rethrow;
    }
  }
}
