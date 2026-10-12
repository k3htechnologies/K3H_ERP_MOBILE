import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/data/model/drawing_document.model.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/data/model/inventory_drawing_document.model.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/data/repository/drawing_document.repository.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document_category/data/model/drawing_document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document_category/data/repository/drawing_document_category.repository.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';

part 'drawing_document_state.dart';

class DrawingDocumentCubit extends Cubit<DrawingDocumentState> {
  DrawingDocumentCubit() : super(DrawingDocumentState.initial());

  final DrawingDocumentCategoryRepository __drawingDocumentCategoryRepositor =
      serviceLocator<DrawingDocumentCategoryRepository>();

  final DrawingDocumentRepository _drawingDocumentRepository =
      serviceLocator<DrawingDocumentRepository>();

  void searchDocument(String value, BuildContext context) {
    emit(
      state.copyWith(
        drawingDocumentList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );
    getDrawingDocumentList(context: context, pageNumber: 1);
  }

  // GET CATEGORY LIST
  Future getDrawingDocumentCategoryList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
        DrawingDocumentCubit();
        emit(
          state.copyWith(
            isLoading: false,
            drawingDocumentCategoryModelList: [],
            drawingDocumentList: [],
          ),
        );
      });
      return;
    }

    var result = await __drawingDocumentCategoryRepositor
        .getDrawingDocumentCategory(
          pageNumber: pageNumber,
          pageSize: 500,
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
            drawingDocumentCategoryModelList:
                response['data'] as List<DrawingDocumentCategoryModel>,
            totalNumberOfRecord:
                response['totalNumberOfRecord'] == 0 && state.currentPage != 1
                    ? state.totalNumberOfRecord - 1
                    : response['totalNumberOfRecord'],
            currentPage: pageNumber,
            categoryIndex:
                (response['data'] as List<DrawingDocumentCategoryModel>).isEmpty
                    ? -1
                    : 0,
            drawingDocumentCategoryId:
                (response['data'] as List<DrawingDocumentCategoryModel>).isEmpty
                    ? 0
                    : (response['data'] as List<DrawingDocumentCategoryModel>)
                        .first
                        .drawingDocumentCategoryId,
          ),
        );
        if ((response['data'] as List<DrawingDocumentCategoryModel>)
            .isNotEmpty) {
          getDrawingDocumentList(context: context, pageNumber: 1);
        }
      },
    );
  }

  // GET TEST DOCUMENT
  Future getDrawingDocumentList({
    required BuildContext context,
    required int pageNumber,
    int? drawingDocumentId,
    String? drawingDocumentCategory,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "DrawingDocumentName": state.searchText,
      "BuildingNumber": state.buildingNumberText,
      "Wing": state.wingText,
      "Floor": state.floorText,
      "DrawingDocumentCategoryId": state.drawingDocumentCategoryId,
      if (drawingDocumentId != null) "DrawingDocumentId": drawingDocumentId,
      if (drawingDocumentCategory != null)
        "DrawingDocumentCategory": drawingDocumentCategory,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    var result = await _drawingDocumentRepository.pullDrawingDocument(
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
        final List<DrawingDocumentModel> newData =
            List<DrawingDocumentModel>.from(response['data'] ?? []);

        if (drawingDocumentId == null) {
          final List<DrawingDocumentModel> updatedList =
              pageNumber == 1
                  ? newData
                  : [...state.drawingDocumentList, ...newData];
          emit(
            state.copyWith(
              isLoading: false,
              drawingDocumentList: updatedList,
              totalNumberOfRecord: response["totalNumberOfRecord"],
              currentPage: pageNumber,
            ),
          );
        } else {
          final List<DrawingDocumentModel> updatedSubDocList =
              pageNumber == 1
                  ? newData
                  : [...state.subDrawingDocumentList, ...newData];
          emit(
            state.copyWith(
              isLoading: false,
              subDrawingDocumentList: updatedSubDocList,
              totalNumberOfRecordOfSubDoc: response["totalNumberOfRecord"],
              currentPageOfSubDoc: pageNumber,
            ),
          );
        }
      },
    );
  }

  Future<void> getInventoryDrawingDocumentList({
    required BuildContext context,
    int pageNumber = 1,
    int? projectId,
    int? inventoryFloorId,
    String? floor,
  }) async {
    emit(state.copyWith(isLoading: true));

    final Map<String, dynamic> queryParams = {
      "InventoryFloorId": inventoryFloorId,
      "Floor": floor,
    };

    final result = await _drawingDocumentRepository
        .pullInventoryDrawingDocument(
          projectId: projectId!,
          queryParams: queryParams,
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
      },
      (response) {
        final List<InventoryDrawingDocumentModel> newData =
            List<InventoryDrawingDocumentModel>.from(response['data'] ?? []);

        final List<InventoryDrawingDocumentModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.inventoryDrawingDocumentList, ...newData];

        emit(
          state.copyWith(
            isLoading: false,
            inventoryDrawingDocumentList: updatedList,
          ),
        );
      },
    );
  }

  Future updateSubDrawingDocument({
    required int index,
    required BuildContext context,
    required int drawingDocumentId,
    required String uniqueKey,
    required String drawingDocumentName,
    required int drawingDocumentCategoryId,
    DateTime? drawingDocumentRevisionDate,
    String? drawingDocumentRemark,
    String? drawingDocumentStatus,
    String? inventoryFloorId,
    MultiFilePickerModel? documents,
    MultiFilePickerModel? documentDWG,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "DrawingDocumentId": drawingDocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "DrawingDocumentName": drawingDocumentName,
      "DrawingDocumentCategoryId": drawingDocumentCategoryId.toString(),
      "IsMaster": 0.toString(),
      "DrawingDocumentRevisionDate":
          drawingDocumentRevisionDate != null
              ? drawingDocumentRevisionDate.toIso8601String()
              : '',
      "RemoveDrawingDocumentURL": documents?.deletedFileList ?? '',
      "RemoveDrawingDocumentDWGURL": documentDWG?.deletedFileList ?? '',
      "DrawingDocumentRemark": drawingDocumentRemark ?? '',
      "DrawingDocumentStatus": drawingDocumentStatus.toString(),
      "InventoryFloorId": inventoryFloorId.toString(),
    };
    if (documents != null) {
      for (int i = 0; i < documents.fileNameList.length; i++) {
        if (documents.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "DrawingDocumentURL",
          "value": documents.fileBytesList[i],
          "fileName": documents.fileNameList[i],
        });
      }
    }
    if (documentDWG != null) {
      for (int i = 0; i < documentDWG.fileNameList.length; i++) {
        if (documentDWG.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "DrawingDocumentDWGURL",
          "value": documentDWG.fileBytesList[i],
          "fileName": documentDWG.fileNameList[i],
        });
      }
    }

    var result = await _drawingDocumentRepository.addUpdateDrawingDocument(
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

        final updatedDocument = response['data'][0] as DrawingDocumentModel;

        if (state.subDrawingDocumentList.isNotEmpty &&
            index < state.subDrawingDocumentList.length) {
          final updatedListModel = List<DrawingDocumentModel>.from(
            state.subDrawingDocumentList,
          );

          updatedListModel[index] = updatedDocument;
          emit(
            state.copyWith(
              isLoading: false,
              subDrawingDocumentList: updatedListModel,
            ),
          );
        }

        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future addSubDrawingDocument({
    required int index,
    required BuildContext context,
    required int drawingDocumentId,
    required String uniqueKey,
    required int drawingDocumentCategoryId,
    required String drawingDocumentName,
    DateTime? drawingDocumentRevisionDate,
    String? drawingDocumentRemark,
    MultiFilePickerModel? documents,
    MultiFilePickerModel? documentDWG,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "DrawingDocumentId": drawingDocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "DrawingDocumentCategoryId": drawingDocumentCategoryId.toString(),
      "DrawingDocumentName": drawingDocumentName,
      //isMaster is 0 means add subdoc in document group
      "IsMaster": 0.toString(),

      "DrawingDocumentRevisionDate":
          drawingDocumentRevisionDate != null
              ? drawingDocumentRevisionDate.toIso8601String()
              : '',
      "DrawingDocumentRemark": drawingDocumentRemark ?? '',
    };

    if (documents != null) {
      for (int i = 0; i < documents.fileNameList.length; i++) {
        if (documents.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "DrawingDocumentURL",
          "value": documents.fileBytesList[i],
          "fileName": documents.fileNameList[i],
        });
      }
    }
    if (documentDWG != null) {
      for (int i = 0; i < documentDWG.fileNameList.length; i++) {
        if (documentDWG.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "DrawingDocumentDWGURL",
          "value": documentDWG.fileBytesList[i],
          "fileName": documentDWG.fileNameList[i],
        });
      }
    }

    var result = await _drawingDocumentRepository.addUpdateDrawingDocument(
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
        if (currentPath == AppRoutes.viewDrawingDocument) {
          goRouter.pop();
        }

        if (state.drawingDocumentList.isNotEmpty &&
            index < state.drawingDocumentList.length) {
          final updatedListModel = List<DrawingDocumentModel>.from(
            state.drawingDocumentList,
          );

          // Only increment approvalPendingProjectDocumentCount & uploadedProjectDocumentCount counts in existing parent document instance
          updatedListModel[index] = updatedListModel[index].copyWith(
            drawingDocumentName: updatedListModel[index].drawingDocumentName,
            approvalPendingApprovalDocumentCount:
                updatedListModel[index].approvalPendingApprovalDocumentCount +
                1,
            uploadedApprovalDocumentCount:
                updatedListModel[index].uploadedApprovalDocumentCount + 1,
          );

          emit(
            state.copyWith(
              isLoading: false,
              drawingDocumentList: updatedListModel,
            ),
          );
        }

        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  //RENAME PARENT DOCUMENT NAME
  Future updateDrawingDocumentNameInCategory({
    required int index,
    required BuildContext context,
    required int drawingDocumentId,
    required String uniqueKey,
    required String drawingDocumentName,
    required int drawingDocumentCategoryId,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "DrawingDocumentId": drawingDocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "DrawingDocumentName": drawingDocumentName,
      "DrawingDocumentCategoryId": drawingDocumentCategoryId.toString(),
      //isMaster is 1 means update document group into category
      "IsMaster": 1.toString(),
    };

    var result = await _drawingDocumentRepository.addUpdateDrawingDocument(
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
        final updatedDocument = response['data'][0] as DrawingDocumentModel;

        if (state.drawingDocumentList.isNotEmpty &&
            index < state.drawingDocumentList.length) {
          final updatedListModel = List<DrawingDocumentModel>.from(
            state.drawingDocumentList,
          );
          updatedListModel[index] = updatedDocument;
          emit(
            state.copyWith(
              isLoading: false,
              drawingDocumentList: updatedListModel,
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
  Future addDrawingDocumentToCategory({
    required BuildContext context,
    required String drawingDocumentName,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectId": getProject().projectId.toString(),
      "DrawingDocumentName": drawingDocumentName,
      "DrawingDocumentCategoryId":
          state
              .drawingDocumentCategoryModelList[state.categoryIndex]
              .drawingDocumentCategoryId
              .toString(),
      //isMaster is 1 means add document group into category
      "IsMaster": 1.toString(),
    };
    List<Map<String, dynamic>> fileList = [];

    var result = await _drawingDocumentRepository.addUpdateDrawingDocument(
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
      state.copyWith(
        categoryIndex: index,
        drawingDocumentCategoryId:
            state
                .drawingDocumentCategoryModelList[index]
                .drawingDocumentCategoryId,
        searchText: "",
        currentSortColumn: "",
        currentSortDirection: "",
        drawingDocumentList: [],
      ),
    );
    getDrawingDocumentList(context: context, pageNumber: 1);
  }

  // DELETE DOCUMENT CATEGORY
  Future deleteDrawingDocument(
    DrawingDocumentModel document,
    BuildContext context,
    int index, {
    bool isSubDoc = false,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _drawingDocumentRepository.deleteDrawingDocument(
      drawingDocumentCategoryId:
          state
              .drawingDocumentCategoryModelList[state.categoryIndex]
              .drawingDocumentCategoryId,
      drawingDocumentId: document.drawingDocumentId,
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
          final updatedList = List<DrawingDocumentModel>.from(
            state.drawingDocumentList,
          );
          updatedList.removeAt(index);
          emit(
            state.copyWith(
              drawingDocumentList: updatedList,
              totalNumberOfRecord:
                  state.totalNumberOfRecord > 0
                      ? state.totalNumberOfRecord - 1
                      : 0,
            ),
          );
        } else {
          //Sub document delete
          final updatedList = List<DrawingDocumentModel>.from(
            state.subDrawingDocumentList,
          );
          updatedList.removeAt(index);
          emit(
            state.copyWith(
              subDrawingDocumentList: updatedList,
              totalNumberOfRecordOfSubDoc:
                  state.totalNumberOfRecordOfSubDoc > 0
                      ? state.totalNumberOfRecordOfSubDoc - 1
                      : 0,
            ),
          );
        }
        showSuccessMessage(context, subTitle: success['message']);
      },
    );
  }

  // SORT TEST Document
  Future applyFilterAndSortDrawingDocument({
    required BuildContext context,
    required String column,
    required String direction,
    required String buildingNumber,
    required String wing,
    required String floor,
  }) async {
    emit(
      state.copyWith(
        buildingNumberText: buildingNumber,
        wingText: wing,
        floorText: floor,
        currentSortColumn: column,
        currentSortDirection: direction,
        drawingDocumentList: [],
      ),
    );
    await getDrawingDocumentList(context: context, pageNumber: 1);
  }

  int updateFilterCount(DrawingDocumentState state) {
    final hasSort =
        state.currentSortColumn == "Drawing Document" &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");
    return getActiveFilterCount([
      hasSort,
      state.searchText.trim().isNotEmpty,
      state.buildingNumberText.trim().isNotEmpty,
      state.wingText.trim().isNotEmpty,
      state.floorText.trim().isNotEmpty,
    ]);
  }
}
