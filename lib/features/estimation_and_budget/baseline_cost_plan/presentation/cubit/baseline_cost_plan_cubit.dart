import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/baseline_cost_plan/data/model/baseline_cost_plan.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/baseline_cost_plan/data/model/baseline_cost_plan_category.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/baseline_cost_plan/data/repository/baseline_cost_plan.repository.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';

part 'baseline_cost_plan_state.dart';

class BaselineCostPlanCubit extends Cubit<BaselineCostPlanState> {
  BaselineCostPlanCubit() : super(BaselineCostPlanState.inital());

  final BaselineCostPlanRepository _baselineCostPlanRepository =
      serviceLocator<BaselineCostPlanRepository>();

  Future<void> resetSearchAndFetchCategories({
    required BuildContext context,
    required int projectId,
  }) async {
    emit(
      state.copywith(
        searchText: "",
        currentPage: 1,
        categoryIndex: 0,
        baselineCostPlanDocumentCategoryId: 0,
        baselineCostPlanDocumentList: [],
        baselineCostPlanDocumentCategoryList: [],
        isLoading: true,
      ),
    );

    await getBaselineCostPlanDocumentCategoryList(context, 1, projectId);

    if (!context.mounted) return;

    final categories = state.baselineCostPlanDocumentCategoryList;

    if (categories.isNotEmpty) {
      setSelectedCategory(categories.first.baselineCostPlanDocumentCategoryId);

      await getBaselineCostPlanDocumentList(context: context, pageNumber: 1);
    }
  }

  Future<void> searchDocument(String value, BuildContext context) async {
    emit(
      state.copywith(
        baselineCostPlanDocumentList: [],
        searchText: value.trim(),
        currentPage: 1,
        isLoading: true,
      ),
    );

    await getBaselineCostPlanDocumentList(context: context, pageNumber: 1);
  }

  //UPDATE CATEGORY INDEX AND MAKE GET API CALL AS PER CATEGORY
  void onTabChanged(int index, BuildContext context) {
    emit(
      state.copywith(
        categoryIndex: index,
        baselineCostPlanDocumentCategoryId:
            state
                .baselineCostPlanDocumentCategoryList[index]
                .baselineCostPlanDocumentCategoryId,
        searchText: "",
        currentSortColumn: "",
        currentSortDirection: "",
        baselineCostPlanDocumentList: [],
      ),
    );
    getBaselineCostPlanDocumentList(context: context, pageNumber: 1);
  }

  void setSelectedCategory(int categoryId) {
    emit(state.copywith(baselineCostPlanDocumentCategoryId: categoryId));
  }

