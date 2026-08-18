import 'package:k3h_erp_app/features/crm/crm_pay_track/snag_checklist/data/model/snag_checklist.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class SnagChecklistDatasource {
  Future<Map<String, dynamic>> apicallPullSnagCheckList({
    required int projectId,
    required int bookingId,
    required String categoryName,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateSnagCheckList({
    required Map<String, dynamic> body,
  });
}

class SnagChecklistDatasourceImpl extends SnagChecklistDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullSnagCheckList({
    required int projectId,
    required int bookingId,
    required String categoryName,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullSnagCheckListUrl({
      Map<String, dynamic>? queryParams,
      required int bookingId,
      required int projectId,
      required String categoryName,
    }) {
      String url =
          "SnagCheckList/PullSnagCheckList?ProjectId=$projectId&BookingId=$bookingId&&CategoryName=$categoryName";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullSnagCheckListUrl(
          bookingId: bookingId,
          projectId: projectId,
          categoryName: categoryName,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<SnagChecklistModel>.from(
          networkResponse["data"].map((e) => SnagChecklistModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullSnagCheckList(
          projectId: projectId,
          bookingId: bookingId,
          categoryName: categoryName,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateSnagCheckList({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateSnagCheckListUrl = "SnagCheckList/AddUpdateSnagCheckList";
    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateSnagCheckListUrl,
        body,
      );
      return {
        'data': List<SnagChecklistModel>.from(
          networkResponse["data"].map((e) => SnagChecklistModel.fromJson(e)),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateSnagCheckList(body: body);
      }
      rethrow;
    }
  }
}
