import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/project_document/document/data/model/document.model.dart';
import 'package:k3h_erp_app/features/project_document/document/data/repository/document.repository.dart';
import 'package:k3h_erp_app/features/project_document/document_category/data/model/document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/document_category/data/repository/document_category.repository.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

part 'document_state.dart';

class DocumentCubit extends Cubit<DocumentState> {
  DocumentCubit() : super(DocumentState.initial());

  final DocumentCategoryRepository _documentCategoryRepository =
      serviceLocator<DocumentCategoryRepository>();
  final DocumentRepository _documentRepository =
      serviceLocator<DocumentRepository>();

  // <---- GET CATEGORY LIST ---->
  Future getCategoryList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    var result = await _documentCategoryRepository.getDocumentCategory(
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
                response['data'] as List<DocumentCategoryModel>,
            totalNumberOfRecord:
                response['totalNumberOfRecord'] == 0 && state.currentPage != 1
                    ? state.totalNumberOfRecord - 1
                    : response['totalNumberOfRecord'],
            currentPage: pageNumber,
            categoryIndex:
                (response['data'] as List<DocumentCategoryModel>).isEmpty
                    ? -1
                    : 0,
            projectDocumentCategoryId:
                (response['data'] as List<DocumentCategoryModel>).isEmpty
                    ? 0
                    : (response['data'] as List<DocumentCategoryModel>)
                        .first
                        .projectDocumentCategoryId,
          ),
        );
        if ((response['data'] as List<DocumentCategoryModel>).isNotEmpty) {
          getProjectDocumentList(context: context, pageNumber: 1);
        }
      },
    );
  }

  // <---- GET PROJECT DOCUMENT ---->
  Future getProjectDocumentList({
    required BuildContext context,
    required int pageNumber,
    int? projectDocumentId,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ProjectDocumentName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      "ProjectDocumentCategoryId": state.projectDocumentCategoryId,
      "ProjectDocumentId": projectDocumentId,
    };

    var result = await _documentRepository.pullProjectDocument(
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
        final List<DocumentModel> newData = List<DocumentModel>.from(
          response['data'] ?? [],
        );

        if (projectDocumentId == null) {
          final List<DocumentModel> updatedList =
              pageNumber == 1 ? newData : [...state.documentList, ...newData];
          emit(
            state.copyWith(
              isLoading: false,
              documentList: updatedList,
              totalNumberOfRecord: response["totalNumberOfRecord"],
              currentPage: pageNumber,
            ),
          );
        } else {
          final List<DocumentModel> updatedSubDocList =
              pageNumber == 1
                  ? newData
                  : [...state.subDocumentList, ...newData];
          emit(
            state.copyWith(
              isLoading: false,
              subDocumentList: updatedSubDocList,
              totalNumberOfRecordOfSubDoc: response["totalNumberOfRecord"],
              currentPageOfSubDoc: pageNumber,
            ),
          );
        }
      },
    );
  }

  //UPDATE SUB DOCUMENT
  Future updateSubDocument({
    required int index,
    required BuildContext context,
    required int projectDocumentId,
    required String uniqueKey,
    required int projectDocumentCategoryId,
    DateTime? projectDocumentExpiryDate,
    String? projectDocumentStatus,
    String? projectDocumentRemark,
    MultiFilePickerModel? documents,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectDocumentId": projectDocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "ProjectDocumentCategoryId": projectDocumentCategoryId.toString(),
      "IsMaster": 0.toString(),
      "ProjectDocumentExpiryDate":
          projectDocumentExpiryDate != null
              ? projectDocumentExpiryDate.toIso8601String()
              : '',
      "ProjectDocumentStatus": projectDocumentStatus ?? '',
      "ProjectDocumentRemark": projectDocumentRemark ?? '',
    };
    if (documents != null) {
      for (int i = 0; i < documents.fileNameList.length; i++) {
        if (documents.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "ProjectDocumentURL",
          "value": documents.fileBytesList[i],
          "fileName": documents.fileNameList[i],
        });
      }
    }

    var result = await _documentRepository.addUpdateDocument(
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

        final updatedDocument = response['data'][0] as DocumentModel;

        if (state.subDocumentList.isNotEmpty &&
            index < state.subDocumentList.length) {
          final updatedListModel = List<DocumentModel>.from(
            state.subDocumentList,
          );

          updatedListModel[index] = updatedDocument;
          emit(
            state.copyWith(isLoading: false, subDocumentList: updatedListModel),
          );
        }

        showSuccessMessage(
          context,
          subTitle: "Project Document Updated Successfully",
        );
      },
    );
  }

  // ADD SUB DOCUMENT
  Future addSubDocument({
    required int index,
    required BuildContext context,
    required int projectDocumentId,
    required String uniqueKey,
    required int projectDocumentCategoryId,
    DateTime? projectDocumentExpiryDate,
    String? projectDocumentStatus,
    String? projectDocumentRemark,
    MultiFilePickerModel? documents,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectDocumentId": projectDocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "ProjectDocumentCategoryId": projectDocumentCategoryId.toString(),
      //isMaster is 0 means add subdoc in document group
      "IsMaster": 0.toString(),

      "ProjectDocumentExpiryDate":
          projectDocumentExpiryDate != null
              ? projectDocumentExpiryDate.toIso8601String()
              : '',
      "ProjectDocumentStatus": projectDocumentStatus ?? '',
      "ProjectDocumentRemark": projectDocumentRemark ?? '',
    };

    if (documents != null) {
      for (int i = 0; i < documents.fileNameList.length; i++) {
        if (documents.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "ProjectDocumentURL",
          "value": documents.fileBytesList[i],
          "fileName": documents.fileNameList[i],
        });
      }
    }

    var result = await _documentRepository.addUpdateDocument(
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
        if (currentPath == AppRoutes.viewDocument) {
          goRouter.pop();
        }

        if (state.documentList.isNotEmpty &&
            index < state.documentList.length) {
          final updatedListModel = List<DocumentModel>.from(state.documentList);

          // Only increment approvalPendingProjectDocumentCount & uploadedProjectDocumentCount counts in existing parent document instance
          updatedListModel[index] = updatedListModel[index].copyWith(
            projectDocumentName: updatedListModel[index].projectDocumentName,
            approvalPendingProjectDocumentCount:
                updatedListModel[index].approvalPendingProjectDocumentCount + 1,
            uploadedProjectDocumentCount:
                updatedListModel[index].uploadedProjectDocumentCount + 1,
          );

          emit(
            state.copyWith(isLoading: false, documentList: updatedListModel),
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
    required int projectDocumentId,
    required String uniqueKey,
    required String projectDocumentName,
    required int projectDocumentCategoryId,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectDocumentId": projectDocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "ProjectDocumentName": projectDocumentName,
      "ProjectDocumentCategoryId": projectDocumentCategoryId.toString(),
      //isMaster is 1 means update document group into category
      "IsMaster": 1.toString(),
    };

    var result = await _documentRepository.addUpdateDocument(
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
        final updatedDocument = response['data'][0] as DocumentModel;

        if (state.documentList.isNotEmpty &&
            index < state.documentList.length) {
          final updatedListModel = List<DocumentModel>.from(state.documentList);
          updatedListModel[index] = updatedDocument;
          emit(
            state.copyWith(isLoading: false, documentList: updatedListModel),
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
    required String projectDocumentName,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectDocumentId": 0.toString(),
      "ProjectId": getProject().projectId.toString(),
      "ProjectDocumentName": projectDocumentName,
      "ProjectDocumentCategoryId":
          state
              .documentCategoryModelList[state.categoryIndex]
              .projectDocumentCategoryId
              .toString(),
      //isMaster is 1 means add document group into category
      "IsMaster": 1.toString(),
    };
    List<Map<String, dynamic>> fileList = [];

    var result = await _documentRepository.addUpdateDocument(
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
        final updatedList = response['data'][0] as DocumentModel;
        var list = [updatedList, ...state.documentList];

        emit(
          state.copyWith(
            documentList: list,
            totalNumberOfRecord:
                state.totalNumberOfRecord == -1
                    ? 1
                    : state.totalNumberOfRecord + 1,
          ),
        );

        showSuccessMessage(
          context,
          subTitle: "Project Document Added Successfully",
        );
      },
    );
  }

  //UPDATE CATEGORY INDEX AND MAKE GET API CALL AS PER CATEGORY
  void onTabChanged(int index, BuildContext context) {
    emit(
      state.copyWith(
        categoryIndex: index,
        projectDocumentCategoryId:
            state.documentCategoryModelList[index].projectDocumentCategoryId,
        documentList: [],
      ),
    );
    getProjectDocumentList(context: context, pageNumber: 1);
  }

  // SEARCH BASED ON SHIFT
  void searchDocument(String value, BuildContext context) {
    emit(
      state.copyWith(
        documentList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );
    getProjectDocumentList(context: context, pageNumber: 1);
  }

  // <---- DELETE DOCUMENT CATEGORY  ---->
  Future deleteDocument(
    DocumentModel document,
    BuildContext context,
    int index,
  ) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _documentRepository.deleteDocument(
      projectDocumentCategoryId:
          state
              .documentCategoryModelList[state.categoryIndex]
              .projectDocumentCategoryId,
      projectDocumentId: document.projectDocumentId,
      uniqueKey: document.uniquekey,
      projectId: getProject().projectId,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        final updatedList = List<DocumentModel>.from(state.documentList);
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            documentList: updatedList,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );
        showSuccessMessage(context, subTitle: "Document Deleted Successfully");
      },
    );
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(
    BuildContext context,
    String exportType,
    int projectId,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _documentRepository.exportProjectDocument(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      projectId: projectId,
      queryParams:
          state.searchText != ""
              ? {
                "ChannelPartnerName": state.searchText,
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
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "channel_partner_${DateTime.now()}.pdf"
              : "channel_partner_${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
