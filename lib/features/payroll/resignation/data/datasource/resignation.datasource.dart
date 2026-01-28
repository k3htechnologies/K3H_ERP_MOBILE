import 'package:k3h_erp_app/features/payroll/resignation/data/model/resignation.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';

abstract interface class ResignationDatasource {
  Future<Map<String, dynamic>> apicallPullResignation({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateResignation({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallPullResignationForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
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
      queryParams?.forEach((key, value) => url += "&$key=$value");
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
    required Map<String, dynamic> body,
  }) async {
    try {
      @override
      String addResignationUrl = 'Resignation/AddUpdateResignation';
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addResignationUrl,
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
  Future<Map<String, dynamic>> apicallPullResignationForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullResignationForExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Resignation/PullResignationForExport?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullResignationForExportUrl(
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
  Future<Map<String, dynamic>> apicallDeleteResignation({
    required int resignationId,
    required String uniqueKey,
  }) async {
    try {
      String deleteResignationUrl =
          "Resignation/DeleteResignation?LeaveId=$resignationId&UniqueKey=$uniqueKey";

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
