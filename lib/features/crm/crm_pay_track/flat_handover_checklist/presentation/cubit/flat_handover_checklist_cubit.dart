import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover_checklist/data/model/flat_handover_checklist.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover_checklist/data/repository/flat_handover_checklist.repository.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

part 'flat_handover_checklist_state.dart';

class FlatHandoverChecklistCubit extends Cubit<FlatHandoverChecklistState> {
  FlatHandoverChecklistCubit() : super(FlatHandoverChecklistState.initial());

  // REPOSITORY
  final FlatHandoverChecklistRepository _flatHandoverChecklistRepository =
      serviceLocator<FlatHandoverChecklistRepository>();

  Future getFlatHandoverCheckList(
    BuildContext context, {
    required int projectId,
    required int bookingId,
  }) async {
    emit(state.copyWith(isLoading: true));

    var result = await _flatHandoverChecklistRepository
        .getBookingLoanDetailsList(bookingId: bookingId, projectId: projectId);

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<FlatHandoverChecklistModel> list =
            List<FlatHandoverChecklistModel>.from(response['data'] ?? []);
        emit(state.copyWith(flatHandoverCheckList: list, isLoading: false));
      },
    );
  }

  Future<void> addUpdateFlatHandoverChecklist(
    BuildContext context, {
    required int projectId,
    required int bookingId,
    required List<FlatHandoverChecklistModel> checklist,
  }) async {
    emit(state.copyWith(isLoading: true));

    final flatHandoverChecklistJson =
        checklist
            .map(
              (e) => {
                "FlatHandOverCheckListId": e.flatHandOverCheckListId,
                "Status": e.status,
                "Remark": e.remark,
              },
            )
            .toList();

    final body = {
      "ProjectId": projectId,
      "BookingId": bookingId,
      "FlatHandOverCheckListJSON": jsonEncode(flatHandoverChecklistJson),
    };

    var result = await _flatHandoverChecklistRepository
        .addUpdateBookingLoanDetails(body: body);

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));

        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        emit(state.copyWith(isLoading: false));

        showSuccessMessage(
          context,
          subTitle:
              response["message"] ??
              "Flat handover checklist updated successfully",
        );

        await getFlatHandoverCheckList(
          context,
          projectId: projectId,
          bookingId: bookingId,
        );
      },
    );
  }
}
