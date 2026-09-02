import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/term_sheet.model.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class TermSheetDatasource {
  Future<Map<String, dynamic>> apiCallPullTermSheet({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> addUpdateTermSheet({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apiCallPullTermSheetView({
    required int projectId,
    required int termSheetId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallDeleteTermSheet({
    required int projectId,
    required int termSheetId,
    required int termSheetDetailsId,
  });

  Future<Map<String, dynamic>> apicallFinalizeTermSheetDetails({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apiCallPullTermSheetForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class TermSheetDatasourceImpl extends TermSheetDatasource {
  final BaseClient baseClient = BaseClient();
  @override
  Future<Map<String, dynamic>> apiCallPullTermSheet({
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
          "TermSheet/PullTermSheet?PageSize=$pageSize&PageNumber=$pageNumber";
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
        'data': List<TermSheetModel>.from(
          networkResponse['data'].map((e) => TermSheetModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullTermSheet(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> addUpdateTermSheet({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateBrokerageInvoiceUrl = "TermSheet/AddUpdateTermSheet";

    try {
      final networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateBrokerageInvoiceUrl,
            fileList,
            body,
          );
      return {
        'data': List<TermSheetModel>.from(
          (networkResponse['data'] as List<dynamic>).map(
            (e) => TermSheetModel.fromJson(e),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return addUpdateTermSheet(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullTermSheetView({
    required int projectId,
    required int termSheetId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullTermSheetViewUrl({
      Map<String, dynamic>? queryParams,
      required int projectId,
      required int termSheetId,
    }) {
      String url =
          "TermSheet/PullTermSheetView?ProjectId=$projectId&TermSheetId=$termSheetId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullTermSheetViewUrl(
          projectId: projectId,
          termSheetId: termSheetId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<TermSheetViewModel>.from(
          networkResponse['data'].map((e) => TermSheetViewModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullTermSheetView(
          projectId: projectId,
          termSheetId: termSheetId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallDeleteTermSheet({
    required int projectId,
    required int termSheetId,
    required int termSheetDetailsId,
  }) async {
    String deleteTermSheetUrl({
      required int projectId,
      required int termSheetId,
      required int termSheetDetailsId,
    }) {
      return "TermSheet/DeleteTermSheet"
          "?TermSheetId=$termSheetId"
          "&TermSheetDetailsId=$termSheetDetailsId"
          "&ProjectId=$projectId";
    }

    try {
      final networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteTermSheetUrl(
          projectId: projectId,
          termSheetId: termSheetId,
          termSheetDetailsId: termSheetDetailsId,
        ),
      );
      return {
        'data': networkResponse['data'],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallDeleteTermSheet(
          projectId: projectId,
          termSheetId: termSheetId,
          termSheetDetailsId: termSheetDetailsId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallFinalizeTermSheetDetails({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateExtraCarpetAreaUrl = "TermSheet/FinalizeTermSheetDetails";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateExtraCarpetAreaUrl,
        body,
      );
      return {
        'data': List<TermSheetDetailsView>.from(
          networkResponse['data'].map((x) => TermSheetDetailsView.fromJson(x)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallFinalizeTermSheetDetails(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullTermSheetForExport({
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
          "TermSheet/PullTermSheet?PageSize=$pageSize&PageNumber=$pageNumber";
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
        apiCallPullTermSheetForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
