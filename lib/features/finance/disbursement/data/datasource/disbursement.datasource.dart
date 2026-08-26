import 'package:k3h_erp_app/features/finance/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class DisbursementDatasource {
  Future<Map<String, dynamic>> apicallAddUpdateTermSheetDisbursedAmountDetails({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apiCallDeleteTermSheetDisbursedAmountDetails({
    required int termSheetDisbursedAmountDetailsId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
  });
}

class DisbursementDatasourceImpl extends DisbursementDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallAddUpdateTermSheetDisbursedAmountDetails({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateExtraCarpetAreaUrl =
        "TermSheet/AddUpdateTermSheetDisbursedAmountDetails";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateExtraCarpetAreaUrl,
        body,
      );
      return {
        'data': List<TermSheetDisbursedAmountDetailsData>.from(
          networkResponse['data'].map(
            (x) => TermSheetDisbursedAmountDetailsData.fromJson(x),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateTermSheetDisbursedAmountDetails(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallDeleteTermSheetDisbursedAmountDetails({
    required int termSheetDisbursedAmountDetailsId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
  }) async {
    String deleteDisbursedAmountUrl({
      required int termSheetDisbursedAmountDetailsId,
      required int termSheetId,
      required int termSheetDetailsId,
      required int projectId,
    }) {
      return "TermSheet/DeleteTermSheetDisbursedAmountDetails"
          "?TermSheetId=$termSheetId"
          "&TermSheetDetailsId=$termSheetDetailsId"
          "&TermSheetDisbursedAmountDetailsId=$termSheetDisbursedAmountDetailsId"
          "&ProjectId=$projectId";
    }

    try {
      final networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteDisbursedAmountUrl(
          projectId: projectId,
          termSheetId: termSheetId,
          termSheetDetailsId: termSheetDetailsId,
          termSheetDisbursedAmountDetailsId: termSheetDisbursedAmountDetailsId,
        ),
      );
      return {
        'data': networkResponse['data'],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallDeleteTermSheetDisbursedAmountDetails(
          projectId: projectId,
          termSheetId: termSheetId,
          termSheetDetailsId: termSheetDetailsId,
          termSheetDisbursedAmountDetailsId: termSheetDisbursedAmountDetailsId,
        );
      }
      rethrow;
    }
  }
}
