import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_report/client_loan_report/data/model/client_loan_report.model.dart';
import 'package:k3h_erp_app/features/crm/crm_report/client_loan_report/data/repository/client_loan_report.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';

part 'client_loan_report_state.dart';

class ClientLoanReportCubit extends Cubit<ClientLoanReportState> {
  ClientLoanReportCubit() : super(ClientLoanReportState.initial());

  final ClientLoanReportRepository _clientLoanReportRepository =
      serviceLocator<ClientLoanReportRepository>();

  Future searchClientLoanReport(
    BuildContext context,
    String value,
    int projectId,
  ) async {
    emit(
      state.copyWith(
        searchText: value,
        clientLoanReportList: [],
        currentPage: 1,
      ),
    );
    await getClientLoanReportList(context, pageNumber: 1, projectId: projectId);
  }

  Future applyDarAllocationFilterAndSort({
    required BuildContext context,
    String? applicantName,
    String? sortColumn,
    String? sortDirection,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          searchText: "",
          filterByApplicantName: "",
          currentSortColumn: "Created Date",
          currentSortDirection: "DESC",
          clientLoanReportList: [],
        ),
      );
    } else {
      emit(
        state.copyWith(
          searchText: applicantName ?? state.searchText,

          currentSortColumn: sortColumn ?? state.currentSortColumn,
          currentSortDirection: sortDirection ?? state.currentSortDirection,
          clientLoanReportList: [],
        ),
      );
    }
    await getClientLoanReportList(
      context,
      pageNumber: 1,
      projectId: getProject().projectId,
    );
  }

  int updateDarAllocationFilterCount(ClientLoanReportState state) {
    final hasSort =
        state.currentSortColumn == "Applicant Name" &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");
    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterByApplicantName.trim().isNotEmpty,
      hasSort,
    ]);
  }

  Future resetAndFetchForProject(BuildContext context, int projectId) async {
    emit(
      state.copyWith(
        searchText: "",
        filterByApplicantName: "",
        currentSortColumn: "Created Date",
        currentSortDirection: "DESC",
        clientLoanReportList: [],
        currentPage: 1,
        totalNumberOfRecord: 0,
      ),
    );
    await getClientLoanReportList(context, pageNumber: 1, projectId: projectId);
  }

  Future getClientLoanReportList(
    BuildContext context, {
    required int pageNumber,
    int? pageSize,
    int? projectId,
  }) async {
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
      });
      emit(state.copyWith(isLoading: false));
      return;
    }
    var result = await _clientLoanReportRepository
        .getProjectWiseClientLoanReportList(
          pageNumber: pageNumber,
          pageSize: 10,
          queryParams: {
            "ProjectId": projectId,
            "ApplicantName": state.searchText,
            "SortBy":
                "${state.currentSortColumn} ${state.currentSortDirection}",
          },
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));

        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<ClientLoanReportModel> newList =
            response['data'] as List<ClientLoanReportModel>;

        final updatedList =
            pageNumber == 1
                ? newList
                : [...state.clientLoanReportList, ...newList];

        emit(
          state.copyWith(
            clientLoanReportList: updatedList,
            currentPage: pageNumber,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            isLoading: false,
          ),
        );
      },
    );
  }

  Future exportExcelPdf(BuildContext context, String exportType) async {
    if (state.totalNumberOfRecord == 0) {
      showErrorMessage(context, "Error", "No Data Found");
      return;
    }
    DialogHelper.showProcessingOverlay(context);
    var result = await _clientLoanReportRepository.exportClientLoanReport(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      projectId: getProject().projectId,
      queryParams:
          state.searchText != ""
              ? {"ApplicantName": state.searchText, "ExportType": exportType}
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
              ? "Client Loan Report ${DateTime.now()}.pdf"
              : "Client Loan Report ${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
