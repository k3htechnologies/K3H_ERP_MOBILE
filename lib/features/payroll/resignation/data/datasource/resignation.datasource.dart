import 'package:k3h_erp_app/features/payroll/resignation/data/model/resignation.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class ResignationDatasource {
  Future<Map<String, dynamic>> apicallPullResignation({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateResignation({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeleteResignation({
    required int resignationId,
    required String uniqueKey,
  });
}

class ResignationDatasourceImpl implements ResignationDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullResignation({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullResignationUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "EmployeeResignation/PullEmployeeResignation?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);

      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullResignationUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<ResignationModel>.from(
          networkResponse["data"].map((e) => ResignationModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse["totalNumberOfRecord"],
      };
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateResignation({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      @override
      String addResignationUrl =
          'EmployeeResignation/AddUpdateEmployeeResignation';
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addResignationUrl,
            fileList,
            body,
          );
      return {
        'data': List<ResignationModel>.from(
          networkResponse["data"].map((e) => ResignationModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse["totalNumberOfRecord"],
      };
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteResignation({
    required int resignationId,
    required String uniqueKey,
  }) async {
    try {
      String deleteResignationUrl =
          "EmployeeResignation/DeleteEmployeeResignation?EmployeeResignationId=$resignationId&UniqueKey=$uniqueKey";

      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteResignationUrl,
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse["totalNumberOfRecord"],
      };
    } catch (e) {
      rethrow;
    }
  }
}
