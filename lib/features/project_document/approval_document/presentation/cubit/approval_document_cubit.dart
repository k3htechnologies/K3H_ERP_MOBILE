import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/data/model/approval_category.model.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/data/repository/approval_category.repository.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/data/model/approval_document.model.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/data/repository/approval_document.repository.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/presentation/cubit/approval_document_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

class ApprovalDocumentCubit extends Cubit<ApprovalDocumentState> {
  ApprovalDocumentCubit() : super(ApprovalDocumentState.initial());

  final ApprovalCategoryRepository _documentCategoryRepository =
      serviceLocator<ApprovalCategoryRepository>();
  final ApprovalDocumentRepository _documentRepository =
      serviceLocator<ApprovalDocumentRepository>();

  // <---- GET CATEGORY LIST ---->
  Future getCategoryList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    var result = await _documentCategoryRepository.getApprovalDocumentCategory(
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
                response['data'] as List<ApprovalDocumentCategoryModel>,
            totalNumberOfRecord:
                response['totalNumberOfRecord'] == 0 && state.currentPage != 1
                    ? state.totalNumberOfRecord - 1
                    : response['totalNumberOfRecord'],
            currentPage: pageNumber,
            categoryIndex:
                (response['data'] as List<ApprovalDocumentCategoryModel>)
                        .isEmpty
                    ? -1
                    : 0,
            approvalDocumentCategoryId:
                (response['data'] as List<ApprovalDocumentCategoryModel>)
                        .isEmpty
                    ? 0
                    : (response['data'] as List<ApprovalDocumentCategoryModel>)
                        .first
                        .approvalDocumentCategoryId,
          ),
        );
        if ((response['data'] as List<ApprovalDocumentCategoryModel>)
            .isNotEmpty) {
          getProjectApprovalDocumentList(context: context, pageNumber: 1);
        }
      },
    );
  }

  // <---- GET PROJECT DOCUMENT ---->
  Future getProjectApprovalDocumentList({
    required BuildContext context,
    required int pageNumber,
    int? approvalDocumentId,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ApprovalDocumentName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      "ApprovalDocumentCategoryId": state.approvalDocumentCategoryId,
      "ApprovalDocumentId": approvalDocumentId,
    };

    var result = await _documentRepository.pullProjectApprovalDocument(
      pageNumber: pageNumber,
      pageSize: 5,
      projectId: getProject().projectId,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
      },
      (response) {
        final List<ApprovalDocumentModel> newData =
            List<ApprovalDocumentModel>.from(response['data'] ?? []);

        if (approvalDocumentId == null) {
          final List<ApprovalDocumentModel> updatedList = [
            ...state.documentList,
            ...newData,
          ];
          emit(
            state.copyWith(
              isLoading: false,
              documentList: updatedList,
              totalNumberOfRecord: response["totalNumberOfRecord"],
              currentPage: pageNumber,
            ),
          );
        } else {
          final List<ApprovalDocumentModel> updatedSubDocList = [
            ...state.subApprovalDocumentList,
            ...newData,
          ];
          emit(
            state.copyWith(
              isLoading: false,
              subApprovalDocumentList: updatedSubDocList,
              totalNumberOfRecordOfSubDoc: response["totalNumberOfRecord"],
              currentPageOfSubDoc: pageNumber,
            ),
          );
        }
      },
    );
  }

  //UPDATE SUB DOCUMENT
  Future updateSubApprovalDocument({
    required int index,
    required BuildContext context,
    required int approvalDocumentId,
    required String uniqueKey,
    required int approvalDocumentCategoryId,
    DateTime? approvalDocumentExpiryDate,
    String? approvalDocumentStatus,
    String? approvalDocumentRemark,
    MultiFilePickerModel? documents,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ApprovalDocumentId": approvalDocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "ApprovalDocumentCategoryId": approvalDocumentCategoryId.toString(),
      "IsMaster": 0.toString(),
      "ApprovalDocumentExpiryDate":
          approvalDocumentExpiryDate != null
              ? approvalDocumentExpiryDate.toIso8601String()
              : '',
      "ApprovalDocumentStatus": approvalDocumentStatus ?? '',
      "ApprovalDocumentRemark": approvalDocumentRemark ?? '',
    };
    if (documents != null) {
      for (int i = 0; i < documents.fileNameList.length; i++) {
        if (documents.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "ApprovalDocumentURL",
          "value": documents.fileBytesList[i],
          "fileName": documents.fileNameList[i],
        });
      }
    }

    var result = await _documentRepository.addUpdateApprovalDocument(
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

        final updatedApprovalDocument =
            response['data'][0] as ApprovalDocumentModel;

        if (state.subApprovalDocumentList.isNotEmpty &&
            index < state.subApprovalDocumentList.length) {
          final updatedListModel = List<ApprovalDocumentModel>.from(
            state.subApprovalDocumentList,
          );

          updatedListModel[index] = updatedApprovalDocument;
          emit(
            state.copyWith(
              isLoading: false,
              subApprovalDocumentList: updatedListModel,
            ),
          );
        }

        showSuccessMessage(
          context,
          subTitle: "Project ApprovalDocument Updated Successfully",
        );
      },
    );
  }

  // ADD SUB DOCUMENT
  Future addSubApprovalDocument({
    required int index,
    required BuildContext context,
    required int approvalDocumentId,
    required String uniqueKey,
    required int approvalDocumentCategoryId,
    DateTime? approvalDocumentExpiryDate,
    String? approvalDocumentStatus,
    String? approvalDocumentRemark,
    MultiFilePickerModel? documents,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ApprovalDocumentId": approvalDocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "ApprovalDocumentCategoryId": approvalDocumentCategoryId.toString(),
      //isMaster is 0 means add subdoc in document group
      "IsMaster": 0.toString(),

      "ApprovalDocumentExpiryDate":
          approvalDocumentExpiryDate != null
              ? approvalDocumentExpiryDate.toIso8601String()
              : '',
      "ApprovalDocumentStatus": approvalDocumentStatus ?? '',
      "ApprovalDocumentRemark": approvalDocumentRemark ?? '',
    };

    if (documents != null) {
      for (int i = 0; i < documents.fileNameList.length; i++) {
        if (documents.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "ApprovalDocumentURL",
          "value": documents.fileBytesList[i],
          "fileName": documents.fileNameList[i],
        });
      }
    }

    var result = await _documentRepository.addUpdateApprovalDocument(
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
        goRouter.pop();

        if (state.documentList.isNotEmpty &&
            index < state.documentList.length) {
          final updatedListModel = List<ApprovalDocumentModel>.from(
            state.documentList,
          );

          // Only increment approvalPendingApprovalDocumentCount & uploadedApprovalDocumentCount counts in existing parent document instance
          updatedListModel[index] = updatedListModel[index].copyWith(
            approvalDocumentName: updatedListModel[index].approvalDocumentName,
            approvalPendingApprovalDocumentCount:
                updatedListModel[index].approvalPendingApprovalDocumentCount +
                1,
            uploadedApprovalDocumentCount:
                updatedListModel[index].uploadedApprovalDocumentCount + 1,
          );

          emit(
            state.copyWith(isLoading: false, documentList: updatedListModel),
          );
        }

        showSuccessMessage(
          context,
          subTitle: "Project ApprovalDocument Updated Successfully",
        );
      },
    );
  }

  //RENAME PARENT DOCUMENT NAME
  Future updateApprovalDocumentNameInCategory({
    required int index,
    required BuildContext context,
    required int approvalDocumentId,
    required String uniqueKey,
    required String approvalDocumentName,
    required int approvalDocumentCategoryId,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ApprovalDocumentId": approvalDocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "ApprovalDocumentName": approvalDocumentName,
      "ApprovalDocumentCategoryId": approvalDocumentCategoryId.toString(),
      //isMaster is 1 means update document group into category
      "IsMaster": 1.toString(),
    };

    var result = await _documentRepository.addUpdateApprovalDocument(
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
        final updatedApprovalDocument =
            response['data'][0] as ApprovalDocumentModel;

        if (state.documentList.isNotEmpty &&
            index < state.documentList.length) {
          final updatedListModel = List<ApprovalDocumentModel>.from(
            state.documentList,
          );
          updatedListModel[index] = updatedApprovalDocument;
          emit(
            state.copyWith(isLoading: false, documentList: updatedListModel),
          );
        }

        showSuccessMessage(
          context,
          subTitle: "Project ApprovalDocument Updated Successfully",
        );
      },
    );
  }

  //ADD DOCUMENT TO CATEGORY
  Future addApprovalDocumentToCategory({
    required BuildContext context,
    required String approvalDocumentName,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ApprovalDocumentId": 0.toString(),
      "ProjectId": getProject().projectId.toString(),
      "ApprovalDocumentName": approvalDocumentName,
      "ApprovalDocumentCategoryId":
          state
              .documentCategoryModelList[state.categoryIndex]
              .approvalDocumentCategoryId
              .toString(),
      //isMaster is 1 means add document group into category
      "IsMaster": 1.toString(),
    };
    List<Map<String, dynamic>> fileList = [];

    var result = await _documentRepository.addUpdateApprovalDocument(
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
        final updatedList = response['data'][0] as ApprovalDocumentModel;
        var list = [updatedList, ...state.documentList];

        emit(state.copyWith(documentList: list));

        showSuccessMessage(
          context,
          subTitle: "Project ApprovalDocument Added Successfully",
        );
      },
    );
  }

  //UPDATE CATEGORY INDEX AND MAKE GET API CALL AS PER CATEGORY
  void onTabChanged(int index, BuildContext context) {
    emit(
      state.copyWith(
        categoryIndex: index,
        approvalDocumentCategoryId:
            state.documentCategoryModelList[index].approvalDocumentCategoryId,
        documentList: [],
      ),
    );
    getProjectApprovalDocumentList(context: context, pageNumber: 1);
  }

  // SEARCH BASED ON SHIFT
  void searchApprovalDocument(String value, BuildContext context) {
    emit(
      state.copyWith(
        documentList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );
    getProjectApprovalDocumentList(context: context, pageNumber: 1);
  }

  // <---- DELETE DOCUMENT CATEGORY  ---->
  Future deleteApprovalDocument(
    ApprovalDocumentModel document,
    BuildContext context,
    int index,
  ) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _documentRepository.deleteApprovalDocument(
      approvalDocumentCategoryId:
          state
              .documentCategoryModelList[state.categoryIndex]
              .approvalDocumentCategoryId,
      approvalDocumentId: document.approvalDocumentId,
      uniqueKey: document.uniquekey,
      projectId: getProject().projectId,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        final updatedList = List<ApprovalDocumentModel>.from(
          state.documentList,
        );
        updatedList.removeAt(index);
        emit(state.copyWith(documentList: updatedList));
        showSuccessMessage(
          context,
          subTitle: "ApprovalDocument Deleted Successfully",
        );
      },
    );
  }

  Future clearSubApprovalDocument() async {
    emit(state.copyWith(subApprovalDocumentList: []));
  }

  Future clearApprovalDocument() async {
    emit(state.copyWith(documentList: []));
  }
}
