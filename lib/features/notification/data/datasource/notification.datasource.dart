import 'package:k3h_erp_app/features/notification/data/model/notification.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class NotificationDatasource {
  Future<Map<String, dynamic>> apicallPullNotification({
    required int pageNumber,
    required int pageSize,
    required int projectId,
  });
  Future<Map<String, dynamic>> apicallReadNotification({
    required Map<String, dynamic> payload,
  });
}

class NotificationDatasourceImpl implements NotificationDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullNotification({
    required int pageNumber,
    required int pageSize,
    required int projectId,
  }) async {
    String pullNotificationUrl({
      required int pageNumber,
      required int pageSize,
      required int projectId,
    }) {
      return "Notification/PullNotification?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullNotificationUrl(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
        ),
      );

      return {
        'data': List<NotificationModel>.from(
          networkResponse["data"].map((e) => NotificationModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullNotification(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallReadNotification({
    required Map<String, dynamic> payload,
  }) async {
    String readNotificationUrl = 'Notification/ReadNotification';

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        readNotificationUrl,
        payload,
      );

      return {
        'data': List<NotificationModel>.from(
          networkResponse["data"].map((e) => NotificationModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallReadNotification(payload: payload);
      }
      rethrow;
    }
  }
}
