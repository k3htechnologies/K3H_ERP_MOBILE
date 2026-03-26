import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/model/leave_type_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/repository/leave_type_master.repository.dart';
import 'package:k3h_erp_app/features/payroll/leave/data/repository/leave.repository.dart';
import 'package:k3h_erp_app/features/payroll/leave/model/leave.model.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'leave_state.dart';

class LeaveCubit extends Cubit<LeaveState> {
  LeaveCubit() : super(LeaveState.initial());

  // REPOSITORY
  final LeaveRepository _leaveRepository = serviceLocator<LeaveRepository>();

  static const List<String> _statusTabs = [
    "All",
    "Pending",
    "Approved",
    "Rejected",
  ];

  // <---- SEARCH LEAVE ---->
  Future searchOutdoor(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, leaveList: []));
    await getLeaveList(context, 1);
  }

  // <---- GET LEAVE LIST ---->
  Future getLeaveList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    final status =
        state.currentTabIndex == 0
            ? ""
            : (state.currentTabIndex <= _statusTabs.length - 1
                ? _statusTabs[state.currentTabIndex]
                : "");
    final Map<String, dynamic> queryParams = {
      "LeaveType": state.searchText,
      "Status": status,
    };
    if (state.filterLeaveType != null && state.filterLeaveType!.isNotEmpty) {
      queryParams["LeaveType"] = state.filterLeaveType!;
    }
    if (state.filterStartDate != null) {
      queryParams["StartDate"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.filterStartDate!);
    }
    if (state.filterEndDate != null) {
      queryParams["EndDate"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.filterEndDate!);
    }
    var result = await _leaveRepository.getLeaveList(
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
        final List<LeaveModel> newData = List<LeaveModel>.from(
          response['data'] ?? [],
        );

        final List<LeaveModel> updatedList =
            pageNumber == 1 ? newData : [...state.leaveList, ...newData];
        emit(
          state.copyWith(
            leaveList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- APPLY LEAVE ---->
  Future<void> applyLeave({
    required BuildContext context,
    required String leaveTypeMasterId,
    required String startDate,
    required String endDate,
    required String startDateLeaveDuration,
    required String endDateLeaveDuration,
    required String reason,
    required MultiFilePickerModel leaveDocument,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "LeaveId": "0",
      "LeaveTypeMasterId": leaveTypeMasterId,
      "StartDate": startDate,
      "EndDate": endDate,
      "StartDateLeaveDuration": startDateLeaveDuration,
      "EndDateLeaveDuration": endDateLeaveDuration,
      "Reason": reason,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < leaveDocument.fileNameList.length; i++) {
      if (leaveDocument.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "LeaveDocumentURL",
        "value": leaveDocument.fileBytesList[i],
        "fileName": leaveDocument.fileNameList[i],
      });
    }
    var addResult = await _leaveRepository.addUpdateLeave(
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
        goRouter.pop();
        showSuccessMessage(context, subTitle: "Leave apply successfully");
      },
    );
  }

  // <---- UPDATE LEAVE ---->
  Future<void> updateLeave({
    required int index,
    required BuildContext context,
    required String leaveId,
    required String uniquekey,
    required String leaveTypeMasterId,
    required String startDate,
    required String endDate,
    required String startDateLeaveDuration,
    required String endDateLeaveDuration,
    required String reason,
    required MultiFilePickerModel leaveDocument,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "LeaveId": leaveId,
      "Uniquekey": uniquekey,
      "LeaveTypeMasterId": leaveTypeMasterId,
      "StartDate": startDate,
      "EndDate": endDate,
      "StartDateLeaveDuration": startDateLeaveDuration,
      "EndDateLeaveDuration": endDateLeaveDuration,
      "Reason": reason,
      "RemoveLeaveURL": leaveDocument.deletedFileList,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < leaveDocument.fileNameList.length; i++) {
      if (leaveDocument.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "LeaveDocumentURL",
        "value": leaveDocument.fileBytesList[i],
        "fileName": leaveDocument.fileNameList[i],
      });
    }
    var addResult = await _leaveRepository.addUpdateLeave(
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
        final updatedLeave = response['data'][0] as LeaveModel;

        if (state.leaveList.isNotEmpty && index < state.leaveList.length) {
          final updatedList = List<LeaveModel>.from(state.leaveList);
          updatedList[index] = updatedLeave;
          emit(state.copyWith(leaveList: updatedList, isLoading: false));
        }
        showSuccessMessage(context, subTitle: "Leave updated successfully");
      },
    );
  }

  // <---- DELETE LEAVE ---->
  Future deleteLeave({
    required BuildContext context,
    required int leaveId,
    required String uniqueKey,
    required int pageNumber,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _leaveRepository.deleteLeave(
      leaveId: leaveId,
      uniqueKey: uniqueKey,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context, subTitle: 'Leave Deleted Successfully!!!');
        if (index != null) {
          final updatedList = List<LeaveModel>.from(state.leaveList);
          updatedList.removeAt(index);

          emit(
            state.copyWith(
              leaveList: updatedList,
              totalNumberOfRecord:
                  state.totalNumberOfRecord > 0
                      ? state.totalNumberOfRecord - 1
                      : 0,
            ),
          );
        } else {
          getLeaveList(context, state.currentPage);
        }
      },
    );
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);

    var result = await _leaveRepository.exportLeave(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams: {"ExportType": exportType},
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
              ? "leave_${DateTime.now()}.pdf"
              : "leave_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  void onTabChanged(int index, BuildContext context) {
    emit(
      state.copyWith(
        currentTabIndex: index,
        leaveList: [],
        currentPage: 1,
        totalNumberOfRecord: 0,
      ),
    );
    getLeaveList(context, 1);
  }

  void onTabChangedViewScreen(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndexViewScreen: index));
  }

  // <---- APPLY FILTER ON LEAVE ---->
  void applyFilterOnLeave(
    BuildContext context, {
    String? leaveType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    emit(
      state.copyWith(
        filterLeaveType: leaveType,
        filterStartDate: startDate,
        filterEndDate: endDate,
        leaveList: [],
        currentPage: 1,
        totalNumberOfRecord: 0,
      ),
    );
    getLeaveList(context, 1);
  }

  void clearFilterOnLeave(BuildContext context) {
    emit(
      state.copyWith(
        clearFilters: true,
        leaveList: [],
        currentPage: 1,
        totalNumberOfRecord: 0,
      ),
    );
    getLeaveList(context, 1);
  }
}
