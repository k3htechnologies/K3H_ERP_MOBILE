import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class RepaymentDatasource {
  Future<Map<String, dynamic>> apicallAddUpdateTermSheetRepayLedger({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apiCallDeleteTermSheetDirectSellingAgent({
    required int termSheetRepayLedgerId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
  });
}

class RepaymentDatasourceImpl extends RepaymentDatasource {
  final BaseClient baseClient = BaseClient();
  @override
  Future<Map<String, dynamic>> apicallAddUpdateTermSheetRepayLedger({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateExtraCarpetAreaUrl =
        "TermSheet/AddUpdateTermSheetRepayLedger";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateExtraCarpetAreaUrl,
        body,
      );
      return {
        'data': List<TermSheetViewModel>.from(
          networkResponse['data'].map((x) => TermSheetViewModel.fromJson(x)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateTermSheetRepayLedger(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallDeleteTermSheetDirectSellingAgent({
    required int termSheetRepayLedgerId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
  }) async {
    String deleteDisbursedAmountUrl({
      required int termSheetRepayLedgerId,
      required int termSheetId,
      required int termSheetDetailsId,
      required int projectId,
    }) {
      return "TermSheet/DeleteTermSheetRepayLedger"
          "?TermSheetId=$termSheetId"
          "&TermSheetDetailsId=$termSheetDetailsId"
          "&TermSheetRepayLedgerId=$termSheetRepayLedgerId"
          "&ProjectId=$projectId";
    }

    try {
      final networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteDisbursedAmountUrl(
          projectId: projectId,
          termSheetId: termSheetId,
          termSheetDetailsId: termSheetDetailsId,
          termSheetRepayLedgerId: termSheetRepayLedgerId,
        ),
      );
      return {
        'data': networkResponse['data'],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallDeleteTermSheetDirectSellingAgent(
          projectId: projectId,
          termSheetId: termSheetId,
          termSheetDetailsId: termSheetDetailsId,
          termSheetRepayLedgerId: termSheetRepayLedgerId,
        );
      }
      rethrow;
    }
  }
}
