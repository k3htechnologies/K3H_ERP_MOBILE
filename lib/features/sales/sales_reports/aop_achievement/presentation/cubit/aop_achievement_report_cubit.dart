import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/achivement_drill_down_report.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/aop_achievement/data/model/aop_achievement_report.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/aop_achievement/data/repository/aop_achievement_report.repository.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/aop_achievement/presentation/cubit/aop_achievement_report_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

class AopAchievementReportCubit extends Cubit<AopAchievementReportState> {
  AopAchievementReportCubit() : super(AopAchievementReportState.initial());
  final AopAchievementReportRepository _aopAchievementRepository =
      serviceLocator<AopAchievementReportRepository>();

  void search({
    required BuildContext context,
    required String searchText,
    required String filterType,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    emit(state.copyWith(searchText: searchText, aopAchievementReportList: []));
    getAopAchievementReport(
      context: context,
      pageNumber: 1,
      filterType: filterType,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  void resetState() {
    emit(
      state.copyWith(
        searchText: '',
        currentSortColumn: '',
        currentSortDirection: '',
        currentAopAchievementReportPageNumber: 1,
        aopAchievementReportList: [],
        aopAchievementReportTotalNumberOfRecord: 0,
        isLoading: false,
      ),
    );
  }

  Future<void> getAopAchievementReport({
    required BuildContext context,
    required int pageNumber,
    required String filterType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    emit(state.copyWith(isLoading: true));
    final Map<String, dynamic> queryParams = {
      'Name': state.searchText.trim(),
      'FromDate': fromDate?.apiDate,
      'ToDate': toDate?.apiDate,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _aopAchievementRepository.getAopAchievementReport(
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
        final List<AopAchievementReportModel> newData =
            List<AopAchievementReportModel>.from(response['data'] ?? []);

        final List<AopAchievementReportModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.aopAchievementReportList, ...newData];

        emit(
          state.copyWith(
            aopAchievementReportList: updatedList,
            aopAchievementReportTotalNumberOfRecord:
                response['totalNumberOfRecord'],
            isLoading: false,
            currentAopAchievementReportPageNumber: pageNumber,
          ),
        );
      },
    );
  }

  Future exportAopAchievementReportExcelPdf(
    BuildContext context,
    String exportType, {
    required String filterType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _aopAchievementRepository
        .getAopAchievementReportForExport(
          pageNumber: 1,
          pageSize: state.aopAchievementReportTotalNumberOfRecord,
          filterType: filterType,
          queryParams: {
            "Name": state.searchText,
            "ExportType": exportType,
            'FromDate': fromDate?.apiDate,
            'ToDate': toDate?.apiDate,
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
              ? "AOP Achievement By Channel Partner ${DateTime.now()}.pdf"
              : "AOP Achievement By Channel Partner ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future updateAchievementDrillDownType({
    required AchievementDrillDownType drillDownType,
  }) async {
    emit(
      state.copyWith(
        achievementDrillDownReportList: [],
        achievementDrillDownTotalNumberOfRecord: 0,
        currentAchievementDrillDownReportPageNumber: 1,
        drillDownType: drillDownType,
      ),
    );
  }

  Future<void> getAchievementDrillDownReportList({
    required BuildContext context,
    required int pageNumber,
    int? employeeId,
    required String tabName,
    required String columnName,
    required String filterType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    emit(state.copyWith(isLoading: true));
    var queryParams = {
      "ChannelPartnerId": employeeId,
      "FromDate": fromDate.apiDate,
      "ToDate": toDate.apiDate,
    };
    var result = await _aopAchievementRepository.getAchievementDrillDownReport(
      pageNumber: pageNumber,
      pageSize: 10,
      tabName: tabName.toUpperCase(),
      columnName: columnName,
      filterType: filterType,
      achivementDrillDownType: state.drillDownType,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final newData = List<AchievementDrillDownReportModel>.from(
          response['data'] ?? [],
        );

        final updatedList =
            pageNumber == 1
                ? newData
                : [...state.achievementDrillDownReportList, ...newData];

        emit(
          state.copyWith(
            achievementDrillDownReportList: updatedList,
            achievementDrillDownTotalNumberOfRecord:
                response['totalNumberOfRecord'],
            currentAchievementDrillDownReportPageNumber: pageNumber,
            isLoading: false,
          ),
        );
      },
    );
  }

  Future<void> getAchievementDrillDownReportForExport({
    required BuildContext context,
    int? employeeId,
    required String tabName,
    required String columnName,
    required String filterType,
    DateTime? fromDate,
    DateTime? toDate,
    required String exportType,
  }) async {
    emit(state.copyWith(isLoading: true));
    var queryParams = {
      "ChannelPartnerId": employeeId,
      "FromDate": fromDate.apiDate,
      "ToDate": toDate.apiDate,
      "ExportType": exportType,
    };
    var result = await _aopAchievementRepository
        .getAchievementDrillDownReportForExport(
          pageNumber: 1,
          pageSize: state.achievementDrillDownTotalNumberOfRecord,
          tabName: tabName.toUpperCase(),
          columnName: columnName,
          filterType: filterType,
          queryParams: queryParams,
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
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
              ? "AOP Achievement ($columnName) ${DateTime.now()}.pdf"
              : "AOP Achievement ($columnName) ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  int updateFilterCount(AopAchievementReportState state) {
    final hasSort =
        state.currentSortColumn == 'Name' &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");
    return getActiveFilterCount([state.searchText.trim().isNotEmpty, hasSort]);
  }

  Future applyAchievementFilterAndSort({
    required BuildContext context,
    required String searchText,
    required String filterType,
    String? sortColumn,
    String? sortDirection,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    emit(
      state.copyWith(
        searchText: searchText,
        currentSortColumn: sortColumn ?? '',
        currentSortDirection: sortDirection ?? '',
        currentAopAchievementReportPageNumber: 1,
      ),
    );

    getAopAchievementReport(
      context: context,
      pageNumber: 1,
      filterType: filterType,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
