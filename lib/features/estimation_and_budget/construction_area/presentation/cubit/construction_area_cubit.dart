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

part 'construction_area_state.dart';

class ConstructionAreaCubit extends Cubit<ConstructionAreaState> {
  ConstructionAreaCubit() : super(ConstructionAreaState.inital());
  final ConstructionAreaRepository _constructionAreaRepository =
      serviceLocator<ConstructionAreaRepository>();

  // GET CONSTRUCTION AREA LIST
  Future getConstructionAreaList(
    BuildContext context,
    int pageNumber, {
    required int projectId,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ConstructionAreaId": state.constructionAreaId,
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
    Map<String, dynamic> queryParams = {};
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
  Future updateConstructionAreaComparativer({
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
}
