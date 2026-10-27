import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/data/model/building_summary.model.dart';

import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/data/model/construction_area.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/data/model/construction_area_comparative.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/data/repository/construction_area.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';

part 'construction_area_state.dart';

class ConstructionAreaCubit extends Cubit<ConstructionAreaState> {
  ConstructionAreaCubit() : super(ConstructionAreaState.inital());
  final ConstructionAreaRepository _constructionAreaRepository =
      serviceLocator<ConstructionAreaRepository>();

  Future searchConstructionArea(
    BuildContext context,
    int projectId,
    String value,
  ) async {
    emit(
      state.copyWith(
        searchConstructionAreaText: value,
        constructionAreaList: [],
      ),
    );
    await getConstructionAreaList(context, 1, projectId: projectId);
  }

  void clearConstructionAreSearch() {
    emit(
      state.copyWith(searchConstructionAreaText: "", constructionAreaList: []),
    );
  }

  Future searchConstructionAreaComparative(
    BuildContext context,
    int projectId,
    String value,
  ) async {
    emit(
      state.copyWith(
        searchConstructionAreaComparativeText: value,
        constructionAreaComparativeList: [],
      ),
    );
    await getConstructionAreaComparativeList(context, projectId: projectId);
  }

  void clearConstructionAreaComparativeSearch() {
    emit(
      state.copyWith(
        searchConstructionAreaComparativeText: "",
        constructionAreaComparativeList: [],
      ),
    );
  }

