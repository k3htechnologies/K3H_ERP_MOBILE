import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/data/model/payment_schedule_scheme.model.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/data/repository/payment_schedule_scheme.repository.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/presentation/cubit/payment_schedule_scheme_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

class PaymentScheduleSchemeCubit extends Cubit<PaymentScheduleSchemeState> {
  PaymentScheduleSchemeCubit() : super(PaymentScheduleSchemeState.initial());

  final PaymentScheduleSchemeRepository _repository =
      serviceLocator<PaymentScheduleSchemeRepository>();

  // ----------------------------------------------------------
  // SEARCH
  // ----------------------------------------------------------

  Future searchPaymentScheduleScheme(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, paymentScheduleSchemeList: []));
    await getPaymentScheduleSchemeList(context, 1);
  }

  // ----------------------------------------------------------
  // GET LIST
  // ----------------------------------------------------------

  Future getPaymentScheduleSchemeList(
    BuildContext context,
    int pageNumber,
  ) async {
    emit(state.copyWith(isLoading: true));

    Map<String, dynamic> queryParams = {
      "PaymentScheduleSchemeName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    var result = await _repository.getPaymentScheduleSchemeList(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: getProject().projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<PaymentScheduleSchemeModel> newData =
            List<PaymentScheduleSchemeModel>.from(response['data'] ?? []);

        final updatedList =
            pageNumber == 1
                ? newData
                : [...state.paymentScheduleSchemeList, ...newData];

        emit(
          state.copyWith(
            paymentScheduleSchemeList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future addPaymentScheduleScheme({
    required BuildContext context,
    required int projectId,
    required String schemeName,
    required int orderBy,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, dynamic> requestBody = {
      "PaymentScheduleSchemeId": 0,
      "ProjectId": projectId,
      "PaymentScheduleSchemeName": schemeName,
      "OrderBy": orderBy,
    };

    var result = await _repository.addUpdatePaymentScheduleScheme(
      body: requestBody,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(
          context,
          subTitle: "Payment Schedule Scheme Added Successfully!!!",
        );
      },
    );
  }

  Future updatePaymentScheduleScheme({
    required BuildContext context,
    required int paymentScheduleSchemeId,
    required String uniqueKey,
    required int projectId,
    required String schemeName,
    required int orderBy,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, dynamic> requestBody = {
      "PaymentScheduleSchemeId": paymentScheduleSchemeId,
      "Uniquekey": uniqueKey,
      "ProjectId": projectId,
      "PaymentScheduleSchemeName": schemeName,
      "OrderBy": orderBy,
    };

    var result = await _repository.addUpdatePaymentScheduleScheme(
      body: requestBody,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();

        final updatedItem = response['data'][0] as PaymentScheduleSchemeModel;

        if (state.paymentScheduleSchemeList.isNotEmpty &&
            index < state.paymentScheduleSchemeList.length) {
          final updatedList = List<PaymentScheduleSchemeModel>.from(
            state.paymentScheduleSchemeList,
          );

          updatedList[index] = updatedItem;

          emit(state.copyWith(paymentScheduleSchemeList: updatedList));
        }

        showSuccessMessage(
          context,
          subTitle: "Payment Schedule Scheme Updated Successfully!!!",
        );
      },
    );
  }
  // ----------------------------------------------------------
  // EXPORT
  // ----------------------------------------------------------

  Future exportExcelPdf(
    BuildContext context,
    String exportType,
    int projectId,
  ) async {
    DialogHelper.showProcessingOverlay(context);

    var result = await _repository.exportPaymentScheduleScheme(
      pageNumber: 1,
      projectId: projectId,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {
                "PaymentScheduleSchemeName": state.searchText,
                "ExportType": exportType,
              }
              : {"ExportType": exportType},
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "paymentScheduleScheme_${DateTime.now()}.pdf"
              : "paymentScheduleScheme_${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
