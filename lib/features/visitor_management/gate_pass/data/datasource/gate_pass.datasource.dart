import 'package:k3h_erp_app/features/visitor_management/gate_pass/data/model/gate_pass.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class GatePassDatasource {
  Future<Map<String, dynamic>> apiCallPullGatePass({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallAddUpdateGatePass({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallUpdateGatePassOut({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apiCallDeleteGatePass({
    required int externalId,
    required String uniquekey,
  });

  Future<Map<String, dynamic>> apiCallPullGatePassForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class GatePassDatasourceImpl extends GatePassDatasource {
  final BaseClient baseClient = BaseClient();
  @override
  Future<Map<String, dynamic>> apiCallPullGatePass({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullTermSheetUrl({
      Map<String, dynamic>? queryParams,
      required int pageSize,
      required int pageNumber,
    }) {
      String url =
          "GatePass/PullGatePass?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullTermSheetUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<GatePassModel>.from(
          networkResponse['data'].map((e) => GatePassModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullGatePass(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallAddUpdateGatePass({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateBrokerageInvoiceUrl = "GatePass/AddUpdateGatePass";

    try {
      final networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateBrokerageInvoiceUrl,
            fileList,
            body,
          );
      return {
        'data': List<GatePassModel>.from(
          (networkResponse['data'] as List<dynamic>).map(
            (e) => GatePassModel.fromJson(e),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallAddUpdateGatePass(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallUpdateGatePassOut({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateExtraCarpetAreaUrl = "GatePass/UpdateGatePassOut";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateExtraCarpetAreaUrl,
        body,
      );
      return {
        'data': List<GatePassModel>.from(
          networkResponse['data'].map((x) => GatePassModel.fromJson(x)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallUpdateGatePassOut(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallDeleteGatePass({
    required int externalId,
    required String uniquekey,
  }) async {
    String deleteGatePassUrl({
      required int externalId,
      required String uniquekey,
    }) {
      return "GatePass/DeleteGatePass"
          "?ExternalId=$externalId"
          "&Uniquekey=$uniquekey";
    }

    try {
      final networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteGatePassUrl(externalId: externalId, uniquekey: uniquekey),
      );
      return {
        'data': networkResponse['data'],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallDeleteGatePass(externalId: externalId, uniquekey: uniquekey);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullGatePassForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullTermSheetExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "GatePass/PullGatePass?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullTermSheetExportUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullGatePassForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