  // GET CONSTRUCTION AREA LIST
  Future getConstructionAreaList(
    BuildContext context,
    int pageNumber, {
    required int projectId,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ConstructionAreaId": state.constructionAreaId,
      "Floor": state.searchConstructionAreaText,
      "BuildingNumber": state.searchConstructionAreaByBuildingNumber,
      "Wing": state.searchConstructionAreaByWing,
      "Flat": state.searchConstructionAreaByUnit,
      "FlatType": state.searchConstructionAreaByUnitType,
      "FlatConfiguration": state.searchConstructionAreaByUnitConfiguration,
      "IsCheckPermission": false,
      "ApprovalStatus": "APPROVED",
    };
    var result = await _constructionAreaRepository.getConstructionArea(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
      projectId: projectId,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<ConstructionAreaModel> newData =
            List<ConstructionAreaModel>.from(response['data'] ?? []);
        final List<ConstructionAreaModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.constructionAreaList, ...newData];

        emit(
          state.copyWith(
            isLoading: false,
            constructionAreaList: updatedList,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  List<BuildingFloorGroup> groupByBuildingFloor(
    List<ConstructionAreaModel> list,
  ) {
    final Map<String, BuildingFloorGroup> grouped = {};
    for (final item in list) {
      if (item.buildingNumber.isEmpty) continue;
      final key = '${item.buildingNumber}||${item.floor}';
      grouped
          .putIfAbsent(
            key,
            () => BuildingFloorGroup(
              buildingNumber: item.buildingNumber,
              floor: item.floor,
              flats: [],
            ),
          )
          .flats
          .add(item);
    }
    return grouped.values.toList();
  }

  List<WingGroup> wingsOfFloor(String buildingNumber, String floor) {
    final Map<String, List<ConstructionAreaModel>> wings = {};
    for (final i in state.constructionAreaList) {
      if (i.buildingNumber == buildingNumber && i.floor == floor) {
        wings.putIfAbsent(i.wing, () => []).add(i);
      }
    }
    return wings.entries
        .map((e) => WingGroup(wing: e.key, flats: e.value))
        .toList();
  }

  // GET CONSTRUCTION AREA COMPARATIVE LIST
  Future getConstructionAreaComparativeList(
    BuildContext context, {
    required int projectId,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "Type": state.searchConstructionAreaComparativeText,
    };
    var result = await _constructionAreaRepository
        .getConstructionAreaComparative(
          queryParams: queryParams,
          projectId: projectId,
        );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<ConstructionAreaComparativeModel> newData =
            List<ConstructionAreaComparativeModel>.from(response['data'] ?? []);

        emit(
          state.copyWith(
            isLoading: false,
            constructionAreaComparativeList: newData,
          ),
        );
      },
    );
  }

  // UPDATE CONSTRUCTION AREA COMPARATIVE
  Future updateConstructionAreaComparative({
    required BuildContext context,
    required int index,
    required int constructionAreaComparativeId,
    required String uniqueKey,
    required int projectId,
    required double areaByPLLineSqMt,
    required String remark,
    required MultiFilePickerModel annexure,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> body = {
      "ConstructionAreaComparativeId": constructionAreaComparativeId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": projectId.toString(),
      "AreaByPLLineSqMt": areaByPLLineSqMt.toString(),
      "Remark": remark,
      "RemoveAnnexureURL": annexure.deletedFileList,
    };
    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < annexure.fileNameList.length; i++) {
      if (annexure.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "AnnexureURL",
        "value": annexure.fileBytesList[i],
        "fileName": annexure.fileNameList[i],
      });
    }
    var result = await _constructionAreaRepository
        .addUpdateConstructionAreaComparative(body: body, fileList: fileList);
    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();
        final updatedChannelPartner =
            (response['data'] as List<ConstructionAreaComparativeModel>).first;

        if (state.constructionAreaComparativeList.isNotEmpty &&
            index < state.constructionAreaComparativeList.length) {
          final updatedList = List<ConstructionAreaComparativeModel>.from(
            state.constructionAreaComparativeList,
          );

          updatedList[index] = updatedChannelPartner;

          emit(
            state.copyWith(
              isLoading: false,
              constructionAreaComparativeList: updatedList,
            ),
          );
        }

        showSuccessMessage(context, subTitle: response["message"]);
      },
    );
  }

  // UPDATE CONSTRUCTION AREA
  Future<void> updateConstructionArea({
    required BuildContext context,
    required int constructionAreaId,
    required String uniquekey,
    required int projectId,
    required double areaByPLLineSqMt,
    required double floorToFloorHeightMt,
    required int inventoryFlatId,
    required double multiplierForAreaPercentage,
    required String remark,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    String clean(double v) =>
        v == v.truncateToDouble() ? v.toInt().toString() : v.toString();
    final formData = {
      'ConstructionAreaId': constructionAreaId,
      'Uniquekey': uniquekey,
      'ProjectId': projectId,
      'AreaByPLLineSqMt': areaByPLLineSqMt,
      'FloorToFloorHeightMt': clean(floorToFloorHeightMt),
      'InventoryFlatId': inventoryFlatId,
      'MultiplierForAreaPercentage': multiplierForAreaPercentage,
      'Remark': remark,
    };
    final result = await _constructionAreaRepository.addUpdateConstructionArea(
      requestBody: formData,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: response['message']);
        getConstructionAreaList(context, 1, projectId: projectId);
      },
    );
  }

  Future applyConstructionAreaFilterAndSort({
    required BuildContext context,
    String? floor,
    String? buildingNumber,
    String? wing,
    String? unit,
    String? unitType,
    String? unitConfiguration,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          searchConstructionAreaText: "",
          searchConstructionAreaByBuildingNumber: "",
          searchConstructionAreaByWing: "",
          searchConstructionAreaByUnit: "",
          searchConstructionAreaByUnitType: "",
          searchConstructionAreaByUnitConfiguration: "",
        ),
      );
    } else {
      emit(
        state.copyWith(
          searchConstructionAreaText: floor ?? state.searchConstructionAreaText,
          searchConstructionAreaByBuildingNumber:
              buildingNumber ?? state.searchConstructionAreaByBuildingNumber,
          searchConstructionAreaByWing:
              wing ?? state.searchConstructionAreaByWing,
          searchConstructionAreaByUnit:
              unit ?? state.searchConstructionAreaByUnit,
          searchConstructionAreaByUnitType:
              unitType ?? state.searchConstructionAreaByUnitType,
          searchConstructionAreaByUnitConfiguration:
              unitConfiguration ??
              state.searchConstructionAreaByUnitConfiguration,
          constructionAreaList: [],
        ),
      );
    }
    await getConstructionAreaList(
      context,
      1,
      projectId: getProject().projectId,
    );
  }

  int updateConstructionAreaFilterCount(ConstructionAreaState state) {
    return getActiveFilterCount([
      state.searchConstructionAreaText.trim().isNotEmpty,
      state.searchConstructionAreaByBuildingNumber.trim().isNotEmpty,
      state.searchConstructionAreaByWing.trim().isNotEmpty,
      state.searchConstructionAreaByUnit.trim().isNotEmpty,
      state.searchConstructionAreaByUnitType.trim().isNotEmpty,
      state.searchConstructionAreaByUnitConfiguration.trim().isNotEmpty,
    ]);
  }

  Future<void> exportConstructionAreaExcelPdf(
    BuildContext context,
    String exportType, {
    required int projectId,
  }) async {
    if (state.totalNumberOfRecord == 0) {
      showErrorMessage(context, "Error", "No Data Found");
      return;
    }

    DialogHelper.showProcessingOverlay(context);

    final queryParams = <String, dynamic>{
      "ProjectId": projectId,
      "ConstructionAreaId": 0,
      "IsCheckPermission": false,
      "ApprovalStatus": "APPROVED",
      "ExportType": exportType,
    };

    // Include the search filter only when it has a value.
    if (state.searchConstructionAreaText.trim().isNotEmpty) {
      queryParams["Floor"] = state.searchConstructionAreaText.trim();
    }

    final result = await _constructionAreaRepository.exportConstructionArea(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams: queryParams,
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
              ? "ConstructionArea Data ${DateTime.now()}.pdf"
              : "ConstructionArea Data ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future exportConstructionAreaComparativeExcelPdf(
    BuildContext context,
    String exportType,
  ) async {
    if (state.totalNumberOfRecord == 0) {
      showErrorMessage(context, "Error", "No Data Found");
      return;
    }
    DialogHelper.showProcessingOverlay(context);
    var result = await _constructionAreaRepository
        .exportConstructionAreaComparative(
          pageNumber: 1,
          pageSize: state.totalNumberOfRecord,
          queryParams:
              state.searchConstructionAreaText != ""
                  ? {
                    "BuildingName": state.searchConstructionAreaText,
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
              ? "ConstructionArea Data Comparative ${DateTime.now()}.pdf"
              : "ConstructionArea Data Comparative ${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
