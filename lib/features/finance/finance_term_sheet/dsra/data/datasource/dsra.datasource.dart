import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class DsraDatasource {
  Future<Map<String, dynamic>>
  apicallAddUpdateTermSheetDebtServiceReserveAccount({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apiCallDeleteTermSheetDebtServiceReserveAccount({
    required int termSheetDebtServiceReserveAccountId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
  });
}

class DsraDatasourceImpl extends DsraDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>>
  apicallAddUpdateTermSheetDebtServiceReserveAccount({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateExtraCarpetAreaUrl =
        "TermSheet/AddUpdateTermSheetDebtServiceReserveAccount";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateExtraCarpetAreaUrl,
        body,
      );
      return {
        'data': List<TermSheetDebtServiceReserveAccountData>.from(
          networkResponse['data'].map(
            (x) => TermSheetDebtServiceReserveAccountData.fromJson(x),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateTermSheetDebtServiceReserveAccount(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallDeleteTermSheetDebtServiceReserveAccount({
    required int termSheetDebtServiceReserveAccountId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
  }) async {
    String deleteDisbursedAmountUrl({
      required int termSheetDebtServiceReserveAccountId,
      required int termSheetId,
      required int termSheetDetailsId,
      required int projectId,
    }) {
      return "TermSheet/DeleteTermSheetDebtServiceReserveAccount"
          "?TermSheetId=$termSheetId"
          "&TermSheetDetailsId=$termSheetDetailsId"
          "&TermSheetDebtServiceReserveAccountId=$termSheetDebtServiceReserveAccountId"
          "&ProjectId=$projectId";
    }

    try {
      final networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteDisbursedAmountUrl(
          projectId: projectId,
          termSheetId: termSheetId,
          termSheetDetailsId: termSheetDetailsId,
          termSheetDebtServiceReserveAccountId:
              termSheetDebtServiceReserveAccountId,
        ),
      );
      return {
        'data': networkResponse['data'],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallDeleteTermSheetDebtServiceReserveAccount(
          projectId: projectId,
          termSheetId: termSheetId,
          termSheetDetailsId: termSheetDetailsId,
          termSheetDebtServiceReserveAccountId:
              termSheetDebtServiceReserveAccountId,
        );
      }
      rethrow;
    }
  }
}