  // GET BASELINE COST PLAN CATEGORY LIST
  Future getBaselineCostPlanDocumentCategoryList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copywith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
        BaselineCostPlanCubit();
        emit(
          state.copywith(
            isLoading: false,
            baselineCostPlanDocumentCategoryList: [],
          ),
        );
      });
      return;
    }
    Map<String, dynamic> queryParams = {
      "ProjectDocumentCategory": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      "IsCheckPermission": false,
    };
    var result = await _baselineCostPlanRepository
        .getBaselineCostPlanDocumentCategory(
          pageNumber: pageNumber,
          pageSize: 10,
          projectId: projectId,
          queryParams: queryParams,
        );

    result.fold(
      (failure) {
        emit(state.copywith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<BaselineCostPlanDocumentCategory> updatedList =
            pageNumber == 1
                ? List<BaselineCostPlanDocumentCategory>.from(
                  response['data'] ?? [],
                )
                : [
                  ...state.baselineCostPlanDocumentCategoryList,
                  ...List<BaselineCostPlanDocumentCategory>.from(
                    response['data'] ?? [],
                  ),
                ];
        emit(
          state.copywith(
            baselineCostPlanDocumentCategoryList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // GET BASELINE COST PLAN DOCUMENT
  Future getBaselineCostPlanDocumentList({
    required BuildContext context,
    required int pageNumber,
    int? baselineCostPlanDocumentId,
    String? baselineCostPlanDocumentCategory,
  }) async {
    emit(state.copywith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "BaselineCostPlanDocumentName": state.searchText,
      "BaselineCostPlanDocumentCategoryId":
          state.baselineCostPlanDocumentCategoryId,
      "BaselineCostPlanDocumentCategory": baselineCostPlanDocumentCategory,
      "BaselineCostPlanDocumentId": baselineCostPlanDocumentId,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    var result = await _baselineCostPlanRepository.pullDrawingDocument(
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
        final List<BaselineCostPlanDocumentModel> newData =
            List<BaselineCostPlanDocumentModel>.from(response['data'] ?? []);
        debugPrint('API documents count: ${newData.length}');
        if (baselineCostPlanDocumentId == null) {
          final List<BaselineCostPlanDocumentModel> updatedList =
              pageNumber == 1
                  ? newData
                  : [...state.baselineCostPlanDocumentList, ...newData];
          emit(
            state.copywith(
              isLoading: false,
              baselineCostPlanDocumentList: updatedList,
              totalNumberOfRecord: response["totalNumberOfRecord"],
              currentPage: pageNumber,
            ),
          );
        } else {
          final List<BaselineCostPlanDocumentModel> updatedSubDocList =
              pageNumber == 1
                  ? newData
                  : [...state.subBaselineCostPlanDocumentList, ...newData];
          emit(
            state.copywith(
              isLoading: false,
              subBaselineCostPlanDocumentList: updatedSubDocList,
              totalNumberOfRecordOfSubDoc: response["totalNumberOfRecord"],
              currentPageOfSubDoc: pageNumber,
            ),
          );
        }
      },
    );
  }

  //RENAME PARENT DOCUMENT NAME
  Future updateDrawingDocumentNameInCategory({
    required int index,
    required BuildContext context,
    required int baselineCostPlanDocumentId,
    required String uniqueKey,
    required String baselineCostPlanDocumentName,
    required int baselineCostPlanDocumentCategoryId,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "BaselineCostPlanDocumentId": baselineCostPlanDocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "BaselineCostPlanDocumentName": baselineCostPlanDocumentName,
      "BaselineCostPlanDocumentCategoryId":
          baselineCostPlanDocumentCategoryId.toString(),
      //isMaster is 1 means update document group into category
      "IsMaster": 1.toString(),
    };

    var result = await _baselineCostPlanRepository
        .addUpdateBaselineCostPlanDocument(body: body, fileList: fileList);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedDocument =
            response['data'][0] as BaselineCostPlanDocumentModel;

        if (state.baselineCostPlanDocumentList.isNotEmpty &&
            index < state.baselineCostPlanDocumentList.length) {
          final updatedListModel = List<BaselineCostPlanDocumentModel>.from(
            state.baselineCostPlanDocumentList,
          );
          updatedListModel[index] = updatedDocument;
          emit(
            state.copywith(
              isLoading: false,
              baselineCostPlanDocumentList: updatedListModel,
            ),
          );
        }

        showSuccessMessage(context, subTitle: response["message"]);
      },
    );
  }

  //ADD DOCUMENT TO CATEGORY
  Future addDrawingDocumentToCategory({
    required BuildContext context,
    required String baselineCostPlanDocumentName,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectId": getProject().projectId.toString(),
      "BaselineCostPlanDocumentName": baselineCostPlanDocumentName,
      "BaselineCostPlanDocumentCategoryId":
          state
              .baselineCostPlanDocumentCategoryList[state.categoryIndex]
              .baselineCostPlanDocumentCategoryId
              .toString(),
      //isMaster is 1 means add document group into category
      "IsMaster": 1.toString(),
    };
    List<Map<String, dynamic>> fileList = [];

    var result = await _baselineCostPlanRepository
        .addUpdateBaselineCostPlanDocument(body: body, fileList: fileList);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();

        showSuccessMessage(context, subTitle: response["message"]);
        searchDocument("", context);
      },
    );
  }

  Future updateSubDrawingDocument({
    required int index,
    required BuildContext context,
    required int baselineCostPlanDocumentId,
    required String uniqueKey,
    required String baselineCostPlanDocumentName,
    required int baselineCostPlanDocumentCategoryId,
    String? baselineCostPlanValue,
    String? baselineCostPlanDocumentRemark,
    MultiFilePickerModel? documents,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    final Map<String, String> body = {
      "BaselineCostPlanDocumentId": baselineCostPlanDocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "BaselineCostPlanDocumentName": baselineCostPlanDocumentName,
      "BaselineCostPlanDocumentCategoryId":
          baselineCostPlanDocumentCategoryId.toString(),
      "IsMaster": 0.toString(),
      if (baselineCostPlanValue != null &&
          baselineCostPlanValue.trim().isNotEmpty)
        "BaselineCostPlanValue": baselineCostPlanValue.trim(),
      "RemoveBaselineCostPlanDocumentURL": documents?.deletedFileList ?? '',
      "BaselineCostPlanDocumentRemark": baselineCostPlanDocumentRemark ?? '',
    };
    if (documents != null) {
      for (int i = 0; i < documents.fileNameList.length; i++) {
        if (documents.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "BaselineCostPlanDocumentURL",
          "value": documents.fileBytesList[i],
          "fileName": documents.fileNameList[i],
        });
      }
    }

    var result = await _baselineCostPlanRepository
        .addUpdateBaselineCostPlanDocument(body: body, fileList: fileList);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();

        final updatedDocument =
            response['data'][0] as BaselineCostPlanDocumentModel;

        if (state.subBaselineCostPlanDocumentList.isNotEmpty &&
            index < state.subBaselineCostPlanDocumentList.length) {
          final updatedListModel = List<BaselineCostPlanDocumentModel>.from(
            state.subBaselineCostPlanDocumentList,
          );

          updatedListModel[index] = updatedDocument;
          emit(
            state.copywith(
              isLoading: false,
              subBaselineCostPlanDocumentList: updatedListModel,
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
    required int baselineCostPlanDocumentId,
    required String uniqueKey,
    required int baselineCostPlanDocumentCategoryId,
    required String baselineCostPlanDocumentName,
    String? baselineCostPlanValue,
    String? baselineCostPlanDocumentRemark,
    MultiFilePickerModel? documents,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "BaselineCostPlanDocumentId": baselineCostPlanDocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "BaselineCostPlanDocumentCategoryId":
          baselineCostPlanDocumentCategoryId.toString(),
      "BaselineCostPlanDocumentName": baselineCostPlanDocumentName,
      //isMaster is 0 means add subdoc in document group
      "IsMaster": 0.toString(),
      "BaselineCostPlanValue": baselineCostPlanValue.toString(),
      "BaselineCostPlanDocumentRemark": baselineCostPlanDocumentRemark ?? '',
    };

    if (documents != null) {
      for (int i = 0; i < documents.fileNameList.length; i++) {
        if (documents.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "BaselineCostPlanDocumentURL",
          "value": documents.fileBytesList[i],
          "fileName": documents.fileNameList[i],
        });
      }
    }

    var result = await _baselineCostPlanRepository
        .addUpdateBaselineCostPlanDocument(body: body, fileList: fileList);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final currentPath = goRouter.state.path;
        if (currentPath == AppRoutes.viewBaselineCostPlan) {
          goRouter.pop();
        }

        if (state.subBaselineCostPlanDocumentList.isNotEmpty &&
            index < state.subBaselineCostPlanDocumentList.length) {
          final updatedListModel = List<BaselineCostPlanDocumentModel>.from(
            state.subBaselineCostPlanDocumentList,
          );

          // Only increment approvalPendingProjectDocumentCount & uploadedProjectDocumentCount counts in existing parent document instance
          updatedListModel[index] = updatedListModel[index].copyWith(
            baselineCostPlanDocumentName:
                updatedListModel[index].baselineCostPlanDocumentName,

            uploadedDocumentCount:
                updatedListModel[index].uploadedDocumentCount + 1,
          );

          emit(
            state.copywith(
              isLoading: false,
              subBaselineCostPlanDocumentList: updatedListModel,
            ),
          );
        }

        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  // DELETE BASELINE COST PLAN
  Future deleteBaseplanCostPlanDocument(
    BaselineCostPlanDocumentModel document,
    BuildContext context,
    int index, {
    bool isSubDoc = false,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _baselineCostPlanRepository
        .deleteBaseplanCostPlanDocument(
          baselineCostPlanDocumentCategoryId:
              state
                  .baselineCostPlanDocumentCategoryList[state.categoryIndex]
                  .baselineCostPlanDocumentCategoryId,
          baselineCostPlanDocumentId: document.baselineCostPlanDocumentId,
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
          final updatedList = List<BaselineCostPlanDocumentModel>.from(
            state.baselineCostPlanDocumentList,
          );
          updatedList.removeAt(index);
          emit(
            state.copywith(
              baselineCostPlanDocumentList: updatedList,
              totalNumberOfRecord:
                  state.totalNumberOfRecord > 0
                      ? state.totalNumberOfRecord - 1
                      : 0,
            ),
          );
        } else {
          //Sub document delete
          final updatedList = List<BaselineCostPlanDocumentModel>.from(
            state.subBaselineCostPlanDocumentList,
          );
          updatedList.removeAt(index);
          emit(
            state.copywith(
              subBaselineCostPlanDocumentList: updatedList,
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

  Future applyFilterAndSortBaselineCostPlan({
    required BuildContext context,
    required String column,
    required String direction,
    required String categoryName,
    required int projectId,
  }) async {
    emit(
      state.copywith(
        searchText: categoryName,
        currentSortColumn: column,
        currentSortDirection: direction,
        baselineCostPlanDocumentList: [],
      ),
    );
    await getBaselineCostPlanDocumentList(context: context, pageNumber: 1);
  }

  int updateFilterCount(BaselineCostPlanState state) {
    final hasSort =
        state.currentSortColumn == "Document Name" &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");
    return getActiveFilterCount([hasSort, state.searchText.trim().isNotEmpty]);
  }
}
