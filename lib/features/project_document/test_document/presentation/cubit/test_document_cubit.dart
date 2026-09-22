import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/project_document/test_document/data/model/test_document.model.dart';
import 'package:k3h_erp_app/features/project_document/test_document/data/repository/test_document.repository.dart';
import 'package:k3h_erp_app/features/project_document/test_document_category/data/model/test_document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/test_document_category/data/repository/test_document_category.repository.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';

part 'test_document_state.dart';

class TestDocumentCubit extends Cubit<TestDocumentState> {
  TestDocumentCubit() : super(TestDocumentState.initial());

  final TestDocumentCategoryRepository _testDocumentCategoryRepositor =
      serviceLocator<TestDocumentCategoryRepository>();

  final TestDocumentRepository _testDocumentRepository =
      serviceLocator<TestDocumentRepository>();

  void searchDocument(String value, BuildContext context) {
    emit(
      state.copywith(
        testDocumentList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );
    getTestDocumentList(context: context, pageNumber: 1);
  }

  // GET CATEGORY LIST
  Future getTestCategoryList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copywith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
        TestDocumentCubit();
        emit(
          state.copywith(
            isLoading: false,
            tesDocumentCategoryModelList: [],
            testDocumentList: [],
          ),
        );
      });
      return;
    }

    var result = await _testDocumentCategoryRepositor.getTestDocumentCategory(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
    );
    result.fold(
      (failure) {
        emit(state.copywith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        emit(
          state.copywith(
            isLoading: false,
            tesDocumentCategoryModelList:
                response['data'] as List<TestDocumentCategoryModel>,
            totalNumberOfRecord:
                response['totalNumberOfRecord'] == 0 && state.currentPage != 1
                    ? state.totalNumberOfRecord - 1
                    : response['totalNumberOfRecord'],
            currentPage: pageNumber,
            categoryIndex:
                (response['data'] as List<TestDocumentCategoryModel>).isEmpty
                    ? -1
                    : 0,
            testDocumentCategoryId:
                (response['data'] as List<TestDocumentCategoryModel>).isEmpty
                    ? 0
                    : (response['data'] as List<TestDocumentCategoryModel>)
                        .first
                        .testDocumentCategoryId,
          ),
        );
        if ((response['data'] as List<TestDocumentCategoryModel>).isNotEmpty) {
          getTestDocumentList(context: context, pageNumber: 1);
        }
      },
    );
  }

  // GET TEST DOCUMENT
  Future getTestDocumentList({
    required BuildContext context,
    required int pageNumber,
    int? testDocumentId,
    String? testDocumentCategory,
  }) async {
    emit(state.copywith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "TestDocumentName": state.searchText,
      "TestDocumentCategoryId": state.testDocumentCategoryId,
      if (testDocumentId != null) "TestDocumentId": testDocumentId,
      if (testDocumentCategory != null)
        "TestDocumentCategory": testDocumentCategory,
    };

    var result = await _testDocumentRepository.pullTestDocument(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: getProject().projectId,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copywith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
      },
      (response) {
        final List<TestDocumentModel> newData = List<TestDocumentModel>.from(
          response['data'] ?? [],
        );

        if (testDocumentId == null) {
          final List<TestDocumentModel> updatedList =
              pageNumber == 1
                  ? newData
                  : [...state.testDocumentList, ...newData];
          emit(
            state.copywith(
              isLoading: false,
              testDocumentList: updatedList,
              totalNumberOfRecord: response["totalNumberOfRecord"],
              currentPage: pageNumber,
            ),
          );
        } else {
          final List<TestDocumentModel> updatedSubDocList =
              pageNumber == 1
                  ? newData
                  : [...state.subTestDocumentList, ...newData];
          emit(
            state.copywith(
              isLoading: false,
              subTestDocumentList: updatedSubDocList,
              totalNumberOfRecordOfSubDoc: response["totalNumberOfRecord"],
              currentPageOfSubDoc: pageNumber,
            ),
          );
        }
      },
    );
  }

  Future updateSubTestDocument({
    required int index,
    required BuildContext context,
    required int testDocumentId,
    required String uniqueKey,
    required String testDocumentName,
    required int testDocumentCategoryId,
    DateTime? testDocumentExpiryDate,
    String? testDocumentRemark,
    MultiFilePickerModel? documents,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "TestDocumentId": testDocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "TestDocumentName": testDocumentName,
      "TestDocumentCategoryId": testDocumentCategoryId.toString(),
      "IsMaster": 0.toString(),
      "TestDocumentExpiryDate":
          testDocumentExpiryDate != null
              ? testDocumentExpiryDate.toIso8601String()
              : '',
      "RemoveTestDocumentURL": documents?.deletedFileList ?? '',
      "TestDocumentRemark": testDocumentRemark ?? '',
    };
    if (documents != null) {
      for (int i = 0; i < documents.fileNameList.length; i++) {
        if (documents.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "TestDocumentURL",
          "value": documents.fileBytesList[i],
          "fileName": documents.fileNameList[i],
        });
      }
    }

    var result = await _testDocumentRepository.addUpdateTestDocument(
      body: body,
      fileList: fileList,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();

        final updatedDocument = response['data'][0] as TestDocumentModel;

        if (state.subTestDocumentList.isNotEmpty &&
            index < state.subTestDocumentList.length) {
          final updatedListModel = List<TestDocumentModel>.from(
            state.subTestDocumentList,
          );

          updatedListModel[index] = updatedDocument;
          emit(
            state.copywith(
              isLoading: false,
              subTestDocumentList: updatedListModel,
            ),
          );
        }

        showSuccessMessage(
          context,
          subTitle: "Test Document Updated Successfully",
        );
      },
    );
  }

  Future addSubDocument({
    required int index,
    required BuildContext context,
    required int projectDocumentId,
    required String uniqueKey,
    required int projectDocumentCategoryId,
    required String projectDocumentName,
    DateTime? projectDocumentExpiryDate,
    String? projectDocumentRemark,
    MultiFilePickerModel? documents,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "TestDocumentId": projectDocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "TestDocumentCategoryId": projectDocumentCategoryId.toString(),
      "TestDocumentName": projectDocumentName,
      //isMaster is 0 means add subdoc in document group
      "IsMaster": 0.toString(),

      "TestDocumentExpiryDate":
          projectDocumentExpiryDate != null
              ? projectDocumentExpiryDate.toIso8601String()
              : '',
      "TestDocumentRemark": projectDocumentRemark ?? '',
    };

    if (documents != null) {
      for (int i = 0; i < documents.fileNameList.length; i++) {
        if (documents.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "TestDocumentURL",
          "value": documents.fileBytesList[i],
          "fileName": documents.fileNameList[i],
        });
      }
    }

    var result = await _testDocumentRepository.addUpdateTestDocument(
      body: body,
      fileList: fileList,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final currentPath = goRouter.state.path;
        if (currentPath == AppRoutes.viewTestDocument) {
          goRouter.pop();
        }

        if (state.testDocumentList.isNotEmpty &&
            index < state.testDocumentList.length) {
          final updatedListModel = List<TestDocumentModel>.from(
            state.testDocumentList,
          );

          // Only increment approvalPendingProjectDocumentCount & uploadedProjectDocumentCount counts in existing parent document instance
          updatedListModel[index] = updatedListModel[index].copyWith(
            testDocumentName: updatedListModel[index].testDocumentName,
            approvalPendingApprovalDocumentCount:
                updatedListModel[index].approvalPendingApprovalDocumentCount +
                1,
            uploadedApprovalDocumentCount:
                updatedListModel[index].uploadedApprovalDocumentCount + 1,
          );

          emit(
            state.copywith(
              isLoading: false,
              testDocumentList: updatedListModel,
            ),
          );
        }

        showSuccessMessage(
          context,
          subTitle: "Project Document Added Successfully",
        );
      },
    );
  }

  //RENAME PARENT DOCUMENT NAME
  Future updateDocumentNameInCategory({
    required int index,
    required BuildContext context,
    required int testDocumentId,
    required String uniqueKey,
    required String testDocumentName,
    required int testDocumentCategoryId,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "TestDocumentId": testDocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "TestDocumentName": testDocumentName,
      "TestDocumentCategoryId": testDocumentCategoryId.toString(),
      //isMaster is 1 means update document group into category
      "IsMaster": 1.toString(),
    };

    var result = await _testDocumentRepository.addUpdateTestDocument(
      body: body,
      fileList: fileList,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedDocument = response['data'][0] as TestDocumentModel;

        if (state.testDocumentList.isNotEmpty &&
            index < state.testDocumentList.length) {
          final updatedListModel = List<TestDocumentModel>.from(
            state.testDocumentList,
          );
          updatedListModel[index] = updatedDocument;
          emit(
            state.copywith(
              isLoading: false,
              testDocumentList: updatedListModel,
            ),
          );
        }

        showSuccessMessage(
          context,
          subTitle: "Project Document Updated Successfully",
        );
      },
    );
  }

  //ADD DOCUMENT TO CATEGORY
  Future addDocumentToCategory({
    required BuildContext context,
    required String testDocumentName,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectId": getProject().projectId.toString(),
      "TestDocumentName": testDocumentName,
      "TestDocumentCategoryId":
          state
              .tesDocumentCategoryModelList[state.categoryIndex]
              .testDocumentCategoryId
              .toString(),
      //isMaster is 1 means add document group into category
      "IsMaster": 1.toString(),
    };
    List<Map<String, dynamic>> fileList = [];

    var result = await _testDocumentRepository.addUpdateTestDocument(
      body: body,
      fileList: fileList,
    );
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
          subTitle: "Project Document Added Successfully",
        );
        searchDocument("", context);
      },
    );
  }

  //UPDATE CATEGORY INDEX AND MAKE GET API CALL AS PER CATEGORY
  void onTabChanged(int index, BuildContext context) {
    emit(
      state.copywith(
        categoryIndex: index,
        testDocumentCategoryId:
            state.tesDocumentCategoryModelList[index].testDocumentCategoryId,
        testDocumentList: [],
      ),
    );
    getTestDocumentList(context: context, pageNumber: 1);
  }

  // DELETE DOCUMENT CATEGORY
  Future deleteDocument(
    TestDocumentModel document,
    BuildContext context,
    int index, {
    bool isSubDoc = false,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _testDocumentRepository.deleteTestDocument(
      testDocumentCategoryId:
          state
              .tesDocumentCategoryModelList[state.categoryIndex]
              .testDocumentCategoryId,
      testDocumentId: document.testDocumentId,
      uniqueKey: document.uniquekey,
      projectId: getProject().projectId,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        // Parent document delete
        if (isSubDoc == false) {
          final updatedList = List<TestDocumentModel>.from(
            state.testDocumentList,
          );
          updatedList.removeAt(index);
          emit(
            state.copywith(
              testDocumentList: updatedList,
              totalNumberOfRecord:
                  state.totalNumberOfRecord > 0
                      ? state.totalNumberOfRecord - 1
                      : 0,
            ),
          );
        } else {
          //Sub document delete
          final updatedList = List<TestDocumentModel>.from(
            state.subTestDocumentList,
          );
          updatedList.removeAt(index);
          emit(
            state.copywith(
              subTestDocumentList: updatedList,
              totalNumberOfRecordOfSubDoc:
                  state.totalNumberOfRecordOfSubDoc > 0
                      ? state.totalNumberOfRecordOfSubDoc - 1
                      : 0,
            ),
          );
        }
        showSuccessMessage(
          context,
          subTitle: "Test Document Deleted Successfully",
        );
      },
    );
  }
}
