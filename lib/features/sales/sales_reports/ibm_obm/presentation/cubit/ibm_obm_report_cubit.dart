import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/ibm_obm/data/model/ibm_obm_report.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/ibm_obm/presentation/cubit/ibm_obm_report_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

import '../../data/repository/ibm_obm_report.repository.dart';

class IbmObmReportCubit extends Cubit<IbmObmReportState> {
  final IbmObmReportRepository ibmObmReportRepository;

  IbmObmReportCubit({required this.ibmObmReportRepository})
    : super(IbmObmReportState.initial());

  Future<void> getIbmObmReport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await ibmObmReportRepository.getIbmObmReport(
      pageNumber: pageNumber,
      pageSize: pageSize,
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
      },
      (response) {
        final List<IbmObmReportModel> newData = List<IbmObmReportModel>.from(
          response['data'] ?? [],
        );

        final List<IbmObmReportModel> updatedList =
            pageNumber == 1 ? newData : [...state.ibmObmReportList, ...newData];

        emit(
          state.copyWith(
            isLoading: false,
            ibmObmReportList: updatedList,
            totalNumberOfRecord: response['totalNumberOfRecord'] ?? 0,
            currentPageNumber: pageNumber,
          ),
        );
      },
    );
  }

  Future<void> getIbmObmReportForExport(
    BuildContext context,
    String exportType, {
    required int pageNumber,
    required int pageSize,
    required int projectId,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await ibmObmReportRepository.getIbmObmReportForExport(
      pageNumber: pageNumber,
      pageSize: pageSize,
      projectId: projectId,
      queryParams: {"ExportType": exportType},
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
              ? "IBM OBM Report ${DateTime.now()}.pdf"
              : "IBM OBM Report ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  void search(String value) {
    emit(state.copyWith(searchText: value));
  }

  void applyIbmObmFilterAndSort({
    required String column,
    required String direction,
  }) {
    emit(
      state.copyWith(
        currentSortColumn: column,
        currentSortDirection: direction,
      ),
    );
  }
}
