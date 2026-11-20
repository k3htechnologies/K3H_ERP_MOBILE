import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/project_document/test_document_category/data/model/test_document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/test_document_category/data/repository/test_document_category.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
part 'test_document_category_state.dart';

class TestDocumentCategoryCubit extends Cubit<TestDocumentCategoryState> {
  TestDocumentCategoryCubit() : super(TestDocumentCategoryState.initial());
  final TestDocumentCategoryRepository _testDocumentCategoryRepository =
      serviceLocator<TestDocumentCategoryRepository>();
  Future<void> resetSearch() async {
    emit(state.copyWith(searchText: ""));
  }

  // GET RERA DOCUMENT CATEGORY LIST
  Future getTestDocumentCategoryList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
        TestDocumentCategoryCubit();
        emit(state.copyWith(isLoading: false, testDocumentCategoryList: []));
      });
      return;
    }
    Map<String, dynamic> queryParams = {
      "TestDocumentCategory": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _testDocumentCategoryRepository.getTestDocumentCategory(
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
        final List<TestDocumentCategoryModel> newData =
            List<TestDocumentCategoryModel>.from(response['data'] ?? []);
        final List<TestDocumentCategoryModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.testDocumentCategoryList, ...newData];
        emit(
          state.copyWith(
            testDocumentCategoryList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
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
        testDocumentCategoryList: [],
        currentPage: 1,
      ),
    );
    await getTestDocumentCategoryList(context, 1, projectId);
  }

  Future deleteTestDocumentCategory({
    required int projectId,
    required TestDocumentCategoryModel testDocumentCategoryModel,
    required BuildContext context,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final result = await _testDocumentCategoryRepository
        .deleteTestDocumentCategory(
          testDocumentCategoryId:
              testDocumentCategoryModel.testDocumentCategoryId,
          uniqueKey: testDocumentCategoryModel.uniquekey,
          projectId: projectId,
        );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final updatedCategoryList = List<TestDocumentCategoryModel>.from(
          state.testDocumentCategoryList,
        );
        updatedCategoryList.removeAt(index);
        emit(
          state.copyWith(
            testDocumentCategoryList: updatedCategoryList,
            isLoading: false,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future updateTestDocumentCategory({
    required int index,
    required BuildContext context,
    required String uniqueKey,
    required int testDocumentCategoryId,
    required int projectId,
    required String testDocumentCategory,
    required int orderBy,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "TestDocumentCategoryId": testDocumentCategoryId,
      "Uniquekey": uniqueKey,
      "ProjectId": projectId,
      "TestDocumentCategory": testDocumentCategory,
      "OrderBy": orderBy,
    };
    var result = await _testDocumentCategoryRepository
        .addUpdateTestDocumentCategory(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedList = response['data'][0] as TestDocumentCategoryModel;
        if (state.testDocumentCategoryList.isNotEmpty &&
            index < state.testDocumentCategoryList.length) {
          final updatedListModel = List<TestDocumentCategoryModel>.from(
            state.testDocumentCategoryList,
          );
          updatedListModel[index] = updatedList;
          emit(state.copyWith(testDocumentCategoryList: updatedListModel));
        }
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future addTestADocumentCategory({
    required BuildContext context,
    required int index,
    required int projectId,
    required String testDocumentCategory,
    required int orderBy,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectId": projectId,
      "TestDocumentCategory": testDocumentCategory,
      "OrderBy": orderBy,
    };
    var result = await _testDocumentCategoryRepository
        .addUpdateTestDocumentCategory(body: body);
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

  // EXPORT EXCEL PDF
  Future exportExcelPdf(
    BuildContext context,
    String exportType,
    int projectId,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _testDocumentCategoryRepository
        .exportTestDocumentCategory(
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
              ? "test_document_category_${DateTime.now()}.pdf"
              : "test_document_category_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  // SORT TEST DOCUMENT CATEGORY
  Future applyFilterAndSortTestDocumentCategory({
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
        testDocumentCategoryList: [],
      ),
    );
    await getTestDocumentCategoryList(context, 1, getProject().projectId);
  }

  int updateFilterCount(TestDocumentCategoryState state) {
    final hasSort =
        state.currentSortColumn == "Test Document Category" &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");
    return getActiveFilterCount([hasSort, state.searchText.trim().isNotEmpty]);
  }
}
