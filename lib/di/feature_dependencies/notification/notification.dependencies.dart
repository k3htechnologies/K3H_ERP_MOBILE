import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/notification/data/datasource/notification.datasource.dart';
import 'package:k3h_erp_app/features/notification/data/repository/notification.repository.dart';
import 'package:k3h_erp_app/features/notification/presentation/cubit/notification_cubit.dart';

void registerNotificationDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<NotificationDatasource>(
    NotificationDatasourceImpl(),
  );
  serviceLocator.registerSingleton<NotificationRepository>(
    NotificationRepositoryImpl(
      notificationDatasource: serviceLocator<NotificationDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<NotificationCubit>(NotificationCubit());
}
