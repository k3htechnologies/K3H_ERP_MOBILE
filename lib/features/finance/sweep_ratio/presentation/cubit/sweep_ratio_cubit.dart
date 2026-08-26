import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/finance/sweep_ratio/data/repository/sweep_ratio.repository.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/repository/term_sheet.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

part 'sweep_ratio_state.dart';

class SweepRatioCubit extends Cubit<SweepRatioState> {
  SweepRatioCubit() : super(SweepRatioState.inital());

  // REPOSITORY
  final SweepRatioRepository _sweepRatioRepository =
      serviceLocator<SweepRatioRepository>();

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

  Future<void> addSweepRatioDetails({
    required BuildContext context,
    required double lenderSweepRatioInPercentage,
    required double ownSweepRatioInPercentage,
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
      "OwnSweepRatioInPercentage": ownSweepRatioInPercentage,
      "LenderSweepRatioInPercentage": lenderSweepRatioInPercentage,
      "Date": date.apiDate,
      "Remark": remark,
    };

    final result = await _sweepRatioRepository
        .addUpdateTermSheetSweepRatioDetails(body: requestBody);
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

  Future<void> updateSweepRatioDetails({
    required BuildContext context,
    required double lenderSweepRatioInPercentage,
    required double ownSweepRatioInPercentage,
    required DateTime date,
    required int projectId,
    required String remark,
    required int termSheetDetailsId,
    required int termSheetId,
    required int termSheetSweepRatioDetailsId,
    required String uniquekey,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final Map<String, dynamic> requestBody = {
      "TermSheetSweepRatioDetailsId": termSheetSweepRatioDetailsId,
      "Uniquekey": uniquekey,
      "TermSheetId": termSheetId,
      "TermSheetDetailsId": termSheetDetailsId,
      "ProjectId": projectId,
      "OwnSweepRatioInPercentage": ownSweepRatioInPercentage,
      "LenderSweepRatioInPercentage": lenderSweepRatioInPercentage,
      "Date": date.apiDate,
      "Remark": remark,
    };

    final result = await _sweepRatioRepository
        .addUpdateTermSheetSweepRatioDetails(body: requestBody);
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

  Future<void> deleteSweepRatioDetails({
    required BuildContext context,
    required int termSheetSweepRatioDetailsId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _sweepRatioRepository.deleteSweepRatioDetails(
      termSheetSweepRatioDetailsId: termSheetSweepRatioDetailsId,
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
