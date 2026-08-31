import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class DSADatasource {
  Future<Map<String, dynamic>> apicallAddUpdateTermSheetDirectSellingAgent({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apiCallDeleteTermSheetDirectSellingAgent({
    required int termSheetDirectSellingAgentId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
  });
}

class DSADatasourceImpl extends DSADatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallAddUpdateTermSheetDirectSellingAgent({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateExtraCarpetAreaUrl =
        "TermSheet/AddUpdateTermSheetDirectSellingAgent";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateExtraCarpetAreaUrl,
        body,
      );
      return {
        'data': List<TermSheetDirectSellingAgentData>.from(
          networkResponse['data'].map(
            (x) => TermSheetDirectSellingAgentData.fromJson(x),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateTermSheetDirectSellingAgent(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallDeleteTermSheetDirectSellingAgent({
    required int termSheetDirectSellingAgentId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
  }) async {
    String deleteDisbursedAmountUrl({
      required int termSheetDirectSellingAgentId,
      required int termSheetId,
      required int termSheetDetailsId,
      required int projectId,
    }) {
      return "TermSheet/DeleteTermSheetDirectSellingAgent"
          "?TermSheetId=$termSheetId"
          "&TermSheetDetailsId=$termSheetDetailsId"
          "&TermSheetDirectSellingAgentId=$termSheetDirectSellingAgentId"
          "&ProjectId=$projectId";
    }

    try {
      final networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteDisbursedAmountUrl(
          projectId: projectId,
          termSheetId: termSheetId,
          termSheetDetailsId: termSheetDetailsId,
          termSheetDirectSellingAgentId: termSheetDirectSellingAgentId,
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
          termSheetDirectSellingAgentId: termSheetDirectSellingAgentId,
        );
      }
      rethrow;
    }
  }
}
