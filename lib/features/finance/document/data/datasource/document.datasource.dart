import 'package:k3h_erp_app/features/finance/document/data/model/term_sheet_documents.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class DocumentsDatasource {
  Future<Map<String, dynamic>> apiCallPullTermSheetDocument({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallAddUpdateTermSheetDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apiCallDeleteTermSheetDocument({
    required int termSheetDocumentId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
    required String uniquekey,
  });
}

class DocumentsDatasourceImpl extends DocumentsDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullTermSheetDocument({
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
          "TermSheetDocument/PullTermSheetDocument?PageSize=$pageSize&PageNumber=$pageNumber";
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
        'data': List<TermSheetDocumentModel>.from(
          networkResponse['data'].map(
            (e) => TermSheetDocumentModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullTermSheetDocument(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallAddUpdateTermSheetDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateTermSheetDocumentUrl =
        "TermSheetDocument/AddUpdateTermSheetDocument";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateTermSheetDocumentUrl,
            fileList,
            body,
          );
      return {
        'data': List<TermSheetDocumentModel>.from(
          networkResponse["data"].map(
            (e) => TermSheetDocumentModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateTermSheetDocument(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallDeleteTermSheetDocument({
    required int termSheetDocumentId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
    required String uniquekey,
  }) async {
    String deleteDisbursedAmountUrl({
      required int termSheetDocumentId,
      required int termSheetId,
      required int termSheetDetailsId,
      required int projectId,
      required String uniquekey,
    }) {
      return "TermSheetDocument/DeleteTermSheetDocument"
          "?TermSheetId=$termSheetId"
          "&TermSheetDetailsId=$termSheetDetailsId"
          "&TermSheetDocumentId=$termSheetDocumentId"
          "&ProjectId=$projectId"
          "&Uniquekey=$uniquekey";
    }

    try {
      final networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteDisbursedAmountUrl(
          projectId: projectId,
          termSheetId: termSheetId,
          termSheetDetailsId: termSheetDetailsId,
          termSheetDocumentId: termSheetDocumentId,
          uniquekey: uniquekey,
        ),
      );
      return {
        'data': networkResponse['data'],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallDeleteTermSheetDocument(
          projectId: projectId,
          termSheetId: termSheetId,
          termSheetDetailsId: termSheetDetailsId,
          termSheetDocumentId: termSheetDocumentId,
          uniquekey: uniquekey,
        );
      }
      rethrow;
    }
  }
}
