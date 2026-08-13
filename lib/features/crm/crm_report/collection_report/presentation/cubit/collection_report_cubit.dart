import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_report/collection_report/data/model/collection_report.model.dart';
import 'package:k3h_erp_app/features/crm/crm_report/collection_report/data/model/collection_report_project_wise.model.dart';
import 'package:k3h_erp_app/features/crm/crm_report/collection_report/data/repository/collection_report.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';

part 'collection_report_state.dart';

class CollectionReportCubit extends Cubit<CollectionReportState> {
  CollectionReportCubit() : super(CollectionReportState.initial());

  final CollectionReportRepository _collectionReportRepository =
      serviceLocator<CollectionReportRepository>();

  // SEARCH
  Future searchDCR(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, collectionReportList: []));
    await getDailyCollectionReportList(context, pageNumber: 1);
  }

  Future getDailyCollectionReportList(
    BuildContext context, {
    required int pageNumber,
    int? pageSize,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {};

    if (state.searchText.trim().isNotEmpty) {
      queryParams["ProjectName"] = state.searchText.trim();
    }
    var result = await _collectionReportRepository
        .getProjectWiseCollectionReportList(
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
        final List<CollectionReportModel> newList =
            response['data'] as List<CollectionReportModel>;

        final updatedList =
            pageNumber == 1
                ? newList
                : [...state.collectionReportList, ...newList];

        emit(
          state.copyWith(
            collectionReportList: updatedList,
            currentPage: pageNumber,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            isLoading: false,
          ),
        );
      },
    );
  }

  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _collectionReportRepository
        .exportProjectWiseCollectionReportList(
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
              ? "Collection Report ${DateTime.now()}.pdf"
              : "Collection Report ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future getDailyCollectionReportProjectWiseList(
    BuildContext context, {
    required int projectId,
    required String projectName,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {};

    if (state.searchText.trim().isNotEmpty) {
      queryParams["ProjectName"] = state.searchText.trim();
    }
    var result = await _collectionReportRepository
        .getProjectCollectionReportList(
          projectId: projectId,
          projectName: projectName,
          queryParams: queryParams,
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));

        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<CollectionReportProjectWiseModel> newList =
            response['data'] as List<CollectionReportProjectWiseModel>;

        emit(
          state.copyWith(
            collectionProjectReportList: newList,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            isLoading: false,
          ),
        );
      },
    );
  }
}
