import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/village.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/data/model/call_log.model.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/data/model/calling_data.model.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/data/repository/call_tracker.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'call_tracker_state.dart';

class CallTrackerCubit extends Cubit<CallTrackerState> {
  CallTrackerCubit() : super(CallTrackerState.initial());

  // REPOSITORIES
  final CallTrackerRepository _callTrackerRepository =
      serviceLocator<CallTrackerRepository>();

  final UtilsRepository _utilsRepository = serviceLocator<UtilsRepository>();
  // HELPER ON TAB CHANGED
  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index, searchText: ""));
  }

  // SEARCH CALLING DATA
  Future<void> searchCallingData(
    BuildContext context,
    String searchText,
    int projectId,
  ) async {
    emit(state.copyWith(searchText: searchText, callingDataList: []));
    await getCallingDataList(context, 1, projectId);
  }

  Future<void> searchCallingLog(
    BuildContext context,
    String searchText,
    int projectId,
  ) async {
    emit(state.copyWith(searchText: searchText, callLogList: []));
    await getCallLogList(context, 1, projectId);
  }

  Future<void> applyFilterAndSort({
    required BuildContext context,
    String? mobileNumber,
    DateTime? rescheduleFromDate,
    DateTime? rescheduleToDate,
    required int projectId,
  }) async {
    emit(
      state.copyWith(
        filterMobileNo: mobileNumber,
        filterRescheduleFromDate: rescheduleFromDate,
        filterRescheduleToDate: rescheduleToDate,
      ),
    );

    if (state.currentTabIndex == 0) {
      getCallingDataList(context, 1, projectId);
    } else {
      await getCallLogList(context, 1, projectId);
    }
  }

  // <---- GET CALLING DATA LIST ---->
  Future getCallingDataList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    var queryParams = {
      "Name": state.searchText,
      "MobileNumber": state.filterMobileNo,
      "RescheduleDateFromDate":
          state.filterRescheduleFromDate?.toIso8601String(),
      "RescheduleDateToDate": state.filterRescheduleToDate?.toIso8601String(),
    };

    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
      });
      emit(state.copyWith(isLoading: false));
      return;
    }
    var result = await _callTrackerRepository.getCallingData(
      pageNumber: pageNumber,
      pageSize: 20,
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<CallingDataModel> newData = List<CallingDataModel>.from(
          response['data'] ?? [],
        );

        final List<CallingDataModel> updatedList =
            pageNumber == 1 ? newData : [...state.callingDataList, ...newData];
        emit(
          state.copyWith(
            callingDataList: updatedList,
            isLoading: false,
            totalNumberOfRecordCallingData: response["totalNumberOfRecord"],
            currentPageCallingData: pageNumber,
          ),
        );
      },
    );
  }

  Future addCallingData({
    required BuildContext context,
    required int projectId,
    required String name,
    required String emailId,
    required String mobileNumber,
    required String address,
    required String source,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "CallingDataId": 0,
      "ProjectId": projectId,
      "Name": name,
      "EmailId": emailId,
      "MobileNumber": mobileNumber,
      "Address": address,
      "Source": source,
    };
    var addResult = await _callTrackerRepository.addCallingData(body: body);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(
          context,
          subTitle: 'Calling Data Added Successfully!!!',
        );
        getCallingDataList(context, 1, projectId);
      },
    );
  }

  // <---- GET CALLING DATA LIST ---->
  Future getCallLogList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    var queryParams = {
      "Name": state.searchText,
      "MobileNumber": state.filterMobileNo,
      "RescheduleDateFromDate":
          state.filterRescheduleFromDate?.toIso8601String(),
      "RescheduleDateToDate": state.filterRescheduleToDate?.toIso8601String(),
    };
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
      });
      emit(state.copyWith(isLoading: false));
      return;
    }
    var result = await _callTrackerRepository.getCallLog(
      pageNumber: pageNumber,
      pageSize: 20,
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<CallLogModel> newData = List<CallLogModel>.from(
          response['data'] ?? [],
        );

        final List<CallLogModel> updatedList =
            pageNumber == 1 ? newData : [...state.callLogList, ...newData];
        emit(
          state.copyWith(
            callLogList: updatedList,
            isLoading: false,
            totalNumberOfRecordCallLog: response["totalNumberOfRecord"],
            currentPageCallLog: pageNumber,
          ),
        );
      },
    );
  }

  // <---- UPDATE CALL LOG ---->
  Future updateCallLog({
    required BuildContext context,
    required int callLogId,
    required int projectId,
    required String uniqueKey,
    required String remark,
    required String status,
    required String budget,
    required String requirement,
    required String residentialType,
    required String villageIds,
    required DateTime? rescheduleDate,
    required DateTime? siteVisitProposedDate,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "CallLogId": callLogId,
      "ProjectId": projectId,
      "Uniquekey": uniqueKey,
      "Status": status,
      "Remark": remark,
      "VillageMasterId": villageIds,
      "Budget": budget,
      "Requirement": requirement,
      "RequirementType": residentialType,
      if (siteVisitProposedDate != null)
        "SiteVisitProposedDate": siteVisitProposedDate.toIso8601String(),
      if (rescheduleDate != null)
        "RescheduleDate": rescheduleDate.toIso8601String(),
    };
    var addResult = await _callTrackerRepository.updateCallLog(
      body: requestBody,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedCallLog = response['data'][0] as CallLogModel;

        if (state.callLogList.isNotEmpty && index < state.callLogList.length) {
          final updatedList = List<CallLogModel>.from(state.callLogList);
          updatedList[index] = updatedCallLog;
          emit(state.copyWith(callLogList: updatedList, isLoading: false));
        }

        showSuccessMessage(
          context,
          subTitle: 'Call Log Updated Successfully!!!',
        );
      },
    );
  }

  // <---- DELETE CALL LOG ---->
  Future deleteCallLog({
    required BuildContext context,
    required int callLogId,
    required String uniqueKey,
    required int projectId,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _callTrackerRepository.deleteCallLog(
      projectId: projectId,
      callLogId: callLogId,
      uniqueKey: uniqueKey,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context);
        if (index != null) {
          final updatedList = List<CallLogModel>.from(state.callLogList);
          updatedList.removeAt(index);
          emit(state.copyWith(callLogList: updatedList, isLoading: false));
        } else {
          getCallLogList(context, state.currentPageCallLog, projectId);
        }
      },
    );
  }

  Future<Map<String, dynamic>> fetchVillages(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _utilsRepository.getVillageList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty ? {"VillageName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final villages = response['data'] as List<VillageModel>;

        return {
          "itemList":
              villages.map((village) {
                return {
                  "zAttributesId": village.villageMasterId,
                  "DisplayName": village.villageName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportCallingDataExcelPdf(
    BuildContext context,
    String exportType,
    int projectId,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _callTrackerRepository.exportCallingData(
      projectId: projectId,
      pageNumber: 1,
      pageSize: state.totalNumberOfRecordCallingData,
      queryParams:
          state.searchText != ""
              ? {"Name": state.searchText, "ExportType": exportType}
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
              ? "calling_data_${DateTime.now()}.pdf"
              : "calling_data_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future exportCallLogExcelPdf(
    BuildContext context,
    String exportType,
    int projectId,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _callTrackerRepository.exportCallLog(
      projectId: projectId,
      pageNumber: 1,
      pageSize: state.totalNumberOfRecordCallingData,
      queryParams:
          state.searchText != ""
              ? {"Name": state.searchText, "ExportType": exportType}
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
              ? "calling_log_${DateTime.now()}.pdf"
              : "calling_log_${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
