import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/data/model/outdoor.model.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/data/repository/outdoor.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'outdoor_state.dart';

class OutdoorCubit extends Cubit<OutdoorState> {
  OutdoorCubit() : super(OutdoorState.initial());

  // REPOSITORIES
  final OutdoorRepository _outdoorRepository =
      serviceLocator<OutdoorRepository>();

  // <---- SEARCH OUTDOOR ---->
  Future searchOutdoor(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, outdoorList: []));
    await getOutdoorList(context, 1);
  }

  // <---- GET OUTDOOR LIST ---->
  Future getOutdoorList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {"CompanyName": state.searchText};
    var result = await _outdoorRepository.getOutdoorList(
      pageNumber: pageNumber,
      pageSize: 10,
      // queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<OutdoorModel> newData = List<OutdoorModel>.from(
          response['data'] ?? [],
        );

        final List<OutdoorModel> updatedList =
            pageNumber == 1 ? newData : [...state.outdoorList, ...newData];
        emit(
          state.copyWith(
            outdoorList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- UPDATE OUTDOOR ATTENDANCE ---->
  Future addOutdoorAttendance({
    required BuildContext context,
    required int outdoorId,
    required String punchTime,
    required String address,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "OutdoorId": outdoorId,
      "Punch": punchTime,
      "Address": "string",
    };
    var addResult = await _outdoorRepository.addOutdoorAttendance(
      body: requestBody,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        final updatedDepartment = response['data'][0] as OutdoorModel;

        if (state.outdoorList.isNotEmpty && index < state.outdoorList.length) {
          final updatedList = List<OutdoorModel>.from(state.outdoorList);
          updatedList[index] = updatedDepartment;
          emit(state.copyWith(outdoorList: updatedList, isLoading: false));
        }

        showSuccessMessage(
          context,
          subTitle: 'Outdoor Attendance Updated Successfully!!!',
        );
      },
    );
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _outdoorRepository.exportOutdoor(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {"CompanyName": state.searchText, "ExportType": exportType}
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
              ? "outdoor_${DateTime.now()}.pdf"
              : "outdoor_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
  }
}
