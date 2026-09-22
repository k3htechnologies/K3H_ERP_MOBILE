import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/project_document/test_document_category/data/model/test_document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/test_document_category/data/repository/test_document_category.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

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
        emit(
          state.copyWith(isLoading: false, testDocumentCategoryModelList: []),
        );
      });
      return;
    }
    Map<String, dynamic> queryParams = {
      "TestDocumentCategory": state.searchText,
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
                : [...state.testDocumentCategoryModelList, ...newData];
        emit(
          state.copyWith(
            testDocumentCategoryModelList: updatedList,
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
        testDocumentCategoryModelList: [],
        currentPage: 1,
      ),
    );
    await getTestDocumentCategoryList(context, 1, projectId);
  }

  // CLEAR RERA DOCUMENT CATEGORY LIST
  void clearDocumentCategory() {
    try {
      emit(
        state.copyWith(
          testDocumentCategoryModelList: [],
          currentPage: 1,
          totalNumberOfRecord: 0,
          isLoading: true,
          searchText: "",
        ),
      );
    } catch (e) {}
  }

  Future deleteTestDocumentCategory(
    int projectId,
    TestDocumentCategoryModel testDocumentCategoryModel,
    BuildContext context,
  ) async {
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
      (success) {
        showSuccessMessage(
          context,
          subTitle: "Test Document Category Deleted Successfully",
        );

        getTestDocumentCategoryList(context, state.currentPage, projectId);
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

        if (state.testDocumentCategoryModelList.isNotEmpty &&
            index < state.testDocumentCategoryModelList.length) {
          final updatedListModel = List<TestDocumentCategoryModel>.from(
            state.testDocumentCategoryModelList,
          );
          updatedListModel[index] = updatedList;
          emit(state.copyWith(testDocumentCategoryModelList: updatedListModel));
        }

        showSuccessMessage(
          context,
          subTitle: "Test document category updated successfully",
        );
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

        showSuccessMessage(
          context,
          subTitle: 'Test document category added successfully',
        );
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
}
