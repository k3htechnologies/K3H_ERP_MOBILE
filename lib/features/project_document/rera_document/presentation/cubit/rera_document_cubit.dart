import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/data/model/rera_document.model.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/data/repository/rera_document.repository.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/presentation/cubit/rera_document_state.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/data/model/rera_document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/data/repository/rera_document_category.repository.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

class RERADocumentCubit extends Cubit<RERADocumentState> {
  RERADocumentCubit() : super(RERADocumentState.initial());

  final RERADocumentCategoryRepository _reraDocumentCategoryRepository =
      serviceLocator<RERADocumentCategoryRepository>();
  final RERADocumentRepository _reraDocumentRepository =
      serviceLocator<RERADocumentRepository>();

  // <---- GET CATEGORY LIST ---->
  Future getCategoryList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    var result = await _reraDocumentCategoryRepository.getReraDocumentCategory(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            documentCategoryModelList:
                response['data'] as List<RERADocumentCategoryModel>,
            totalNumberOfRecord:
                response['totalNumberOfRecord'] == 0 && state.currentPage != 1
                    ? state.totalNumberOfRecord - 1
                    : response['totalNumberOfRecord'],
            currentPage: pageNumber,
            categoryIndex:
                (response['data'] as List<RERADocumentCategoryModel>).isEmpty
                    ? -1
                    : 0,
            projectRERADocumentCategoryId:
                (response['data'] as List<RERADocumentCategoryModel>).isEmpty
                    ? 0
                    : (response['data'] as List<RERADocumentCategoryModel>)
                        .first
                        .projectRERADocumentCategoryId,
          ),
        );
        if ((response['data'] as List<RERADocumentCategoryModel>).isNotEmpty) {
          getRERADocumentList(context: context, pageNumber: 1);
        }
      },
    );
  }

  // <---- GET PROJECT RERA DOCUMENT ---->
  Future getRERADocumentList({
    required BuildContext context,
    required int pageNumber,
    int? projectRERADocumentId,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ProjectRERADocumentName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      "ProjectRERADocumentCategoryId": state.projectRERADocumentCategoryId,
      "ProjectRERADocumentId": projectRERADocumentId,
    };

    var result = await _reraDocumentRepository.pullProjectRERADocument(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: getProject().projectId,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
      },
      (response) {
        final List<RERADocumentModel> newData = List<RERADocumentModel>.from(
          response['data'] ?? [],
        );

        if (projectRERADocumentId == null) {
          final List<RERADocumentModel> updatedList =
              pageNumber == 1
                  ? newData
                  : [...state.reraDocumentList, ...newData];
          emit(
            state.copyWith(
              isLoading: false,
              reraDocumentList: updatedList,
              totalNumberOfRecord: response["totalNumberOfRecord"],
              currentPage: pageNumber,
            ),
          );
        } else {
          final List<RERADocumentModel> updatedSubDocList =
              pageNumber == 1
                  ? newData
                  : [...state.reraSubDocumentList, ...newData];
          emit(
            state.copyWith(
              isLoading: false,
              reraSubDocumentList: updatedSubDocList,
              totalNumberOfRecordOfSubDoc: response["totalNumberOfRecord"],
              currentPageOfSubDoc: pageNumber,
            ),
          );
        }
      },
    );
  }

  //UPDATE SUB RERA DOCUMENT
  Future updateRERASubDocument({
    required int index,
    required BuildContext context,
    required int projectRERADocumentId,
    required String uniqueKey,
    required int projectRERADocumentCategoryId,
    MultiFilePickerModel? screenshots,
    String? projectRERADocumentStatus,
    String? projectRERADocumentRemark,
    MultiFilePickerModel? documents,
    required String projectRERADocumentName,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectRERADocumentId": projectRERADocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "ProjectRERADocumentCategoryId": projectRERADocumentCategoryId.toString(),
      "IsMaster": 0.toString(),
      "ProjectRERADocumentName": projectRERADocumentName,
      "RemoveRERAPortalScreenShotURL": screenshots?.deletedFileList ?? "",
      "ProjectRERADocumentStatus": projectRERADocumentStatus ?? '',
      "ProjectRERADocumentRemark": projectRERADocumentRemark ?? '',
    };
    if (documents != null) {
      for (int i = 0; i < documents.fileNameList.length; i++) {
        if (documents.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "ProjectRERADocumentURL",
          "value": documents.fileBytesList[i],
          "fileName": documents.fileNameList[i],
        });
      }
    }
    if (screenshots != null) {
      for (int i = 0; i < screenshots.fileNameList.length; i++) {
        if (screenshots.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "RERAPortalScreenShotURL",
          "value": screenshots.fileBytesList[i],
          "fileName": screenshots.fileNameList[i],
        });
      }
    }

    var result = await _reraDocumentRepository.addUpdateRERADocument(
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

        final updatedDocument = response['data'][0] as RERADocumentModel;

        if (state.reraSubDocumentList.isNotEmpty &&
            index < state.reraSubDocumentList.length) {
          final updatedListModel = List<RERADocumentModel>.from(
            state.reraSubDocumentList,
          );

          updatedListModel[index] = updatedDocument;
          emit(
            state.copyWith(
              isLoading: false,
              reraSubDocumentList: updatedListModel,
            ),
          );
        }

        showSuccessMessage(
          context,
          subTitle: "RERA Document Updated Successfully",
        );
      },
    );
  }

  // ADD RERA SUB DOCUMENT
  Future addRERASubDocument({
    required int index,
    required BuildContext context,
    required int projectRERADocumentId,
    required String uniqueKey,
    required int projectRERADocumentCategoryId,
    MultiFilePickerModel? screenshots,
    String? projectRERADocumentStatus,
    String? projectRERADocumentRemark,
    MultiFilePickerModel? documents,
    required String projectRERADocumentName,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectRERADocumentId": projectRERADocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "ProjectRERADocumentCategoryId": projectRERADocumentCategoryId.toString(),
      //isMaster is 0 means add subdoc in document group
      "IsMaster": 0.toString(),
      "ProjectRERADocumentName": projectRERADocumentName,

      "ProjectRERADocumentStatus": projectRERADocumentStatus ?? '',
      "ProjectRERADocumentRemark": projectRERADocumentRemark ?? '',
    };

    if (documents != null) {
      for (int i = 0; i < documents.fileNameList.length; i++) {
        if (documents.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "ProjectRERADocumentURL",
          "value": documents.fileBytesList[i],
          "fileName": documents.fileNameList[i],
        });
      }
    }

    if (screenshots != null) {
      for (int i = 0; i < screenshots.fileNameList.length; i++) {
        if (screenshots.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "RERAPortalScreenShotURL",
          "value": screenshots.fileBytesList[i],
          "fileName": screenshots.fileNameList[i],
        });
      }
    }

    var result = await _reraDocumentRepository.addUpdateRERADocument(
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
        if (currentPath == AppRoutes.viewReraDocument) {
          goRouter.pop();
        }

        if (state.reraDocumentList.isNotEmpty &&
            index < state.reraDocumentList.length) {
          final updatedListModel = List<RERADocumentModel>.from(
            state.reraDocumentList,
          );

          // Only increment approvalPendingProjectRERADocumentCount & uploadedProjectRERADocumentCount counts in existing parent document instance
          updatedListModel[index] = updatedListModel[index].copyWith(
            projectRERADocumentName:
                updatedListModel[index].projectRERADocumentName,
            approvalPendingProjectRERADocumentCount:
                updatedListModel[index]
                    .approvalPendingProjectRERADocumentCount +
                1,
            uploadedProjectRERADocumentCount:
                updatedListModel[index].uploadedProjectRERADocumentCount + 1,
          );

          emit(
            state.copyWith(
              isLoading: false,
              reraDocumentList: updatedListModel,
            ),
          );
        }

        showSuccessMessage(
          context,
          subTitle: "RERA Document Updated Successfully",
        );
      },
    );
  }

  //RENAME PARENT DOCUMENT NAME
  Future updateRERADocumentNameInCategory({
    required int index,
    required BuildContext context,
    required int projectRERADocumentId,
    required String uniqueKey,
    required String projectRERADocumentName,
    required int projectRERADocumentCategoryId,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectRERADocumentId": projectRERADocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "ProjectRERADocumentName": projectRERADocumentName,
      "ProjectRERADocumentCategoryId": projectRERADocumentCategoryId.toString(),
      //isMaster is 1 means update document group into category
      "IsMaster": 1.toString(),
    };

    var result = await _reraDocumentRepository.addUpdateRERADocument(
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
        final updatedDocument = response['data'][0] as RERADocumentModel;

        if (state.reraDocumentList.isNotEmpty &&
            index < state.reraDocumentList.length) {
          final updatedListModel = List<RERADocumentModel>.from(
            state.reraDocumentList,
          );
          updatedListModel[index] = updatedDocument;
          emit(
            state.copyWith(
              isLoading: false,
              reraDocumentList: updatedListModel,
            ),
          );
        }

        showSuccessMessage(
          context,
          subTitle: "RERA Document Updated Successfully",
        );
      },
    );
  }

  //ADD RERA DOCUMENT TO CATEGORY (PARENT DOCUMENT)
  Future addRERADocumentToCategory({
    required BuildContext context,
    required String projectRERADocumentName,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectRERADocumentId": 0.toString(),
      "ProjectId": getProject().projectId.toString(),
      "ProjectRERADocumentName": projectRERADocumentName,
      "ProjectRERADocumentCategoryId":
          state
              .documentCategoryModelList[state.categoryIndex]
              .projectRERADocumentCategoryId
              .toString(),
      //isMaster is 1 means add document group into category
      "IsMaster": 1.toString(),
    };
    List<Map<String, dynamic>> fileList = [];

    var result = await _reraDocumentRepository.addUpdateRERADocument(
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
          subTitle: "RERA Document Added Successfully",
        );
        searchDocument("", context);
      },
    );
  }

  //UPDATE CATEGORY INDEX AND MAKE GET API CALL AS PER CATEGORY
  void onTabChanged(int index, BuildContext context) {
    emit(
      state.copyWith(
        categoryIndex: index,
        projectRERADocumentCategoryId:
            state
                .documentCategoryModelList[index]
                .projectRERADocumentCategoryId,
        reraDocumentList: [],
      ),
    );
    getRERADocumentList(context: context, pageNumber: 1);
  }

  // SEARCH BASED ON SHIFT
  void searchDocument(String value, BuildContext context) {
    emit(
      state.copyWith(
        reraDocumentList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );
    getRERADocumentList(context: context, pageNumber: 1);
  }

  // <---- DELETE RERA DOCUMENT FROM CATEGORY  ---->
  Future deleteDocument(
    RERADocumentModel document,
    int projectRERADocumentCategoryId,
    BuildContext context,
    int index, {
    bool isSubDoc = false,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _reraDocumentRepository.deleteRERADocument(
      projectRERADocumentCategoryId:
          state
              .documentCategoryModelList[state.categoryIndex]
              .projectRERADocumentCategoryId,
      projectRERADocumentId: document.projectRERADocumentId,
      uniqueKey: document.uniquekey,
      projectId: getProject().projectId,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        if (isSubDoc == false) {
          final updatedList = List<RERADocumentModel>.from(
            state.reraDocumentList,
          );

          updatedList.removeAt(index);

          emit(
            state.copyWith(
              reraDocumentList: updatedList,
              totalNumberOfRecord:
                  state.totalNumberOfRecord > 0
                      ? state.totalNumberOfRecord - 1
                      : 0,
            ),
          );
        } else {
          final updatedList = List<RERADocumentModel>.from(
            state.reraSubDocumentList,
          );

          updatedList.removeAt(index);

          emit(
            state.copyWith(
              reraSubDocumentList: updatedList,
              totalNumberOfRecordOfSubDoc:
                  state.totalNumberOfRecordOfSubDoc > 0
                      ? state.totalNumberOfRecordOfSubDoc - 1
                      : 0,
            ),
          );
        }
        showSuccessMessage(context, subTitle: "Document Deleted Successfully");
      },
    );
  }
}
