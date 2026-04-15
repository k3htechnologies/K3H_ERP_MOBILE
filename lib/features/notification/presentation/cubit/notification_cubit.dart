import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/notification/data/model/notification.model.dart';
import 'package:k3h_erp_app/features/notification/data/repository/notification.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationState.initial());

  // NOTIFICATION REPO
  final NotificationRepository _notificationRepository =
      serviceLocator<NotificationRepository>();

  // <---- PULL NOTIFICATION ---->
  Future getNotification({
    required BuildContext context,
    required int pageNumber,
    required int pageSize,
    required int projectId,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _notificationRepository.getNotification(
      pageNumber: pageNumber,
      pageSize: pageSize,
      projectId: projectId,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final List<NotificationModel> newData =
            response['data'] as List<NotificationModel>;

        emit(
          state.copyWith(
            notificationList:
                pageNumber == 1
                    ? newData
                    : [...state.notificationList, ...newData],
            totalNumberOfRecord: response['totalNumberOfRecord'],
            currentPage: pageNumber,
            isLoading: false,
          ),
        );
      },
    );
  }

  // <----- READ NOTIFICATION ----->
  Future<void> readNotification({
    required int projectId,
    required String notificationIds,
  }) async {
    emit(state.copyWith());
    Map<String, dynamic> requestBody = {
      "ProjectId": projectId,
      "NotificationId": notificationIds,
    };
    await _notificationRepository.readNotification(payload: requestBody);
  }
}
