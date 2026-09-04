import 'package:k3h_erp_app/features/more/events/calendar/data/models/calendar_event.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class CalendarDatasource {
  Future<Map<String, dynamic>> apicallPullEvent({
    required String fromDate,
    required String toDate,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateEvent({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeleteEvent({
    required int eventId,
    required String uniqueKey,
  });
}

class CalendarDatasourceImpl implements CalendarDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullEvent({
    required String fromDate,
    required String toDate,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullEventUrl({
      required String fromDate,
      required String toDate,
      Map<String, dynamic>? queryParams,
    }) {
      String url = "Events/PullEvent?FromDate=$fromDate&ToDate=$toDate";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullEventUrl(
          fromDate: fromDate,
          toDate: toDate,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<CalendarEventModel>.from(
          networkResponse["data"].map((e) => CalendarEventModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullEvent(
          fromDate: fromDate,
          toDate: toDate,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateEvent({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      String addUpdateDepartmentUrl = "Events/AddUpdateEvent";

      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateDepartmentUrl,
            fileList,
            body,
          );
      return {
        'data': List<CalendarEventModel>.from(
          networkResponse["data"].map((e) => CalendarEventModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddUpdateEvent(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteEvent({
    required int eventId,
    required String uniqueKey,
  }) async {
    String deleteEventUrl({required int eventId, required String uniqueKey}) {
      return "Events/DeleteEvent?EventId=$eventId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteEventUrl(eventId: eventId, uniqueKey: uniqueKey),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallDeleteEvent(eventId: eventId, uniqueKey: uniqueKey);
      }
      rethrow;
    }
  }
}
