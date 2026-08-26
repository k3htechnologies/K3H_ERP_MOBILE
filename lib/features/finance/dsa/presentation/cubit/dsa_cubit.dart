import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/finance/dsa/data/repository/dsa.repository.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/repository/term_sheet.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

part 'dsa_state.dart';

class DsaCubit extends Cubit<DsaState> {
  DsaCubit() : super(DsaState.inital());
  // REPOSITORY
  final DSARepository _dsaRepository = serviceLocator<DSARepository>();

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

  Future<void> addDsa({
    required BuildContext context,
    required double amount,
    required double commission,
    required String nameOfCommission,
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
      "CommissionInPercentage": commission,
      "NameOfConsultant": nameOfCommission,
      "PaymentDate": date.apiDate,
      "Remark": remark,
    };

    final result = await _dsaRepository.addUpdateTermSheetDirectSellingAgent(
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

  Future<void> updateDsa({
    required BuildContext context,
    required int termSheetDirectSellingAgentId,
    required String uniquekey,
    required double amount,
    required double commission,
    required String nameOfCommission,
    required DateTime date,
    required int projectId,
    required String remark,
    required int termSheetDetailsId,
    required int termSheetId,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final Map<String, dynamic> requestBody = {
      "TermSheetDirectSellingAgentId": termSheetDirectSellingAgentId,
      "Uniquekey": uniquekey,
      "TermSheetId": termSheetId,
      "TermSheetDetailsId": termSheetDetailsId,
      "ProjectId": projectId,
      "Amount": amount,
      "CommissionInPercentage": commission,
      "NameOfConsultant": nameOfCommission,
      "PaymentDate": date.apiDate,
      "Remark": remark,
    };

    final result = await _dsaRepository.addUpdateTermSheetDirectSellingAgent(
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

  Future<void> deleteDsa({
    required BuildContext context,
    required int termSheetDirectSellingAgentId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _dsaRepository.deleteTermSheetDirectSellingAgent(
      termSheetDirectSellingAgentId: termSheetDirectSellingAgentId,
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
