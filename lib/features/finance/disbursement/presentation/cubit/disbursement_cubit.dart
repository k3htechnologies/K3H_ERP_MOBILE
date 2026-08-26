import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/finance/disbursement/data/repository/disbursement.repository.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/repository/term_sheet.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

part 'disbursement_state.dart';

class DisbursementCubit extends Cubit<DisbursementState> {
  DisbursementCubit() : super(DisbursementState.inital());

  // REPOSITORIES
  final DisbursementRepository _disbursementRepository =
      serviceLocator<DisbursementRepository>();

  final TermSheetRepository _termSheetRepository =
      serviceLocator<TermSheetRepository>();

  Future<void> getTermSheetView(
    BuildContext context,
    int projectId,
    int termSheetId,
  ) async {
    emit(state.copywith(isLoading: true));

    final Map<String, dynamic> queryParams = {};

    final result = await _termSheetRepository.getTermSheetView(
      projectId: projectId,
      termSheetId: termSheetId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copywith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final List<TermSheetViewModel> newList =
            response['data'] as List<TermSheetViewModel>;

        emit(
          state.copywith(
            termSheetViewList: newList,
            termSheetDetailsViewModel:
                newList.isNotEmpty &&
                        newList.first.termSheetDetailsData.isNotEmpty
                    ? newList.first.termSheetDetailsData.first
                    : null,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            isLoading: false,
          ),
        );
      },
    );
  }

  Future addDisbursement({
    required BuildContext context,
    required double disbursedAmount,
    required DateTime disbursedDate,
    required int projectId,
    required String remark,
    required int termSheetDetailsId,
    required int termSheetId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "DisbursedAmount": disbursedAmount,
      "DisbursedDate": disbursedDate.apiDate,
      "ProjectId": projectId,
      "Remark": remark,
      "TermSheetDetailsId": termSheetDetailsId,
      "TermSheetDisbursedAmountDetailsId": 0,
      "TermSheetId": termSheetId,
      "Uniquekey": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    };
    var addResult = await _disbursementRepository
        .addUpdateTermSheetDisbursedAmountDetails(body: requestBody);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context, subTitle: response["message"]);
        getTermSheetView(context, projectId, termSheetId);
        if (context.mounted) {
          goRouter.pop();
        }
      },
    );
  }

  Future updateDisbursement({
    required BuildContext context,
    required int termSheetDisbursedAmountDetailsId,
    required String uniquekey,
    required double disbursedAmount,
    required DateTime disbursedDate,
    required int projectId,
    required String remark,
    required int termSheetDetailsId,
    required int termSheetId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "DisbursedAmount": disbursedAmount,
      "DisbursedDate": disbursedDate.apiDate,
      "ProjectId": projectId,
      "Remark": remark,
      "TermSheetDetailsId": termSheetDetailsId,
      "TermSheetDisbursedAmountDetailsId": termSheetDisbursedAmountDetailsId,
      "TermSheetId": termSheetId,
      "Uniquekey": uniquekey,
    };
    var addResult = await _disbursementRepository
        .addUpdateTermSheetDisbursedAmountDetails(body: requestBody);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context, subTitle: response["message"]);
        getTermSheetView(context, projectId, termSheetId);
        if (context.mounted) {
          goRouter.pop();
        }
      },
    );
  }

  Future<void> deleteDisbursement({
    required BuildContext context,
    required int termSheetDisbursedAmountDetailsId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _disbursementRepository.deleteDisbursedAmountDetails(
      termSheetDisbursedAmountDetailsId: termSheetDisbursedAmountDetailsId,
      termSheetId: termSheetId,
      termSheetDetailsId: termSheetDetailsId,
      projectId: projectId,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        showSuccessMessage(context, subTitle: response["message"]);
        await getTermSheetView(context, projectId, termSheetId);
      },
    );
  }
}
