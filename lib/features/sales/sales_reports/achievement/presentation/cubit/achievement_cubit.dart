import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/project_achievement_report.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/sourcing_achievement_report.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/repository/achievement_report.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import '../../../../../../di/app_dependencies.dart';
import '../../../../../../utils/common_function.dart';
import '../../data/model/closing_achievement_report.model.dart';
import 'achievement.state.dart';

class AchievementCubit extends Cubit<AchievementState> {
  AchievementCubit() : super(AchievementState.initial());
  final AchievementReportRepository _achievementRepository =
      serviceLocator<AchievementReportRepository>();

  void resetState() {
    emit(
      state.copyWith(
        searchText: '',
        currentSortColumn: '',
        currentSortDirection: '',
        projectAchievementReportList: [],
        closingAchievementReportList: [],
        sourcingAchievementReportList: [],
        projectAchievementTotalNumberOfRecord: 0,
        closingAchievementTotalNumberOfRecord: 0,
        sourcingAchievementTotalNumberOfRecord: 0,
      ),
    );
  }

  void search({
    required BuildContext context,
    required String searchText,
    required int activeSecondaryTabIndex,
    required String filterType,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    emit(state.copyWith(searchText: searchText));
    switch (activeSecondaryTabIndex) {
      case 0:
        getProjectAchievementReport(
          context: context,
          pageNumber: 1,
          filterType: filterType,
          fromDate: fromDate,
          toDate: toDate,
        );
        break;
      case 1:
        getClosingAchievementReport(
          context: context,
          pageNumber: 1,
          filterType: filterType,
          fromDate: fromDate,
          toDate: toDate,
        );
        break;
      case 2:
        getSourcingAchievementReport(
          context: context,
          pageNumber: 1,
          filterType: filterType,
          fromDate: fromDate,
          toDate: toDate,
        );
        break;
      default:
    }
  }

  Future<void> getProjectAchievementReport({
    required BuildContext context,
    required int pageNumber,
    required String filterType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    emit(state.copyWith(isLoading: true));
    final Map<String, dynamic> queryParams = {
      'ProjectName': state.searchText.trim(),
      'FromDate': fromDate?.toIso8601String(),
      'ToDate': toDate?.toIso8601String(),
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _achievementRepository.getProjectAchievementReport(
      pageNumber: pageNumber,
      pageSize: 10,
      filterType: filterType,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<ProjectAchievementReportModel> newData =
            List<ProjectAchievementReportModel>.from(response['data'] ?? []);

        final List<ProjectAchievementReportModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.projectAchievementReportList, ...newData];

        emit(
          state.copyWith(
            projectAchievementReportList: updatedList,
            projectAchievementTotalNumberOfRecord:
                response['totalNumberOfRecord'],
            isLoading: false,
            currentProjectAchievementReportPageNumber: pageNumber,
          ),
        );
      },
    );
  }

  Future<void> getClosingAchievementReport({
    required BuildContext context,
    required int pageNumber,
    required String filterType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    emit(state.copyWith(isLoading: true));
    final Map<String, dynamic> queryParams = {
      'EmployeeName': state.searchText.trim(),
      'FromDate': fromDate?.toIso8601String(),
      'ToDate': toDate?.toIso8601String(),
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _achievementRepository.getClosingAchievementReport(
      pageNumber: pageNumber,
      pageSize: 10,
      filterType: filterType,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<ClosingAchievementReportModel> newData =
            List<ClosingAchievementReportModel>.from(response['data'] ?? []);

        final List<ClosingAchievementReportModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.closingAchievementReportList, ...newData];

        emit(
          state.copyWith(
            closingAchievementReportList: updatedList,
            closingAchievementTotalNumberOfRecord:
                response['totalNumberOfRecord'],
            isLoading: false,
            currentClosingAchievementReportPageNumber: pageNumber,
          ),
        );
      },
    );
  }

  Future<void> getSourcingAchievementReport({
    required BuildContext context,
    required int pageNumber,
    required String filterType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    emit(state.copyWith(isLoading: true));
    final Map<String, dynamic> queryParams = {
      'EmployeeName': state.searchText.trim(),
      'FromDate': fromDate?.toIso8601String(),
      'ToDate': toDate?.toIso8601String(),
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _achievementRepository.getSourcingAchievementReport(
      pageNumber: pageNumber,
      pageSize: 10,
      filterType: filterType,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<SourcingAchievementReportModel> newData =
            List<SourcingAchievementReportModel>.from(response['data'] ?? []);

        final List<SourcingAchievementReportModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.sourcingAchievementReportList, ...newData];

        emit(
          state.copyWith(
            sourcingAchievementReportList: updatedList,
            sourcingAchievementTotalNumberOfRecord:
                response['totalNumberOfRecord'],
            isLoading: false,
            currentSourcingAchievementReportPageNumber: pageNumber,
          ),
        );
      },
    );
  }

  Future<void> resetManagerAchievementReportState() async {
    emit(
      state.copyWith(
        managerSearchText: '',
        managerCurrentSortColumn: '',
        managerCurrentSortDirection: '',
        managerClosingAchievementReportList: [],
        managerSourcingAchievementReportList: [],
        managerClosingAchievementTotalNumberOfRecord: 0,
        managerSourcingAchievementTotalNumberOfRecord: 0,
        managerClosingAchievementReportPageNumber: 1,
        managerSourcingAchievementReportPageNumber: 1,
      ),
    );
  }

  void managerSearch({
    required BuildContext context,
    required String searchText,
    required int reportTabIndex,
    required String filterType,
    DateTime? fromDate,
    DateTime? toDate,
    required int projectId,
  }) {
    emit(state.copyWith(managerSearchText: searchText));

    switch (reportTabIndex) {
      case 0:
        getManagerClosingAchievementReport(
          context: context,
          pageNumber: 1,
          filterType: filterType,
          fromDate: fromDate,
          toDate: toDate,
          projectId: projectId,
        );
        break;

      case 1:
        getManagerSourcingAchievementReport(
          context: context,
          pageNumber: 1,
          filterType: filterType,
          fromDate: fromDate,
          toDate: toDate,
          projectId: projectId,
        );
        break;

      default:
    }
  }

  Future<void> getManagerClosingAchievementReport({
    required BuildContext context,
    required int pageNumber,
    required String filterType,
    DateTime? fromDate,
    DateTime? toDate,
    int? projectId,
  }) async {
    emit(state.copyWith(isLoading: true));

    final Map<String, dynamic> queryParams = {
      'EmployeeName': state.managerSearchText.trim(),
      'FromDate': fromDate?.toIso8601String(),
      'ToDate': toDate?.toIso8601String(),
      'ProjectId': projectId,
      'SortBy':
          "${state.managerCurrentSortColumn} ${state.managerCurrentSortDirection}",
    };

    var result = await _achievementRepository.getClosingAchievementReport(
      pageNumber: pageNumber,
      pageSize: 10,
      filterType: filterType,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<ClosingAchievementReportModel> newData =
            List<ClosingAchievementReportModel>.from(response['data'] ?? []);

        final List<ClosingAchievementReportModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.managerClosingAchievementReportList, ...newData];

        emit(
          state.copyWith(
            managerClosingAchievementReportList: updatedList,
            managerClosingAchievementTotalNumberOfRecord:
                response['totalNumberOfRecord'],
            managerClosingAchievementReportPageNumber: pageNumber,
            isLoading: false,
          ),
        );
      },
    );
  }

  Future<void> getManagerSourcingAchievementReport({
    required BuildContext context,
    required int pageNumber,
    required String filterType,
    DateTime? fromDate,
    DateTime? toDate,
    int? projectId,
  }) async {
    emit(state.copyWith(isLoading: true));

    final Map<String, dynamic> queryParams = {
      'EmployeeName': state.managerSearchText.trim(),
      'FromDate': fromDate?.toIso8601String(),
      'ToDate': toDate?.toIso8601String(),
      'ProjectId': projectId,
      'SortBy':
          "${state.managerCurrentSortColumn} ${state.managerCurrentSortDirection}",
    };

    var result = await _achievementRepository.getSourcingAchievementReport(
      pageNumber: pageNumber,
      pageSize: 10,
      filterType: filterType,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<SourcingAchievementReportModel> newData =
            List<SourcingAchievementReportModel>.from(response['data'] ?? []);

        final List<SourcingAchievementReportModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.managerSourcingAchievementReportList, ...newData];

        emit(
          state.copyWith(
            managerSourcingAchievementReportList: updatedList,

            managerSourcingAchievementTotalNumberOfRecord:
                response['totalNumberOfRecord'],

            managerSourcingAchievementReportPageNumber: pageNumber,

            isLoading: false,
          ),
        );
      },
    );
  }

  Future applyAchievementFilterAndSort({
    required BuildContext context,
    String? sortColumn,
    String? sortDirection,
    required int activeSecondaryTabIndex,
  }) async {
    emit(
      state.copyWith(
        currentSortColumn: sortColumn ?? '',
        currentSortDirection: sortDirection ?? '',
        currentProjectAchievementReportPageNumber: 1,
        currentClosingAchievementReportPageNumber: 1,
        currentSourcingAchievementReportPageNumber: 1,
      ),
    );

    switch (activeSecondaryTabIndex) {
      case 0:
        await getProjectAchievementReport(
          context: context,
          pageNumber: 1,
          filterType: '',
        );
        break;

      case 1:
        await getClosingAchievementReport(
          context: context,
          pageNumber: 1,
          filterType: '',
        );
        break;

      case 2:
        await getSourcingAchievementReport(
          context: context,
          pageNumber: 1,
          filterType: '',
        );
        break;
    }
  }

  Future applyManagerAchievementFilterAndSort({
    required BuildContext context,
    String? sortColumn,
    String? sortDirection,
    required int activeSecondaryTabIndex,
    required int projectId,
    required DateTime? fromDate,
    required DateTime? toDate,
    required String filterType,
  }) async {
    emit(
      state.copyWith(
        managerCurrentSortColumn: sortColumn ?? '',
        managerCurrentSortDirection: sortDirection ?? '',
        managerClosingAchievementReportPageNumber: 1,
        managerSourcingAchievementReportPageNumber: 1,
      ),
    );

    switch (activeSecondaryTabIndex) {
      case 0:
        await getManagerClosingAchievementReport(
          context: context,
          pageNumber: 1,
          projectId: projectId,
          fromDate: fromDate,
          toDate: toDate,
          filterType: filterType,
        );
        break;

      case 1:
        await getManagerSourcingAchievementReport(
          context: context,
          pageNumber: 1,
          projectId: projectId,
          fromDate: fromDate,
          toDate: toDate,
          filterType: filterType,
        );
        break;
    }
  }

  Future exportExcelPdf(
    BuildContext context,
    String exportType, {
    required String filterType,
    required int? secondTabIndex,
  }) async {
    switch (secondTabIndex) {
      case 0:
        exportProjectExcelPdf(context, exportType, filterType: filterType);
        break;
      case 1:
        exportClosingExcelPdf(context, exportType, filterType: filterType);
        break;
      case 2:
        exportSourcingExcelPdf(context, exportType, filterType: filterType);
        break;
      case null:
        break;
    }
  }

  Future exportProjectExcelPdf(
    BuildContext context,
    String exportType, {
    required String filterType,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _achievementRepository
        .getProjectAchievementReportForExport(
          pageNumber: 1,
          pageSize: state.projectAchievementTotalNumberOfRecord,
          filterType: filterType,
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
              ? "Achievement By Project ${DateTime.now()}.pdf"
              : "Achievement By Project ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future exportClosingExcelPdf(
    BuildContext context,
    String exportType, {
    required String filterType,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _achievementRepository
        .getClosingAchievementReportForExport(
          pageNumber: 1,
          pageSize: state.closingAchievementTotalNumberOfRecord,
          filterType: filterType,
          queryParams:
              state.searchText != ""
                  ? {"EmployeeName": state.searchText, "ExportType": exportType}
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
              ? "Achievement By Closing ${DateTime.now()}.pdf"
              : "Achievement By Closing ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future exportSourcingExcelPdf(
    BuildContext context,
    String exportType, {
    required String filterType,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _achievementRepository
        .getSourcingAchievementReportForExport(
          pageNumber: 1,
          pageSize: state.sourcingAchievementTotalNumberOfRecord,
          filterType: filterType,
          queryParams:
              state.searchText != ""
                  ? {"EmployeeName": state.searchText, "ExportType": exportType}
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
              ? "Achievement By Sourcing ${DateTime.now()}.pdf"
              : "Achievement By Sourcing ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  void exportManagerExcelPdf({
    required BuildContext context,
    required String exportType,
    required String filterType,
    required int reportTabIndex,
    required int projectId,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    switch (reportTabIndex) {
      case 0:
        exportManagerClosingExcelPdf(
          context,
          exportType,
          filterType: filterType,
          fromDate: fromDate,
          toDate: toDate,
          projectId: projectId,
        );
        break;

      case 1:
        exportManagerSourcingExcelPdf(
          context,
          exportType,
          filterType: filterType,
          fromDate: fromDate,
          toDate: toDate,
          projectId: projectId,
        );
        break;

      default:
    }
  }

  Future exportManagerClosingExcelPdf(
    BuildContext context,
    String exportType, {
    required String filterType,
    required int projectId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _achievementRepository
        .getClosingAchievementReportForExport(
          pageNumber: 1,
          pageSize: state.managerClosingAchievementTotalNumberOfRecord,
          filterType: filterType,
          queryParams:
              state.managerSearchText != ""
                  ? {
                    "EmployeeName": state.managerSearchText,
                    "ExportType": exportType,
                    'FromDate': fromDate?.toIso8601String(),
                    'ToDate': toDate?.toIso8601String(),
                    'ProjectId': projectId,
                  }
                  : {
                    "ExportType": exportType,
                    'FromDate': fromDate?.toIso8601String(),
                    'ToDate': toDate?.toIso8601String(),
                    'ProjectId': projectId,
                  },
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
              ? "Achievement By Closing ${DateTime.now()}.pdf"
              : "Achievement By Closing ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future exportManagerSourcingExcelPdf(
    BuildContext context,
    String exportType, {
    required String filterType,
    required int projectId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _achievementRepository
        .getSourcingAchievementReportForExport(
          pageNumber: 1,
          pageSize: state.managerSourcingAchievementTotalNumberOfRecord,
          filterType: filterType,
          queryParams:
              state.managerSearchText != ""
                  ? {
                    'FromDate': fromDate?.toIso8601String(),
                    'ToDate': toDate?.toIso8601String(),
                    'ProjectId': projectId,
                    "EmployeeName": state.managerSearchText,
                    "ExportType": exportType,
                  }
                  : {
                    "ExportType": exportType,
                    'FromDate': fromDate?.toIso8601String(),
                    'ToDate': toDate?.toIso8601String(),
                    'ProjectId': projectId,
                  },
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
              ? "Achievement By Sourcing ${DateTime.now()}.pdf"
              : "Achievement By Sourcing ${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
