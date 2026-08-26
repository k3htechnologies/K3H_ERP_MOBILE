import 'package:k3h_erp_app/features/finance/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class SweepRatioDatasource {
  Future<Map<String, dynamic>> apicallAddUpdateTermSheetSweepRatioDetails({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apiCallDeleteTermSheetSweepRatioDetails({
    required int termSheetSweepRatioDetailsId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
  });
}

class SweepRatioDatasourceImpl extends SweepRatioDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallAddUpdateTermSheetSweepRatioDetails({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateExtraCarpetAreaUrl =
        "TermSheet/AddUpdateTermSheetSweepRatioDetails";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateExtraCarpetAreaUrl,
        body,
      );
      return {
        'data': List<TermSheetSweepRatioDetailsData>.from(
          networkResponse['data'].map(
            (x) => TermSheetSweepRatioDetailsData.fromJson(x),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateTermSheetSweepRatioDetails(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallDeleteTermSheetSweepRatioDetails({
    required int termSheetSweepRatioDetailsId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
  }) async {
    String deleteDisbursedAmountUrl({
      required int termSheetSweepRatioDetailsId,
      required int termSheetId,
      required int termSheetDetailsId,
      required int projectId,
    }) {
      return "TermSheet/DeleteTermSheetSweepRatioDetails"
          "?TermSheetId=$termSheetId"
          "&TermSheetDetailsId=$termSheetDetailsId"
          "&TermSheetSweepRatioDetailsId=$termSheetSweepRatioDetailsId"
          "&ProjectId=$projectId";
    }

    try {
      final networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteDisbursedAmountUrl(
          projectId: projectId,
          termSheetId: termSheetId,
          termSheetDetailsId: termSheetDetailsId,
          termSheetSweepRatioDetailsId: termSheetSweepRatioDetailsId,
        ),
      );
      return {
        'data': networkResponse['data'],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallDeleteTermSheetSweepRatioDetails(
          projectId: projectId,
          termSheetId: termSheetId,
          termSheetDetailsId: termSheetDetailsId,
          termSheetSweepRatioDetailsId: termSheetSweepRatioDetailsId,
        );
      }
      rethrow;
    }
  }
}
