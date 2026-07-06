import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/snag_checklist/data/model/snag_checklist.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/snag_checklist/data/repository/snag_checklist.repository.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

part 'snag_checklist_state.dart';

class SnagChecklistCubit extends Cubit<SnagChecklistState> {
  SnagChecklistCubit() : super(SnagChecklistState.inital());

  // REPOSITORY
  final SnagChecklistRepository _snagChecklistRepository =
      serviceLocator<SnagChecklistRepository>();

  Future getSnagCheckList(
    BuildContext context, {
    required int projectId,
    required int bookingId,
    required String categoryName,
  }) async {
    emit(state.copyWith(isLoading: true));

    var result = await _snagChecklistRepository.getBookingLoanDetailsList(
      bookingId: bookingId,
      projectId: projectId,
      categoryName: categoryName,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<SnagChecklistModel> list = List<SnagChecklistModel>.from(
          response['data'] ?? [],
        );
        emit(state.copyWith(snagChecklist: list, isLoading: false));
      },
    );
  }

  Future addUpdateSnagChecklist(
    BuildContext context, {
    required int projectId,
    required int bookingId,
    required List<SnagChecklistModel> snagChecklist,
  }) async {
    emit(state.copyWith(isLoading: true));

    final snagChecklistJson =
        snagChecklist
            .map(
              (e) => {
                "SnagCheckListId": e.snagCheckListId,
                "IsCheck": e.isCheck,
              },
            )
            .toList();

    final body = {
      "ProjectId": projectId,
      "BookingId": bookingId,
      "SnagCheckListJSON": jsonEncode(snagChecklistJson),
    };

    var result = await _snagChecklistRepository.addUpdateBookingLoanDetails(
      body: body,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        emit(state.copyWith(isLoading: false));
        showSuccessMessage(
          context,
          subTitle: response["message"] ?? "Checklist updated successfully",
        );
      },
    );
  }
}
