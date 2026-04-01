import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
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
    var queryParams = {
      "StartDate":
          state.filterStartDate != null
              ? state.filterStartDate?.toIso8601String().split("T")[0]
              : null,
      "EndDate":
          state.filterEndDate != null
              ? state.filterEndDate?.toIso8601String().split("T")[0]
              : null,
    };
    var result = await _outdoorRepository.getOutdoorList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
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
        // Check message for error messages (base client puts SuccessMessage[0] into message)
        final apiMessage = response["message"]?.toString() ?? "";
        if (apiMessage.isNotEmpty &&
            apiMessage.toLowerCase().contains("error")) {
          showErrorMessage(context, "Error", apiMessage);
          return;
        }

        // Check if data exists and is not null/empty
        if (response["data"] != null &&
            response["data"] is List &&
            (response["data"] as List).isNotEmpty) {
          final updatedDepartment = response["data"][0] as OutdoorModel;

          if (state.outdoorList.isNotEmpty &&
              index < state.outdoorList.length) {
            final updatedList = List<OutdoorModel>.from(state.outdoorList);
            updatedList[index] = updatedDepartment;
            emit(state.copyWith(outdoorList: updatedList, isLoading: false));
          }

          showSuccessMessage(
            context,
            subTitle: 'Outdoor Attendance Updated Successfully!!!',
          );
        } else {
          // If no data returned, still show success if no errors
          showSuccessMessage(
            context,
            subTitle: 'Outdoor Attendance Updated Successfully!!!',
          );
        }
      },
    );
  }

  // <---- UPDATE OUTDOOR ATTENDANCE ---->
  Future addUpdateConclusion({
    required BuildContext context,
    required int outdoorId,
    required String conclusion,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "OutdoorId": outdoorId,
      "Conclusion": conclusion,
    };
    var addResult = await _outdoorRepository.addUpdateConclusion(
      body: requestBody,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        final apiMessage = response["message"]?.toString() ?? "";
        if (apiMessage.isNotEmpty &&
            apiMessage.toLowerCase().contains("error")) {
          showErrorMessage(context, "Error", apiMessage);
          return;
        }

        // Check if data exists and is not null/empty
        if (response["data"] != null &&
            response["data"] is List &&
            (response["data"] as List).isNotEmpty) {
          final updatedDepartment = response["data"][0] as OutdoorModel;

          if (state.outdoorList.isNotEmpty &&
              index < state.outdoorList.length) {
            final updatedList = List<OutdoorModel>.from(state.outdoorList);
            updatedList[index] = updatedDepartment;
            emit(state.copyWith(outdoorList: updatedList, isLoading: false));
          }

          showSuccessMessage(
            context,
            subTitle: 'Conclusion Added/Updated Successfully!!!',
          );
        }
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
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "outdoor_${DateTime.now()}.pdf"
              : "outdoor_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  // <---- CLEAR EMPLOYEE LIST ---->
  void clearEmployeeList() {
    emit(state.copyWith(employeeList: [], employeeTotalCount: 0));
  }

  // <---- ADD OUTDOOR ---->
  Future<void> addOutdoor({
    required BuildContext context,
    required String outDoorDate,
    required String outDoorTime,
    required String departmentId,
    required String companyName,
    required String companyAddress,
    required String purpose,
    required String accompaniedById,
    required MultiFilePickerModel visitingCardFile,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "OutdoorId": "0",
      "OutDoorDate": outDoorDate,
      "OutDoorTime": outDoorTime,
      "DepartmentId": departmentId,
      "CompanyName": companyName,
      "CompanyAddress": companyAddress,
      "Purpose": purpose,
      "Conclusion": "",
      "AccompaniedById": accompaniedById,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < visitingCardFile.fileNameList.length; i++) {
      if (visitingCardFile.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "VisitingCardURL",
        "value": visitingCardFile.fileBytesList[i],
        "fileName": visitingCardFile.fileNameList[i],
      });
    }
    var addResult = await _outdoorRepository.addUpdateOutdoor(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        emit(state.copyWith(isLoading: false));
        goRouter.pop(); // Close the add screen
        showSuccessMessage(context, subTitle: "Outdoor added successfully");
      },
    );
  }

  // <---- UPDATE OUTDOOR ---->
  Future<void> updateOutdoor({
    required int index,
    required BuildContext context,
    required String outdoorId,
    required String uniquekey,
    required String outDoorDate,
    required String outDoorTime,
    required String departmentId,
    required String companyName,
    required String companyAddress,
    required String purpose,
    required String accompaniedById,
    required MultiFilePickerModel visitingCardFile,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "OutdoorId": outdoorId,
      "Uniquekey": uniquekey,
      "OutDoorDate": outDoorDate,
      "OutDoorTime": outDoorTime,
      "DepartmentId": departmentId,
      "CompanyName": companyName,
      "CompanyAddress": companyAddress,
      "Purpose": purpose,
      "Conclusion": "",
      "AccompaniedById": accompaniedById,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < visitingCardFile.fileNameList.length; i++) {
      if (visitingCardFile.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "VisitingCardURL",
        "value": visitingCardFile.fileBytesList[i],
        "fileName": visitingCardFile.fileNameList[i],
      });
    }
    var addResult = await _outdoorRepository.addUpdateOutdoor(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        goRouter.pop();
        final updatedOutdoor = response['data'][0] as OutdoorModel;

        if (state.outdoorList.isNotEmpty && index < state.outdoorList.length) {
          final updatedList = List<OutdoorModel>.from(state.outdoorList);
          updatedList[index] = updatedOutdoor;
          emit(state.copyWith(outdoorList: updatedList, isLoading: false));
        }
        showSuccessMessage(context, subTitle: "Outdoor updated successfully");
      },
    );
  }

  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
  }

  Future<void> applyFilterAndSort({
    required BuildContext context,
    DateTime? filterFromHolidayDate,
    DateTime? filterToHolidayDate,
  }) async {
    // Update state with new filters and reset pagination
    emit(
      state.copyWith(
        isLoading: true,
        currentPage: 1,
        filterStartDate: filterFromHolidayDate,
        filterEndDate: filterToHolidayDate,
      ),
    );
    getOutdoorList(context, 1);
  }
}
