import 'package:k3h_erp_app/features/finance/term_sheet/data/model/term_sheet.model.dart';
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
}
