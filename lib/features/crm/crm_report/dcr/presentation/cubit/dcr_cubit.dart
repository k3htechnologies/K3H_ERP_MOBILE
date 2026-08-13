import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_report/dcr/data/model/dcr.model.dart';
import 'package:k3h_erp_app/features/crm/crm_report/dcr/data/repository/dcr.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';

part 'dcr_state.dart';

class DcrCubit extends Cubit<DcrState> {
  DcrCubit() : super(DcrState.initial());

  final DCRRepository _dcrRepository = serviceLocator<DCRRepository>();

  // SEARCH
  Future searchDCR(
    BuildContext context,
    String value, {
    String? filterType,
  }) async {
    emit(state.copyWith(searchText: value, dcrReportList: []));
    await getDailyCollectionReportList(
      context,
      pageNumber: 1,
      filterType: filterType!,
      projectId: getProject().projectId,
    );
  }

  Future getDailyCollectionReportList(
    BuildContext context, {
    required int pageNumber,
    int? pageSize,
    required String filterType,
    required int projectId,
    String? fromDate,
    String? toDate,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {};

    if (state.searchText.trim().isNotEmpty) {
      queryParams["ProjectName"] = state.searchText.trim();
    }
    var result = await _dcrRepository.getDailyCollectionReportList(
      filterType: filterType,
      projectId: projectId,
      fromDate: fromDate,
      toDate: toDate,
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));

        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<DcrModel> newList = response['data'] as List<DcrModel>;

        final updatedList =
            pageNumber == 1 ? newList : [...state.dcrReportList, ...newList];

        emit(
          state.copyWith(
            dcrReportList: updatedList,
            currentPage: pageNumber,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            isLoading: false,
            selectedFilterType: filterType,
          ),
        );
      },
    );
  }

  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _dcrRepository.exportDailyCollectionReportList(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      projectId: getProject().projectId,
      queryParams:
          state.searchText != ""
              ? {"ProjectName": state.searchText, "ExportType": exportType}
              : {"ExportType": exportType},
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "Daily Collection Report ${DateTime.now()}.pdf"
              : "Daily Collection Report ${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
