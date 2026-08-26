import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/finance/repayment/data/repository/repayment.repository.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/repository/term_sheet.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

part 'repayment_state.dart';

class RepaymentCubit extends Cubit<RepaymentState> {
  RepaymentCubit() : super(RepaymentState.inital());
  // REPOSITORY
  final RepaymentRepository _repaymentRepository =
      serviceLocator<RepaymentRepository>();
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

  Future<void> addRepayment({
    required BuildContext context,
    required double amount,
    required DateTime date,
    required int projectId,
    required String remark,
    required int termSheetDetailsId,
    required int termSheetId,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final Map<String, dynamic> requestBody = {
      "TermSheetId": termSheetId,
      "TermSheetDetailsId": termSheetDetailsId,
      "ProjectId": projectId,
      "Amount": amount,
      "PaymentDate": date.apiDate,
      "Remark": remark,
    };

    final result = await _repaymentRepository.addUpdateTermSheetRepayLedger(
      body: requestBody,
    );
    if (context.mounted) {
      goRouter.pop();
    }
    result.fold(
      (failure) {
        if (context.mounted) {
          showErrorMessage(context, 'Error', failure.message);
        }
      },
      (response) async {
        if (context.mounted) {
          showSuccessMessage(context, subTitle: response["message"]);
        }
        await getTermSheetView(context, projectId, termSheetId);
        if (context.mounted) {
          goRouter.pop();
        }
      },
    );
  }

  Future<void> updateRepayment({
    required BuildContext context,
    required int termSheetRepayLedgerId,
    required String uniquekey,
    required double amount,
    required DateTime date,
    required int projectId,
    required String remark,
    required int termSheetDetailsId,
    required int termSheetId,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final Map<String, dynamic> requestBody = {
      "TermSheetRepayLedgerId": termSheetRepayLedgerId,
      "Uniquekey": uniquekey,
      "TermSheetId": termSheetId,
      "TermSheetDetailsId": termSheetDetailsId,
      "ProjectId": projectId,
      "Amount": amount,
      "PaymentDate": date.apiDate,
      "Remark": remark,
    };

    final result = await _repaymentRepository.addUpdateTermSheetRepayLedger(
      body: requestBody,
    );
    if (context.mounted) {
      goRouter.pop();
    }
    result.fold(
      (failure) {
        if (context.mounted) {
          showErrorMessage(context, 'Error', failure.message);
        }
      },
      (response) async {
        if (context.mounted) {
          showSuccessMessage(context, subTitle: response["message"]);
        }
        await getTermSheetView(context, projectId, termSheetId);
        if (context.mounted) {
          goRouter.pop();
        }
      },
    );
  }

  Future<void> deleteRepayment({
    required BuildContext context,
    required int termSheetRepayLedgerId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _repaymentRepository.deleteTermSheetDirectSellingAgent(
      termSheetRepayLedgerId: termSheetRepayLedgerId,
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
