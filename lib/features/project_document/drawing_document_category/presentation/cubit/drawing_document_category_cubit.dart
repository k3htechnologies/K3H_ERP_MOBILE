import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document_category/data/model/drawing_document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document_category/data/repository/drawing_document_category.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';

part 'drawing_document_category_state.dart';

class DrawingDocumentCategoryCubit extends Cubit<DrawingDocumentCategoryState> {
  DrawingDocumentCategoryCubit()
    : super(DrawingDocumentCategoryState.initial());

  final DrawingDocumentCategoryRepository _drawingDocumentCategoryRepository =
      serviceLocator<DrawingDocumentCategoryRepository>();

  Future<void> resetSearch() async {
    emit(state.copyWith(searchText: ""));
  }

  // SEARCH CATEGORY
  Future searchCategory(
    BuildContext context,
    int projectId,
    String value,
  ) async {
    emit(
      state.copyWith(
        searchText: value,
        drawingDocumentCategoryModelList: [],
        currentPage: 1,
      ),
    );
    await getDrawingDocumentCategoryList(context, 1, projectId);
  }

  // GET DRAWING DOCUMENT CATEGORY LIST
  Future getDrawingDocumentCategoryList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
        DrawingDocumentCategoryCubit();

        emit(
          state.copyWith(
            isLoading: false,
            drawingDocumentCategoryModelList: [],
          ),
        );
      });
      return;
    }
    Map<String, dynamic> queryParams = {
      "DrawingDocumentCategory": state.searchText,
      "IsCheckPermission": true,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _drawingDocumentCategoryRepository
        .getDrawingDocumentCategory(
          pageNumber: pageNumber,
          pageSize: 10,
          projectId: projectId,
          queryParams: queryParams,
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<DrawingDocumentCategoryModel> newData =
            List<DrawingDocumentCategoryModel>.from(response['data'] ?? []);

        final List<DrawingDocumentCategoryModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.drawingDocumentCategoryModelList, ...newData];
        // final bool isDescending =
        //     state.currentSortDirection.toUpperCase() == "DESC";

        // updatedList.sort((a, b) {
        //   final comparison = a.drawingDocumentCategoryName
        //       .trim()
        //       .toLowerCase()
        //       .compareTo(b.drawingDocumentCategoryName.trim().toLowerCase());

        //   return isDescending ? -comparison : comparison;
        // });

        emit(
          state.copyWith(
            drawingDocumentCategoryModelList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future addDrawingADocumentCategory({
    required BuildContext context,
    required int index,
    required int projectId,
    required String drawingDocumentCategory,
    required int orderBy,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectId": projectId,
      "DrawingDocumentCategory": drawingDocumentCategory,
      "OrderBy": orderBy,
    };
    var result = await _drawingDocumentCategoryRepository
        .addUpdateDrawingDocumentCategory(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();

        showSuccessMessage(context, subTitle: response['message']);
        searchCategory(context, projectId, "");
      },
    );
  }

  Future updateDrawingDocumentCategory({
    required int index,
    required BuildContext context,
    required String uniqueKey,
    required int drawingDocumentCategoryId,
    required int projectId,
    required String drawingDocumentCategory,
    required int orderBy,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "DrawingDocumentCategoryId": drawingDocumentCategoryId,
      "Uniquekey": uniqueKey,
      "ProjectId": projectId,
      "DrawingDocumentCategory": drawingDocumentCategory,
      "OrderBy": orderBy,
    };
    var result = await _drawingDocumentCategoryRepository
        .addUpdateDrawingDocumentCategory(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedList = response['data'][0] as DrawingDocumentCategoryModel;

        if (state.drawingDocumentCategoryModelList.isNotEmpty &&
            index < state.drawingDocumentCategoryModelList.length) {
          final updatedListModel = List<DrawingDocumentCategoryModel>.from(
            state.drawingDocumentCategoryModelList,
          );
          updatedListModel[index] = updatedList;
          emit(
            state.copyWith(drawingDocumentCategoryModelList: updatedListModel),
          );
        }

        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future deleteDrawingDocumentCategory(
    int projectId,
    DrawingDocumentCategoryModel drawingDocumentCategoryModel,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _drawingDocumentCategoryRepository
        .deleteDrawingDocumentCategory(
          drawingDocumentCategoryId:
              drawingDocumentCategoryModel.drawingDocumentCategoryId,
          uniqueKey: drawingDocumentCategoryModel.uniquekey,
          projectId: projectId,
        );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        showSuccessMessage(context, subTitle: success['message']);

        getDrawingDocumentCategoryList(context, state.currentPage, projectId);
      },
    );
  }

  // EXPORT EXCEL PDF
  Future exportExcelPdf(
    BuildContext context,
    String exportType,
    int projectId,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _drawingDocumentCategoryRepository
        .exportDrawingDocumentCategory(
          pageNumber: 1,
          pageSize: state.totalNumberOfRecord,
          projectId: projectId,
          queryParams:
              state.searchText != ""
                  ? {
                    "ProjectRERADocumentCategory": state.searchText,
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
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "Drawing Document Category Master ${DateTime.now()}.pdf"
              : "Drawing Document Category Master ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  // SORT TEST DOCUMENT CATEGORY
  Future applyFilterAndSortDrawingDocumentCategory({
    required BuildContext context,
    required String column,
    required String direction,
    required String testDocument,
  }) async {
    emit(
      state.copyWith(
        searchText: testDocument,
        currentSortColumn: column,
        currentSortDirection: direction,
        drawingDocumentCategoryModelList: [],
      ),
    );
    await getDrawingDocumentCategoryList(context, 1, getProject().projectId);
  }

  int updateFilterCount(DrawingDocumentCategoryState state) {
    final hasSort =
        state.currentSortColumn == "Drawing Document Category" &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");
    return getActiveFilterCount([hasSort, state.searchText.trim().isNotEmpty]);
  }
}
