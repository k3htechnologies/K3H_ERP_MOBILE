import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/notification/data/datasource/notification.datasource.dart';

abstract interface class NotificationRepository {
  Future<Either<Failure, Map<String, dynamic>>> getNotification({
    required int pageNumber,
    required int pageSize,
    required int projectId,
  });

  Future<Either<Failure, Map<String, dynamic>>> readNotification({
    required Map<String, dynamic> payload,
  });
}

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDatasource notificationDatasource;

  NotificationRepositoryImpl({required this.notificationDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getNotification({
    required int pageNumber,
    required int pageSize,
    required int projectId,
  }) async {
    try {
      var result = await notificationDatasource.apicallPullNotification(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> readNotification({
    required Map<String, dynamic> payload,
  }) async {
    try {
      var result = await notificationDatasource.apicallReadNotification(
        payload: payload,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
