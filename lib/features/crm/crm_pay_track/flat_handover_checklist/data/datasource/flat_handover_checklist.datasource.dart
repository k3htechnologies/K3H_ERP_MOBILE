import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover_checklist/data/model/flat_handover_checklist.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class FlatHandoverChecklistDatasource {
  Future<Map<String, dynamic>> apicallPullFlatHandOverCheckList({
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateFlatHandOverCheckList({
    required Map<String, dynamic> body,
  });
}

class FlatHandoverChecklistDatasourceImpl
    extends FlatHandoverChecklistDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullFlatHandOverCheckList({
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullSnagCheckListUrl({
      Map<String, dynamic>? queryParams,
      required int bookingId,
      required int projectId,
    }) {
      String url =
          "FlatHandOverCheckList/PullFlatHandOverCheckList?ProjectId=$projectId&BookingId=$bookingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullSnagCheckListUrl(
          bookingId: bookingId,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<FlatHandoverChecklistModel>.from(
          networkResponse["data"].map(
            (e) => FlatHandoverChecklistModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullFlatHandOverCheckList(
          projectId: projectId,
          bookingId: bookingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateFlatHandOverCheckList({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateFlatHandOverCheckListUrl =
        "FlatHandOverCheckList/AddUpdateFlatHandOverCheckList";
    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateFlatHandOverCheckListUrl,
        body,
      );
      return {
        'data': List<FlatHandoverChecklistModel>.from(
          networkResponse["data"].map(
            (e) => FlatHandoverChecklistModel.fromJson(e),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateFlatHandOverCheckList(body: body);
      }
      rethrow;
    }
  }
}
