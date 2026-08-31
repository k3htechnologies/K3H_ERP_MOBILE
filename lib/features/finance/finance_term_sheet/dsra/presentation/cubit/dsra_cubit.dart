import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/dsra/data/repository/dsra.repository.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/repository/term_sheet.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

part 'dsra_state.dart';

class DsraCubit extends Cubit<DsraState> {
  DsraCubit() : super(DsraState.inital());

  // REPOSITORY
  final DsraRepository _dsraRepository = serviceLocator<DsraRepository>();

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

  Future<void> addDsra({
    required BuildContext context,
    required String term,
    required int unit,
    required double perUnitRate,
    required double amount,
    required DateTime date,
    required double rateOfInterestInPercentage,
    required double redemptionValue,
    required int maturityPeriod,
    required double withdrawAmount,
    DateTime? withdrawDate,
    required String remark,
    required int projectId,
    required int termSheetDetailsId,
    required int termSheetId,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final Map<String, dynamic> requestBody = {
      "TermSheetId": termSheetId,
      "TermSheetDetailsId": termSheetDetailsId,
      "ProjectId": projectId,
      "Term": term,
      "Unit": unit,
      "PerUnitRate": perUnitRate,
      "Amount": amount,
      "Date": date.apiDate,
      "RateOfInterestInPercentage": rateOfInterestInPercentage,
      "RedemptionValue": redemptionValue,
      "MaturityPeriod": maturityPeriod,
      "WithdrawAmount": withdrawAmount,
      "WithdrawDate": withdrawDate?.apiDate,
      "Remark": remark,
    };

    final result = await _dsraRepository
        .addUpdateTermSheetDebtServiceReserveAccount(body: requestBody);
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

  Future<void> updateDsra({
    required BuildContext context,
    required int termSheetDebtServiceReserveAccountId,
    required String uniqueKey,
    required String term,
    required int unit,
    required double perUnitRate,
    required double amount,
    required DateTime date,
    required double rateOfInterestInPercentage,
    required double redemptionValue,
    required int maturityPeriod,
    required double withdrawAmount,
    DateTime? withdrawDate,
    required String remark,
    required int projectId,
    required int termSheetDetailsId,
    required int termSheetId,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final Map<String, dynamic> requestBody = {
      "TermSheetDebtServiceReserveAccountId":
          termSheetDebtServiceReserveAccountId,
      "Uniquekey": uniqueKey,
      "TermSheetId": termSheetId,
      "TermSheetDetailsId": termSheetDetailsId,
      "ProjectId": projectId,
      "Term": term,
      "Unit": unit,
      "PerUnitRate": perUnitRate,
      "Amount": amount,
      "Date": date.apiDate,
      "RateOfInterestInPercentage": rateOfInterestInPercentage,
      "RedemptionValue": redemptionValue,
      "MaturityPeriod": maturityPeriod,
      "WithdrawAmount": withdrawAmount,
      "WithdrawDate": withdrawDate?.apiDate,
      "Remark": remark,
    };

    final result = await _dsraRepository
        .addUpdateTermSheetDebtServiceReserveAccount(body: requestBody);
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

  Future<void> deleteDsra({
    required BuildContext context,
    required int termSheetDebtServiceReserveAccountId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _dsraRepository
        .deleteTermSheetDebtServiceReserveAccount(
          termSheetDebtServiceReserveAccountId:
              termSheetDebtServiceReserveAccountId,
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
